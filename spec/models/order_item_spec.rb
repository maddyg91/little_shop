require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
  end
  describe 'relationships' do
    it {should belong_to :item}
    it {should belong_to :order}
  end
  describe 'instance methods' do
    it ".insufficient_stock?" do
      item = FactoryBot.create(:item, instock_qty: 1)

      order_item_1 = FactoryBot.create(:order_item, item: item, quantity: 500)
      order_item_2 = FactoryBot.create(:order_item, item: item, quantity: 1)
      order_item_3 = FactoryBot.create(:order_item, item: item, quantity: 500, fulfilled: true)

      expect(order_item_1.insufficient_stock?).to eq(true)
      expect(order_item_2.insufficient_stock?).to eq(false)
      expect(order_item_3.insufficient_stock?).to eq(false)
    
    end

    it ".subtotal" do
      order_item_1 = FactoryBot.create(:order_item, price: 2, quantity: 3)
      expect(order_item_1.subtotal).to eq(6)
    end

    it '.fulfillable?' do
      merchant = FactoryBot.create(:merchant)
      item_1 = FactoryBot.create(:item, instock_qty: 1)
      item_2 = FactoryBot.create(:item, instock_qty: 2)
      item_3 = FactoryBot.create(:item, instock_qty: 2)
      merchant.items += [item_1, item_2, item_3]
      order = FactoryBot.create(:order)

      order_item_1 = FactoryBot.create(:order_item, item: item_1, order: order, quantity: 2)
      order_item_2 = FactoryBot.create(:order_item, item: item_2, order: order, quantity: 2)
      order_item_3 = FactoryBot.create(:order_item, item: item_2, order: order, quantity: 2, fulfilled: true)

      expect(order_item_1.fulfillable?).to eq(false)
      expect(order_item_2.fulfillable?).to eq(true)
      expect(order_item_3.fulfillable?).to eq(false)
    end

    it '.fulfill' do
      merchant = FactoryBot.create(:merchant)
      item_1 = FactoryBot.create(:item, instock_qty: 17)
      item_2 = FactoryBot.create(:item, instock_qty: 3)
      merchant.items += [item_1, item_2]
      order = FactoryBot.create(:order)

      order_item_1 = FactoryBot.create(:order_item, item: item_1, order: order, quantity: 5)
      order_item_2 = FactoryBot.create(:order_item, item: item_2, order: order, quantity: 2)

      expect(order.status).to eq("pending")
      expect(order_item_1.fulfilled?).to eq(false)

      order_item_1.fulfill

      expect(item_1.instock_qty).to eq(12)
      expect(order.reload.status).to eq("pending")


      order_item_2.fulfill
      expect(item_2.instock_qty).to eq(1)

      expect(order_item_1.fulfilled?).to eq(true)
      expect(order.reload.status).to eq("fulfilled")
    end
  end

  describe 'before_validations' do
    it ".ensures_price is equal to item price" do
      user = FactoryBot.create(:user)
      item_1 = FactoryBot.create(:item, price: 3.50)
      order_1 = Order.create!(user: user, items: [item_1])

      expect(order_1.order_items[0].price).to eq(item_1.price)
    end
  end
end
