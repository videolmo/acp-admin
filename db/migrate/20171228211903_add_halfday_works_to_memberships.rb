class AddActivityWorksToMemberships < ActiveRecord::Migration[5.1]
  def change
    add_column :memberships, :activity_participations, :integer, default: 0, null: false
    add_column :memberships, :validated_activity_participations, :integer, default: 0, null: false
  end
end
