class ChangeColumnDefaultAnnualActivityWorksOnMemberships < ActiveRecord::Migration[5.2]
  def change
    change_column_default :memberships, :activity_participations_demanded_annualy, nil
  end
end
