class AddEmailFooterAndActivityPhoneToAcps < ActiveRecord::Migration[5.2]
  def change
    add_column :acps, :email_footer, :string
    add_column :acps, :activity_phone, :string
  end
end
