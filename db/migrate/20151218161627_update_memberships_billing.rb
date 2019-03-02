class UpdateMembershipsBilling < ActiveRecord::Migration[4.2]
  def change
    remove_column :memberships, :distribution_basket_price
    remove_column :baskets, :activity_participations_demanded_annualy
    Membership
      .where(activity_participations_demanded_annualy: nil)
      .update_all(activity_participations_demanded_annualy: ActivityWork::MEMBER_PER_YEAR)
    rename_column :memberships, :annual_price, :activity_participations_annual_price_change
  end
end
