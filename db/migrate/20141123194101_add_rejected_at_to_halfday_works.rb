class AddRejectedAtToActivityWorks < ActiveRecord::Migration[4.2]
  def change
    add_column :activity_participations, :rejected_at, :datetime
    add_index :activity_participations, :rejected_at
  end
end
