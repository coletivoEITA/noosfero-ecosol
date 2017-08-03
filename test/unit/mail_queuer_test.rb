ENV['MAIL_QUEUER'] = '1'
require_relative "../test_helper"

class MailQueuerTest < ActiveSupport::TestCase

  def setup
    MailSchedule.delete_all
    Delayed::Job.delete_all

    ENV['MAIL_QUEUER_LIMIT'] = '100'

    MailSchedule.create dest_count: 0, scheduled_to: Time.now
    ApplicationMailer.deliveries = []
  end

  class Mailer < ApplicationMailer
    def test to:[], cc:[], bcc:[], from: Environment.default.noreply_email
      mail to: to, cc: cc, bcc: bcc, from: from,
        subject: "test", body: 'test'
    end
  end

  should 'fit the available limit' do
    to  = 80.times.map{ |i| "b#{i}@example.com" }
    cc  = 10.times.map{ |i| "b#{i}@example.com" }
    bcc =  9.times.map{ |i| "b#{i}@example.com" }
    Mailer.test(to: to, cc: cc, bcc: bcc).deliver

    Delayed::Worker.new.work_off
    message = ApplicationMailer.deliveries.last
    assert_equal 99, MailSchedule.first.dest_count
    assert_equal to, message.to
    assert_equal cc, message.cc
    assert_equal bcc, message.bcc
  end


  should 'break the mail when :to is bigger than limit' do
    to  = 100.times.map{ |i| "b#{i}@example.com" }
    cc  = ["cc@example.com"]
    bcc = ["bcc@example.com"]
    Mailer.test(to: to, cc: cc, bcc: bcc).deliver

    Delayed::Worker.new.work_off
    assert_equal 1, ApplicationMailer.deliveries.count
    message = ApplicationMailer.deliveries.first
    assert_equal 99, MailSchedule.first.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal to.first(99), message.to
    assert message.cc.blank?
    assert message.bcc.blank?

    message = job_message
    assert_equal 3, MailSchedule.last.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal [to.last], message.to
    assert_equal cc, message.cc
    assert_equal bcc, message.bcc
  end

  should 'break the mail with cc is bigger than limit' do
    to  = 10.times.map{ |i| "b#{i}@example.com" }
    cc  = 100.times.map{ |i| "b#{i}@example.com" }
    bcc = ["bcc@example.com"]
    Mailer.test(to: to, cc: cc, bcc: bcc).deliver

    Delayed::Worker.new.work_off
    assert_equal 1, ApplicationMailer.deliveries.count
    message = ApplicationMailer.deliveries.first
    assert_equal 99, MailSchedule.first.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal to, message.to
    assert_equal cc.first(89), message.cc
    assert message.bcc.blank?

    message = job_message
    assert_equal 13, MailSchedule.last.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal [to.first], message.to
    assert_equal cc[89..-1], message.cc
    assert_equal bcc, message.bcc
  end

  should 'break the mail with bcc is bigger than limit' do
    to  = 10.times.map{ |i| "b#{i}@example.com" }
    cc  = 10.times.map{ |i| "b#{i}@example.com" }
    bcc = 80.times.map{ |i| "b#{i}@example.com" }
    Mailer.test(to: to, cc: cc, bcc: bcc).deliver

    Delayed::Worker.new.work_off
    assert_equal 1, ApplicationMailer.deliveries.count
    message = ApplicationMailer.deliveries.first
    assert_equal 99, MailSchedule.first.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal to, message.to
    assert_equal cc, message.cc
    assert_equal bcc.first(79), message.bcc

    message = job_message
    assert_equal 2, MailSchedule.last.dest_count
    assert_equal to+cc, message.reply_to
    assert_equal [to.first], message.to
    assert message.cc.blank?
    assert_equal [bcc.last], message.bcc
  end

  should 'send in the next hour if available_limit < dest_count < limit' do
    MailSchedule.last.update dest_count: 90

    to  = 10.times.map{ |i| "b#{i}@example.com" }
    cc  = 10.times.map{ |i| "b#{i}@example.com" }
    bcc =  9.times.map{ |i| "b#{i}@example.com" }
    Mailer.test(to: to, cc: cc, bcc: bcc).deliver

    assert_equal 2, MailSchedule.count
    assert_equal 90, MailSchedule.first.dest_count
    assert_equal 29, MailSchedule.last.dest_count
    assert_equal MailSchedule.last.scheduled_to, MailSchedule.first.scheduled_to + 1.hour

    Delayed::Worker.new.work_off
    assert_equal nil, ApplicationMailer.deliveries.last

    message = job_message
    assert_equal to, message.to
    assert_equal cc, message.cc
    assert_equal bcc, message.bcc
  end

  protected

  def job_message job=Delayed::Job.last
    y   = YAML.load job.handler
    l   = y.job_data['arguments']
    m   = l.first
    bcc = l.second

    msg = Mail.read_from_string m
    msg.bcc = bcc
    msg
  end

end
