class RenameValidatedActivityWorksOnMemberships < ActiveRecord::Migration[5.2]
  def change
    rename_column :memberships, :validated_activity_participations, :activity_participations_accepted

    # Membership.find_each(&:update_activity_participations_accepted!)
  end
end
