class RenameActivityToActivity < ActiveRecord::Migration[5.2]
  def change
    rename_column :acps, :activity_i18n_scope, :activity_i18n_scope
    rename_column :acps, :activity_participation_deletion_deadline_in_days, :activity_participation_deletion_deadline_in_days
    rename_column :acps, :activity_availability_limit_in_days, :activity_availability_limit_in_days
    rename_column :acps, :activity_phone, :activity_phone

    rename_column :basket_sizes, :annual_activity_participations, :activity_participations_demanded_annualy

    rename_table :activities, :activities
    rename_table :activity_presets, :activity_presets
    rename_table :activity_participations, :activity_participations
    rename_column :activity_participations, :activity_id, :activity_id

    rename_column :invoices, :paid_missing_activity_participations, :paid_missing_activity

    rename_column :memberships, :activity_participations_annual_price, :activity_annual_price_change
    rename_column :memberships, :annual_activity_participations, :activity_participations_demanded_annualy
    rename_column :memberships, :activity_participations, :activity_participations_demanded
    rename_column :memberships, :recognized_activity_participations, :activity_participations_accepted
  end
end
