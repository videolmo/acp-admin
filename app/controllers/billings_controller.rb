class BillingsController < ApplicationController
  before_action :verify_auth_token

  # GET billing.xlsx
  def show
    @memberships = Membership.billable
    @members = Member.billable_for_membership_fee
    respond_to do |format|
      format.xlsx {
        render(
          xlsx: :show,
          filename: "RageDeVert-Facturation-#{Time.zone.now.strftime("%Y%m%d-%Hh%M")}"
        )
      }
    end
  end

  private

  def verify_auth_token
    if params[:auth_token] != ENV['BILLING_AUTH_TOKEN'] && !admin_signed_in?
      render text: 'unauthorized', status: :unauthorized
    end
  end
end
