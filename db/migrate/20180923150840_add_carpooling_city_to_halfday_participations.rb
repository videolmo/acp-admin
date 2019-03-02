class AddCarpoolingCityToActivityParticipations < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_participations, :carpooling_city, :string
  end
end
