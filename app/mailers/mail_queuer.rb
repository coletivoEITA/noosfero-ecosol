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

      set(options).perform_later message.encoded, message.bcc, delivery_method.to_s, delivery_method_options.to_yaml
    end

    ##
    # Mail delivery
    #
    def perform message, bcc, delivery_method, delivery_method_options
      m = Mail.read_from_string message
      m.bcc = bcc
      ApplicationMailer.wrap_delivery_behavior m, delivery_method.to_sym, YAML.load(delivery_method_options)
      m.deliver_now
    end
  end

  module InstanceMethods
    def deliver
      message    = nil
      last_sched = MailSchedule.last
      last_sched.with_lock do
        if last_sched != MailSchedule.last
          message = deliver_now
        else
          message = deliver_schedule last_sched
        end
      end
      message
    end

    def deliver_schedule last_sched
      limit   = ENV['MAIL_QUEUER_LIMIT'].to_i - 1
      orig_to = Array(to).dup
      orig_cc = Array(cc).dup
      dests   = {
        to:  Array(self.to),
        cc:  Array(self.cc),
        bcc: Array(self.bcc),
      }

      loop do
        # mailers don't like emails without :to,
        # so fill one if not present
        dests[:to] = [orig_to.first] if dests[:to].blank?

        dest_count = dests[:to].size + dests[:cc].size + dests[:bcc].size
        # dests are changed on email splits, so set it to the remaining values
        self.to    = dests[:to]
        self.cc    = dests[:cc]
        self.bcc   = dests[:bcc]

        ##
        # The last schedule is outside the quota period
        #
        if last_sched.scheduled_to < 1.hour.ago
          last_sched = MailSchedule.create! dest_count: 0, scheduled_to: Time.now.beginning_of_hour
        end

        available_limit = limit - last_sched.dest_count

        if dest_count <= available_limit
          last_sched.update dest_count: last_sched.dest_count + dest_count
          Job.schedule self, wait_until: last_sched.scheduled_to
          return self

        # avoid breaking mail which respect the mail limit. Schedule it all to the next hour
        elsif dest_count <= limit #&& ENV['AVOID_SPLIT']
          last_sched = MailSchedule.create! dest_count: dest_count, scheduled_to: last_sched.scheduled_to+1.hour
          Job.schedule self, wait_until: last_sched.scheduled_to
          return self

        else # dest_count > limit
          if available_limit == 0
            available_limit = limit
            last_sched = MailSchedule.create! dest_count: limit, scheduled_to: last_sched.scheduled_to+1.hour
          else
            # reuse current schedule
            last_sched.update dest_count: limit # limit = last.sched.dest_count + available_limit
          end

          # needs to preserve replies when spliting the email
          self.reply_to = orig_to + orig_cc if self.reply_to.blank?

          ##
          # start sending :to, followed by :cc, and so :bcc creating new schedules as needed
          #
          [:to, :cc, :bcc].each do |field|
            next self[field] = [] if available_limit == 0

            self[field] = dests[field].shift(available_limit)
            available_limit -= self.send(field).size
          end

          Job.schedule self, wait_until: last_sched.scheduled_to
        end
      end
    end

  end
end
