class CreateBaskets < ActiveRecord::Migration[5.1]
  def change
    create_table :baskets do |t|
      t.references :membership, foreign_key: true, null: false, index: true
      t.references :delivery, foreign_key: true, null: false, index: true
      t.references :basket_size, foreign_key: true, null: false, index: true
      t.references :distribution, foreign_key: true, null: false, index: true

      t.decimal :basket_price, scale: 3, precision: 8, default: 0, null: false
      t.decimal :distribution_price, scale: 2, precision: 8, default: 0, null: false

      t.boolean :trial, default: false, null: false
      t.boolean :absent, default: false, null: false

      t.timestamps
    end
    add_index :baskets, [:membership_id, :delivery_id], unique: true

    add_column :memberships, :baskets_count, :integer, default: 0, null: false



    change_column_default :memberships, :activity_participations_annual_price_change, 0
    change_column_default :memberships, :activity_participations_demanded_annualy, 0
    Membership.with_deleted.where(activity_participations_annual_price_change: nil).update_all(activity_participations_annual_price_change: 0)
    Membership.with_deleted.where(activity_participations_demanded_annualy: nil).update_all(activity_participations_demanded_annualy: 0)
    change_column_null :memberships, :activity_participations_annual_price_change, false
    change_column_null :memberships, :activity_participations_demanded_annualy, false
    change_column_null :memberships, :basket_size_id, true
    change_column_null :memberships, :distribution_id, true
  end
end
