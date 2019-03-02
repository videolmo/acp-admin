class AddLatestReminderSentAtToActivityParticipations < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_participations, :latest_reminder_sent_at, :timestamp
  end
end
