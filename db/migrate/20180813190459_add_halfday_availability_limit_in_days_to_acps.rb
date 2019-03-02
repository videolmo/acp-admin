class AddActivityAvailabilityLimitInDaysToAcps < ActiveRecord::Migration[5.2]
  def change
    add_column :acps, :activity_availability_limit_in_days, :integer, null: false, default: 3
  end
end
