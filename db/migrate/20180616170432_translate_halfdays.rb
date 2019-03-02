class TranslateActivitys < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_presets, :places, :jsonb, default: {}, null: false
    add_column :activity_presets, :place_urls, :jsonb, default: {}, null: false
    add_column :activity_presets, :activities, :jsonb, default: {}, null: false

    add_column :activities, :places, :jsonb, default: {}, null: false
    add_column :activities, :place_urls, :jsonb, default: {}, null: false
    add_column :activities, :activities, :jsonb, default: {}, null: false
    add_column :activities, :descriptions, :jsonb, default: {}, null: false

    acp = ACP.find_by(tenant_name: Apartment::Tenant.current)
    ActivityPreset.find_each do |activity_preset|
      places = acp.languages.map { |l| [l, activity_preset[:place]] }.to_h
      place_urls = acp.languages.map { |l| [l, activity_preset[:place_url]] }.to_h
      activities = acp.languages.map { |l| [l, activity_preset[:activity]] }.to_h
      activity_preset.update!(
        places: places,
        place_urls: place_urls,
        activities: activities)
    end
    Activity.find_each do |activity|
      places = acp.languages.map { |l| [l, halfday[:place]] }.to_h
      place_urls = acp.languages.map { |l| [l, halfday[:place_url]] }.to_h
      activities = acp.languages.map { |l| [l, halfday[:activity]] }.to_h
      descriptions = acp.languages.map { |l| [l, halfday[:description]] }.to_h
      activity.update!(
        places: places,
        place_urls: place_urls,
        activities: activities,
        descriptions: descriptions)
    end

    add_index :activity_presets, [:places, :activities], unique: true

    remove_column :activity_presets, :place
    remove_column :activity_presets, :place_url
    remove_column :activity_presets, :activity
    remove_column :activities, :place
    remove_column :activities, :place_url
    remove_column :activities, :activity
    remove_column :activities, :description
  end
end
