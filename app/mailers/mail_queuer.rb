module MailQueuer

  extend ActiveSupport::Concern

  included do
    alias_method :deliver_now, :deliver
    prepend InstanceMethods
  end

  class Job < ActiveJob::Base
    queue_as :default

    ##
    #
    def self.schedule message, options = {}
      delivery_method = ApplicationMailer.delivery_methods.find{ |n, k| k == message.delivery_method.class }.first
      delivery_method_options = message.delivery_method.settings

      set(options).perform_later message.encoded, delivery_method.to_s, delivery_method_options.to_yaml
    end

    ##
    # Mail delivery
    #
    def perform message, delivery_method, delivery_method_options
      m = Mail.read_from_string message
      ApplicationMailer.wrap_delivery_behavior m, delivery_method.to_sym, YAML.load(delivery_method_options)
      m.deliver_now
    end
  end

  module InstanceMethods
    def deliver
      last_sched = MailSchedule.last
      last_sched.with_lock do
        if last_sched != MailSchedule.last
          deliver_now
        else
          deliver_schedule last_sched
        end
      end
    end

    def deliver_schedule last_sched
      limit   = ENV['MAIL_QUEUER_LIMIT'].to_i - 1
      to      = self.to  ||= []
      orig_to = to.dup
      bcc     = self.bcc ||= []

      loop do
        dest_count = to.size + bcc.size

        ##
        # The last schedule is outside the quota period
        #
        if last_sched.scheduled_to < 1.hour.ago
          last_sched = MailSchedule.create! dest_count: 0, scheduled_to: Time.now
        end

        available_limit = limit - last_sched.dest_count

        if dest_count <= available_limit
          last_sched.update dest_count: last_sched.dest_count + dest_count
          Job.schedule self, wait_until: last_sched.scheduled_to
          return

        # avoid breaking mail which respect the mail limit. Schedule it all to the next hour
        elsif dest_count <= limit
          last_sched = MailSchedule.create! dest_count: dest_count, scheduled_to: last_sched.scheduled_to+1.hour
          Job.schedule self, wait_until: last_sched.scheduled_to
          return

        else # dest_count > limit
          if available_limit == 0
            available_limit = limit
            last_sched = MailSchedule.create! dest_count: limit, scheduled_to: last_sched.scheduled_to+1.hour
          else
            # reuse current schedule
            last_sched.update dest_count: limit # limit = last.sched.dest_count + available_limit
          end

          ##
          # Drop `to` until empty and then start dropping from bcc
          # #to and #bcc are changed destructively
          # for the next recursion
          #
          message = self.dup

          if to.size > 0
            message.to  = to.shift available_limit
            message.bcc = []
          else
            message.to  = [orig_to.first]
            message.bcc = bcc.shift available_limit
            message.reply_to = orig_to if reply_to.blank?
          end

          Job.schedule message, wait_until: last_sched.scheduled_to
        end
      end
    end

  end
end
