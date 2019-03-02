require 'rails_helper'

describe Activity do
  it_behaves_like 'bulk_dates_insert'

  it 'validates participants_limit to be at least 1' do
    halfday = Activity.new(participants_limit: 0)
    expect(halfday).not_to have_valid(:participants_limit)

    halfday = Activity.new(participants_limit: nil)
    expect(halfday).to have_valid(:participants_limit)
  end

  it 'creates an halfday without preset' do
    halfday = Activity.new(
      date: '2018-03-24',
      start_time: '8:30',
      end_time: '12:00',
      place: 'Thielle',
      place_url: 'https://goo.gl/maps/xSxmiYRhKWH2',
      activity: 'Aide aux champs',
      participants_limit: 3,
      description: 'Venez nombreux!')

    expect(activity.preset_id).to be_nil
    expect(activity.places['fr']).to eq 'Thielle'

    activity.save!

    expect(activity.start_time).to eq Tod::TimeOfDay.parse('8:30')
    expect(activity.end_time).to eq Tod::TimeOfDay.parse('12:00')
  end

  it 'creates an halfday with preset' do
    preset = ActivityPreset.create!(
      place: 'Thielle',
      place_url: 'https://goo.gl/maps/xSxmiYRhKWH2',
      activity: 'Aide aux champs')
    halfday = Activity.new(
      date: '2018-03-24',
      start_time: '8:30',
      end_time: '12:00',
      preset_id: preset.id)

    expect(activity.preset_id).to be_present
    expect(activity.places['fr']).to eq 'preset'
    expect(activity.place_urls['de']).to eq 'preset'
    expect(activity.activities['xx']).to eq 'preset'

    activity.save!

    h = Activity.find(activity.id)
    expect(h.place).to eq 'Thielle'
    expect(h.place_url).to eq 'https://goo.gl/maps/xSxmiYRhKWH2'
    expect(h.activity).to eq  'Aide aux champs'
  end

  describe '#period' do
    it 'does not pad hours' do
      halfday = Activity.new(
        date: '2018-03-24',
        start_time: '8:30',
        end_time: '12:00')

      expect(activity.period).to eq '8:30-12:00'
    end
  end
end
