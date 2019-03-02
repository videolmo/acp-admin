class CreateActivityWorkDates < ActiveRecord::Migration[4.2]
  def change
    create_table :activity_work_dates do |t|
      t.date :date, null: false
      t.string :periods, array: true, null: false

      t.timestamps null: false
    end

    add_index :activity_work_dates, :date
  end
end
