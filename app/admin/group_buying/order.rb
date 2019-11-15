ActiveAdmin.register GroupBuying::Order do
  menu parent: :group_buying, priority: 1
  actions :index, :show, :destroy

  filter :delivery,
    as: :select,
    collection: -> { GroupBuying::Delivery.order(created_at: :desc) }
  filter :member,
    as: :select,
    collection: -> { Member.joins(:group_buying_orders).order(:name).distinct }
  filter :created_at

  includes :member, :delivery

  index do
    column :created_at, ->(order) { auto_link order, l(order.created_at.to_date) }
    column :delivery, ->(order) { auto_link order.delivery }
    column :member, ->(order) { auto_link order.member }
    column :amount, ->(order) { number_to_currency(order.amount) }
    actions
  end

  # csv do
  #   column(:name)
  #   column(:producer) { |p| p.producer.name }
  #   column(:price) { |p| number_to_currency(p.price) }
  #   column(:available)
  #   column(:created_at)
  #   column(:updated_at)
  # end

  controller do
    include TranslatedCSVFilename

    before_action delivery: :index do
      if params[:commit].blank? && next_delivery = GroupBuying::Delivery.next
        params[:q] = { delivery_id_eq: next_delivery.id }
      end
    end
  end

  config.sort_order = 'created_at_desc'
end
