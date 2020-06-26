require 'rails_helper'

describe 'Membership' do
  let(:basket_size) { create(:basket_size, name: 'Petit') }
  let(:depot) { create(:depot, name: 'Joli Lieu', fiscal_year: Current.fiscal_year) }
  let(:member) { create(:member) }

  before do
    Capybara.app_host = 'http://membres.ragedevert.test'
  end

  specify 'inactive member' do
    login(member)

    within '#menu' do
      expect(page).not_to have_content 'Abonnement'
    end
  end

  specify 'active member with absence', freeze: '2020-02-01' do
    create(:membership,
      member: member,
      basket_size: basket_size,
      depot: depot)
    create(:absence,
      member: member,
      started_on: '2020-03-01',
      ended_on: '2020-04-01')

    login(member)

    within '#menu' do
      expect(page).to have_content 'Abonnement⤷ En cours'
    end

    click_on 'Abonnement'

    within 'main ul.details' do
      expect(page).to have_content 'Période'
      expect(page).to have_content '1 janvier 2020 – 31 décembre 2020'
      expect(page).to have_content 'Panier'
      expect(page).to have_content 'Petit'
      expect(page).to have_content 'Dépôt'
      expect(page).to have_content 'Joli Lieu'
      expect(page).to have_content 'Livraisons'
      expect(page).to have_content '40, 5 absences'
      expect(page).to have_content '½ Journées'
      expect(page).to have_content '2 demandées'
      expect(page).to have_content 'Prix'
      expect(page).to have_content "CHF 1'200.00"
    end
  end

  specify 'trial membership', freeze: '2020-02-01' do
    create(:membership,
      member: member,
      basket_size: basket_size,
      depot: depot,
      started_on: '2020-02-01')
    member.reload

    login(member)

    within '#menu' do
      expect(page).to have_content "Abonnement⤷ Période d'essai"
    end

    click_on 'Abonnement'

    within 'main ul.details' do
      expect(page).to have_content 'Période'
      expect(page).to have_content '1 février 2020 – 31 décembre 2020'
      expect(page).to have_content 'Panier'
      expect(page).to have_content 'Petit'
      expect(page).to have_content 'Dépôt'
      expect(page).to have_content 'Joli Lieu'
      expect(page).to have_content 'Livraisons'
      expect(page).to have_content "36, encore 4 à l'essai et sans engagement"
      expect(page).to have_content '½ Journées'
      expect(page).to have_content '2 demandées'
      expect(page).to have_content 'Prix'
      expect(page).to have_content "CHF 1'080.00"
    end
  end

  specify 'future membership', freeze: '2020-02-01' do
    Current.acp.update!(trial_basket_count: 0)
    create(:membership,
      member: member,
      basket_size: basket_size,
      depot: depot,
      started_on: '2020-06-01')
    member.reload

    login(member)

    within '#menu' do
      expect(page).to have_content "Abonnement⤷ À venir"
    end

    click_on 'Abonnement'

    within 'main ul.details' do
      expect(page).to have_content 'Période'
      expect(page).to have_content '1 juin 2020 – 31 décembre 2020'
      expect(page).to have_content 'Panier'
      expect(page).to have_content 'Petit'
      expect(page).to have_content 'Dépôt'
      expect(page).to have_content 'Joli Lieu'
      expect(page).to have_content 'Livraisons'
      expect(page).to have_content "19"
      expect(page).to have_content '½ Journées'
      expect(page).to have_content '1 demandée'
      expect(page).to have_content 'Prix'
      expect(page).to have_content "CHF 570"
    end
  end
end
