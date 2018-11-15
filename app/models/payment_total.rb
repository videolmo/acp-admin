class PaymentTotal
  include HalfdaysHelper
  include ActionView::Helpers::UrlHelper

  def self.all
    scopes = %i[paid missing]
    scopes.flatten.map { |scope| new(scope) }
  end

  attr_reader :scope

  def initialize(scope)
    @payments = Payment.current_year
    @invoices = Invoice.current_year.not_canceled
    @scope = scope
  end

  def title
    case scope
    when :paid
      link_to_payments I18n.t("billing.scope.#{scope}")
    when :missing
      link_to_open_invoices I18n.t("billing.scope.#{scope}")
    end
  end

  def price
    @price ||=
      case scope
      when :paid
        @payments.sum(:amount)
      when :missing
        @invoices.sum('amount - LEAST(amount, balance)')
      end
  end

  private

  def link_to_open_invoices(title)
    fy = Current.fiscal_year
    url_helpers = Rails.application.routes.url_helpers
    link_to title, url_helpers.invoices_path(
      scope: :open,
      q: {
        date_gteq: fy.beginning_of_year,
        date_lteq: fy.end_of_year
      })
  end

  def link_to_payments(title)
    fy = Current.fiscal_year
    url_helpers = Rails.application.routes.url_helpers
    link_to title, url_helpers.payments_path(
      scope: :all,
      q: {
        date_gteq: fy.beginning_of_year,
        date_lteq: fy.end_of_year
      })
  end
end
