module MembersHelper
  def languages_collection
    Current.acp.languages.map { |l| [t("languages.#{l}"), l] }
  end

  def billing_year_divisions_collection
    Current.acp.billing_year_divisions.map { |i|
      [collection_text(I18n.t("billing.year_division.x#{i}")), i]
    }
  end

  def basket_sizes_collection
    BasketSize.all.map { |bs|
      [
        collection_text(bs.name, bs.annual_price, [
          deliveries_count(bs.deliveries_count),
          halfdays_count(bs.annual_halfday_works)
        ].join(', ')),
        bs.id
      ]
    } << [collection_text(t('helpers.no_basket_size'), 0, t('helpers.no_basket_size_details')), 0]
  end

  def basket_complements_collection
    BasketComplement.includes(:deliveries).map { |bc|
      [
        collection_text(bc.name,
          bc.annual_price,
          deliveries_count(bc.deliveries.size),
          precision: 2),
        bc.id
      ]
    }
  end

  def distributions_collection
    Distribution.visible.reorder('price, name').map { |d|
      location = [d.address, "#{d.zip} #{d.city}".presence].compact.join(', ') if d.address?
      if location && location != d.address
        location += map_icon(location).html_safe
      end
      txt = collection_text(d.name, d.annual_price, location)

      [txt, d.id]
    }
  end

  def collection_text(text, price = 0, details = '', precision: 0)
    txts = [text]
    txts << "<em class='price'>#{number_to_currency(price, precision: precision)}</em>" if price.positive?
    txts << "<em>(#{details})</em>" if details.present?
    txts.join.html_safe
  end

  private


  def map_icon(location)
    <<-TXT
      <a href="https://www.google.com/maps?q=#{location}" title="#{location}" target="_blank">
        <i class="fa fa-map-signs"></i>
      </a>
    TXT
  end

  def deliveries_count(count)
    "#{count}&nbsp;#{Delivery.model_name.human(count: count)}".downcase
  end

  def halfdays_count(count)
    t_halfday('helpers.halfdays_count_per_year', count: count).gsub(/\s/, '&nbsp;')
  end
end
