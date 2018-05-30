class AddNamesToBasketSizes < ActiveRecord::Migration[5.2]
  def change
    add_column :basket_sizes, :names, :jsonb, default: {}, null: false

    ACP.enter_each! do
      BasketSize.find_each do |basket_size|
        names = Current.acp.languages.map { |l|
          [l, basket_size[:name]]
        }.to_h
        basket_size.update!(names: names)
      end
    end
  end
end
