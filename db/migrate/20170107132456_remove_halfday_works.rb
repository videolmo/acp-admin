class RemoveActivityWorks < ActiveRecord::Migration[5.0]
  def change
    drop_table :activity_participations
    drop_table :activity_work_dates
  end
end
