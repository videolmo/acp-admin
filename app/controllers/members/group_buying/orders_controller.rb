class Members::GroupBuying::OrdersController < Members::GroupBuying::BaseController
  # POST /group_buying/orders
  def create
    @order = current_member.group_buying_orders.new(
      protected_params.merge(delivery_id: @delivery.id))

    if @order.save
      redirect_to members_group_buying_path, notice: t('.flash.notice')
    else
      flash.now[:error] = t('.flash.error')
      render 'members/group_buying/base/show'
    end
  end

  private

  def protected_params
    params
      .require(:group_buying_order)
      .permit(
        :terms_of_service,
        items_attributes: %i[product_id quantity])
  end
end
