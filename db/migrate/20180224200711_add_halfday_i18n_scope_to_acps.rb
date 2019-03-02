class AddActivityI18nScopeToAcps < ActiveRecord::Migration[5.2]
  def change
    add_column :acps, :activity_i18n_scope, :string, null: false, default: 'halfday_work'
  end
end
