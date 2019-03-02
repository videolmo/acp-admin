class AddCarpoolingPhoneToActivityWorks < ActiveRecord::Migration[4.2]
  def change
    add_column :activity_participations, :carpooling_phone, :string
  end
end
