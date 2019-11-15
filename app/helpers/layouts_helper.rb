module LayoutsHelper
  def nav_class(controller)
    'active' if params[:controller].include? "members/#{controller}"
  end

  def next_group_buying_delivery
    @next_group_buying_delivery ||= GroupBuying::Delivery.next
  end

  def display_group_buying?
    Current.acp.feature?('group_buying') && next_group_buying_delivery && current_member.id == 110128
  end
end
