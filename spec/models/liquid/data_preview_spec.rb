require 'rails_helper'

describe Liquid::DataPreview do
  specify 'recursively render drop data' do
    create(:depot, id: 12, name: 'Jardin de la main')
    create(:basket_size, id: 33, name: 'Eveil')

    data = travel_to('2020-03-24') do
      mail_template = MailTemplate.create!(title: 'member_activated')
      described_class.for(mail_template)
    end

    expect(data).to eq({
      'member' =>  {
        'name' => 'John Doe',
        'page_url' => 'https://membres.ragedevert.ch',
        'billing_url' => 'https://membres.ragedevert.ch/billing'
      },
      'membership' => {
        'activity_participations_demanded_count' => 2,
        'basket_complement_names' => nil,
        'basket_complements' => [],
        'basket_size' => {
          'id' => 33,
          'name' => 'Eveil'
        },
        'depot' => {
          'id' => 12,
          'name' => 'Jardin de la main'
        },
        'end_date' => '31 décembre 2020',
        'start_date' => '24 mars 2020',
        'trial_baskets_count' => 4
      }
    })
  end

  specify 'render non-drop data' do
    data = travel_to('2020-03-24') do
      mail_template = MailTemplate.create!(title: 'member_validated')
      described_class.for(mail_template)
    end

    expect(data).to eq({
      'member' =>  {
        'name' => 'John Doe',
        'page_url' => 'https://membres.ragedevert.ch',
        'billing_url' => 'https://membres.ragedevert.ch/billing'
      },
      'waiting_list_position' => 1
    })
  end
end
