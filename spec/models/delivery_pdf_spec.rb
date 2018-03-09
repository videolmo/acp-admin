require 'rails_helper'

describe DeliveryPDF do
  def save_pdf_and_return_strings(delivery, distribution)
    pdf = DeliveryPDF.new(delivery, distribution)
    pdf_path = "tmp/delivery-#{Current.acp.name}-#{delivery.date}-#{distribution.name}.pdf"
    pdf.render_file(Rails.root.join(pdf_path))
    PDF::Inspector::Text.analyze(pdf.render).strings
  end

  context 'Rage de Vert settings' do
    before {
      Current.acp.update!(
        name: 'rdv',
        ccp: '01-13734-6',
        isr_identity: '00 11041 90802 41000',
        isr_payment_for: "Banque Raiffeisen du Vignoble\n2023 Gorgier",
        isr_in_favor_of: "Association Rage de Vert\nClosel-Bourbon 3\n2075 Thielle",
        invoice_info: 'Payable dans les 30 jours, avec nos remerciements.',
        invoice_footer: '<b>Association Rage de Vert</b>, Closel-Bourbon 3, 2075 Thielle /// info@ragedevert.ch, 076 481 13 84')
    }

    it 'generates invoice with all settings and member name and address' do
      member = create(:member,
        name: 'John Doe',
        address: 'unknown str. 42',
        zip: '0123',
        city: 'Nowhere')
      invoice = create(:invoice, :support, id: 706, member: member)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include('Facture N° 706')
        .and contain_sequence('John Doe', 'Unknown str. 42', '0123 Nowhere')
        .and contain_sequence('Banque Raiffeisen du Vignoble', '2023 Gorgier')
        .and contain_sequence('Association Rage de Vert', 'Closel-Bourbon 3', '2075 Thielle')
        .and include('N° facture: 706')
        .and include('01-13734-6')
    end

    it 'generates invoice with only support amount' do
      invoice = create(:invoice, :support, id: 807, support_amount: 42)
      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to contain_sequence('Cotisation annuelle association', '42.00')
        .and include('0100000042007>001104190802410000000008070+ 01137346>')
      expect(pdf_strings).not_to include('Montant annuel')
    end

    it 'generates invoice with support amount + annual membership' do
      membership = create(:membership,
        basket_size: create(:basket_size, :big),
        distribution: create(:distribution, price: 0))
      invoice = create(:invoice,
        id: 4,
        support_amount: 42,
        memberships_amount_description: 'Montant annuel',
        membership: membership)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01\.01\.20\d\d au 31\.12\.20\d\d/)
        .and contain_sequence('Panier: Abondance 40x 33.25', "1'330.00")
        .and contain_sequence('Montant annuel', "1'330.00", 'Montant annuel', "1'330.00")
        .and contain_sequence('Cotisation annuelle association', '42.00')
        .and contain_sequence('Total', "1'372.00")
        .and include '0100001372007>001104190802410000000000048+ 01137346>'
      expect(pdf_strings).not_to include 'Montant annuel restant'
    end

    it 'generates invoice with support ammount + annual membership + halfday_works reduc' do
      membership = create(:membership,
        basket_size: create(:basket_size, :big),
        distribution: create(:distribution, price: 0),
        annual_halfday_works: 8,
        halfday_works_annual_price: -330.50)
      invoice = create(:invoice,
        id: 7,
        support_amount: 30,
        memberships_amount_description: 'Montant annuel',
        membership: membership)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01\.01\.20\d\d au 31\.12\.20\d\d/)
        .and contain_sequence('Panier: Abondance 40x 33.25', "1'330.00")
        .and contain_sequence('Réduction pour 6 demi-journées supplémentaires', '- 330.50')
        .and contain_sequence('Montant annuel', "999.50", 'Montant annuel', "999.50")
        .and contain_sequence('Cotisation annuelle association', '30.00')
        .and contain_sequence('Total', "1'029.50")
        .and include '0100001029509>001104190802410000000000077+ 01137346>'
      expect(pdf_strings).not_to include 'Montant annuel restant'
    end

    it 'generates invoice with support ammount + quarter membership' do
      member = create(:member, billing_year_division: 4)
      membership = create(:membership,
        member: member,
        basket_size: create(:basket_size, :small, price: '23.125'),
        distribution: create(:distribution, name: 'La Chaux-de-Fonds', price: 4))
      invoice =  create(:invoice,
        id: 8,
        member: member,
        support_amount: 30,
        membership_amount_fraction: 4,
        memberships_amount_description: 'Montant trimestriel #1',
        membership: membership)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01\.01\.20\d\d au 31\.12\.20\d\d/)
        .and contain_sequence('Panier: Eveil 40x 23.125', '925.00')
        .and contain_sequence('Distribution: La Chaux-de-Fonds 40x 4.00', '160.00')
        .and contain_sequence('Montant annuel', "1'085.00")
        .and contain_sequence('Montant trimestriel #1', '271.25')
        .and contain_sequence('Cotisation annuelle association', '30.00')
        .and contain_sequence('Total', '301.25')
        .and include '0100000301256>001104190802410000000000085+ 01137346>'
    end

    it 'generates invoice with quarter menbership and paid amount' do
      member = create(:member, billing_year_division: 4)
      membership = create(:membership,
        member: member,
        basket_size: create(:basket_size, :big),
        distribution: create(:distribution, price: 0))
      create(:invoice,
        date: Time.current.beginning_of_year,
        member: member,
        membership_amount_fraction: 4,
        memberships_amount_description: 'Montant trimestriel #1',
        membership: membership)
      create(:invoice,
        date: Time.current.beginning_of_year + 4.months,
        member: member,
        membership_amount_fraction: 3,
        memberships_amount_description: 'Montant trimestriel #2',
        membership: membership)
      invoice = create(:invoice,
        id: 11,
        date: Time.current.beginning_of_year + 8.months,
        member: member,
        membership_amount_fraction: 2,
        memberships_amount_description: 'Montant trimestriel #3',
        membership: membership)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01\.01\.20\d\d au 31\.12\.20\d\d/)
        .and contain_sequence('Panier: Abondance 40x 33.25', "1'330.00",)
        .and contain_sequence('Déjà facturé', '- 665.00')
        .and contain_sequence('Montant annuel restant', '665.00')
        .and contain_sequence('Montant trimestriel #3', '332.50')
        .and include('0100000332508>001104190802410000000000112+ 01137346>')
      expect(pdf_strings).not_to include 'Cotisation annuelle association'
    end
  end

  context 'Lumiere des Champs' do
    before {
      set_acp_logo('ldc_logo.jpg')
      Current.acp.update!(name: 'ldc')
    }

    it 'generates invoice with support amount + complements + annual membership' do
      distribution = create(:distribution, name: 'Fleurs Kissling')
      member = create(:member, name: 'Alain Reymond')
      member2 = create(:member, name: 'John Doe')
      create(:basket_complement,
        id: 1,
        name: 'Oeufs',
        delivery_ids: Delivery.current_year.pluck(:id))
      create(:basket_complement,
        id: 2,
        name: 'Tomme de Lavaux',
        delivery_ids: Delivery.current_year.pluck(:id))
      membership = create(:membership,
        member: member,
        distribution: distribution,
        basket_size: create(:basket_size, name: 'Grand'),
        memberships_basket_complements_attributes: {
          '0' => { basket_complement_id: 1 },
          '1' => { basket_complement_id: 2 }
        })
      membership = create(:membership,
        member: member2,
        distribution: distribution,
        basket_size: create(:basket_size, name: 'Petit'),
        basket_quantity: 2,
        memberships_basket_complements_attributes: {
          '0' => { basket_complement_id: 1, quantity: 2 },
        })
      delivery = Delivery.current_year.first
      distribution = membership.distribution

      pdf_strings = save_pdf_and_return_strings(delivery, distribution)

      # expect(pdf_strings)
      #   .to include(/Période du 01.04.20\d\d au 31.03.20\d\d/)
      #   .and contain_sequence('Panier: Grand 48x 30.50', "1'464.00")
      #   .and contain_sequence('Oeufs 24x 4.80', "115.20")
      #   .and contain_sequence('Tomme de Lavaux 24x 7.40', "177.60")
      #   .and contain_sequence('Montant annuel', "1'756.80", 'Montant annuel', "1'756.80")
      #   .and contain_sequence('Cotisation annuelle association', '75.00')
      #   .and contain_sequence('Total', "1'831.80")
      #   .and include '0100001831806>800250000000000000000001221+ 0192520>'
      # expect(pdf_strings).not_to include 'Montant annuel restant'
    end

    it 'generates invoice with support ammount + four month membership + winter basket' do
      member = create(:member,
        name: 'Alain Reymond',
        address: 'Bd Plumhof 6',
        zip: '1800',
        city: 'Vevey')
      membership = create(:membership,
        basket_size: create(:basket_size, name: 'Grand'),
        distribution: create(:distribution, price: 0),
        basket_price: 30.5,
        seasons: %w[winter])
      create(:invoice,
        support_amount: 75,
        date: Current.fy_range.min,
        membership_amount_fraction: 3,
        memberships_amount_description: 'Montant quadrimestriel #1',
        membership: membership,
        member: member)
      invoice = create(:invoice,
        id: 125,
        date: Current.fy_range.min + 4.month,
        membership_amount_fraction: 2,
        memberships_amount_description: 'Montant quadrimestriel #2',
        membership: membership,
        member: member)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01.04.20\d\d au 31.03.20\d\d/)
        .and contain_sequence('Panier: Grand 22x 30.50', '671.00')
        .and contain_sequence('Déjà facturé', '- 223.65')
        .and contain_sequence('Montant annuel restant', '447.35')
        .and contain_sequence('Montant quadrimestriel #2', "223.70")
        .and include '0100000223709>800250000000000000000001252+ 0192520>'
      expect(pdf_strings).not_to include 'Cotisation annuelle association'
    end

    it 'generates invoice with mensual membership + complements' do
      member = create(:member,
        name: 'Alain Reymond',
        address: 'Bd Plumhof 6',
        zip: '1800',
        city: 'Vevey')
      create(:basket_complement,
        id: 1,
        name: 'Oeufs',
        price: 4.8,
        delivery_ids: Delivery.current_year.pluck(:id)[0..23])
      membership = create(:membership,
        basket_size: create(:basket_size, name: 'Petit'),
        distribution: create(:distribution, price: 0),
        basket_price: 21,
        memberships_basket_complements_attributes: {
          '0' => { basket_complement_id: 1 }
        })

      create(:invoice,
        support_amount: 75,
        date: Current.fy_range.min,
        membership_amount_fraction: 12,
        memberships_amount_description: 'Montant mensuel #1',
        membership: membership,
        member: member)
      create(:invoice,
        date: Current.fy_range.min + 1.month,
        membership_amount_fraction: 11,
        memberships_amount_description: 'Montant mensuel #2',
        membership: membership,
        member: member)

      invoice = create(:invoice,
        id: 127,
        date: Current.fy_range.min + 2.months,
        membership_amount_fraction: 10,
        memberships_amount_description: 'Montant mensuel #3',
        membership: membership,
        member: member)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01.04.20\d\d au 31.03.20\d\d/)
        .and contain_sequence('Panier: Petit 48x 21.00', "1'008.00")
        .and contain_sequence('Oeufs 24x 4.80', "115.20")
        .and contain_sequence('Déjà facturé', '- 187.20')
        .and contain_sequence('Montant annuel restant', '936.00')
        .and contain_sequence('Montant mensuel #3', "93.60")
        .and include '0100000093604>800250000000000000000001273+ 0192520>'
      expect(pdf_strings).not_to include 'Cotisation annuelle association'
    end

    it 'generates invoice with support ammount + baskets_annual_price_change reduc + complements' do
      member = create(:member,
        name: 'Alain Reymond',
        address: 'Bd Plumhof 6',
        zip: '1800',
        city: 'Vevey')
      create(:basket_complement,
        id: 2,
        price: 7.4,
        name: 'Tomme de Lavaux',
        delivery_ids: Delivery.current_year.pluck(:id)[24..48])
      membership = create(:membership,
        started_on: Current.fy_range.min + 5.months,
        basket_size: create(:basket_size, name: 'Grand'),
        distribution: create(:distribution, price: 0),
        basket_price: 30.5,
        baskets_annual_price_change: -44,
        memberships_basket_complements_attributes: {
          '1' => { basket_complement_id: 2 }
        })

      invoice = create(:invoice,
        id: 123,
        support_amount: 75,
        memberships_amount_description: 'Montant annuel',
        membership: membership,
        member: member)

      pdf_strings = save_pdf_and_return_strings(invoice)

      expect(pdf_strings)
        .to include(/Période du 01.09.20\d\d au 31.03.20\d\d/)
        .and contain_sequence('Panier: Grand 27x 30.50', '823.50')
        .and contain_sequence('Ajustement du prix des paniers', '- 44.00')
        .and contain_sequence('Tomme de Lavaux 24x 7.40', '177.60')
        .and contain_sequence('Montant annuel', '957.10', 'Montant annuel', '957.10')
        .and contain_sequence('Cotisation annuelle association', '75.00')
        .and contain_sequence('Total', "1'032.10")
        .and include '0100001032108>800250000000000000000001236+ 0192520>'
      expect(pdf_strings).not_to include 'Montant restant'    end
  end
end
