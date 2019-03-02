class AddParticipantsLimitToActivityWorkDates < ActiveRecord::Migration[4.2]
  def change
    add_column :activity_work_dates, :participants_limit, :integer
  end
end
