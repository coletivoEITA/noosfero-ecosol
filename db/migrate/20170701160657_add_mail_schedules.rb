class AddMailSchedules < ActiveRecord::Migration
  def change
    create_table :mail_schedules do |t|
      t.integer :dest_count
      t.datetime :scheduled_to
    end
    MailSchedule.create(dest_count: 0, scheduled_to: Time.now)
  end
end
