class CreateActivityWorks < ActiveRecord::Migration[4.2]
  def change
    create_table :activity_participations do |t|
      t.references :member, index: true, null: false
      t.date :date, null: false
      t.string :periods, array: true, null: false
      t.datetime :validated_at
      t.references :validator, index: true
      t.integer :participants_count, default: 1, null: false

      t.timestamps
    end

    add_index :activity_participations, :date
    add_index :activity_participations, :validated_at
  end
end
