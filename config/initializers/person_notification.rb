if Delayed::Backend::ActiveRecord::Job.table_exists? &&
  Delayed::Backend::ActiveRecord::Job.attribute_names.include?('queue')

  # FIXME: Disable it as is hanging delayed_job a lot on restarts
  #PersonNotifier.schedule_all_next_notification_mail
end
