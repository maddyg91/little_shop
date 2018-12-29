require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :email}
    it {should validate_uniqueness_of :email}
    it {should validate_presence_of :role}
    it {should validate_presence_of :password}
    it {should validate_presence_of :address}
    it {should validate_presence_of :city}
    it {should validate_presence_of :state}
    it {should validate_presence_of :zip_code}
    it {should validate_confirmation_of :password}
  end
  describe 'relationships' do
    it {should have_many :items}
    it {should have_many :orders}
  end

  describe 'instance methods' do
    it '.status' do
      user = FactoryBot.create(:user)
      expect(user.status).to eq("Enabled")
      user.enabled = false
      expect(user.status).to eq("Disabled")
    end

    it '.merchant_pending_orders' do
      # Current_user
      user = FactoryBot.create(:merchant)

      # Another merchant
      user_2 = FactoryBot.create(:merchant)

      # Item for other merchant
      item_1 = FactoryBot.create(:item, user: user_2)

      # Item for current_user
      item_2 = FactoryBot.create(:item, user: user)

      # Order - pending -for other merchant - should not show up
      order_1 = FactoryBot.create(:pending, items: [item_1])

      # Order - pending -for current_user - should show up
      order_2 = FactoryBot.create(:pending)
      order_item = FactoryBot.create(:order_item, order: order_2, item: item_2)

      # Creates a second order to insure a list is populating to the page for the current_user.
      order_5 = FactoryBot.create(:pending)
      order_item_2 = FactoryBot.create(:order_item, order: order_5, item: item_2)

      # Order - cancelled -for current_user - should not show up
      order_3 = FactoryBot.create(:cancelled, items: [item_1, item_2])

      # Order - fulfilled -for current_user - should not show up
      order_4 = FactoryBot.create(:fulfilled, items: [item_1, item_2])

      expect(user.merchant_pending_orders).to eq([order_2, order_5])

    end
    it '.my_order_items(order)' do
      merchant = FactoryBot.create(:merchant)
      item_1 = FactoryBot.create(:item)
      item_2 = FactoryBot.create(:item)
      FactoryBot.create(:item)
      merchant.items << item_1

      order = FactoryBot.create(:order, items: [item_1, item_2])

      expect(merchant.my_order_items(order)).to eq(item_1.order_items)
    end
    describe 'user statistics' do
      before(:each) do
        @merchant = FactoryBot.create(:merchant)

        @item_1 = FactoryBot.create(:item, instock_qty: 600, price: 5, user: @merchant)
        @item_2 = FactoryBot.create(:item, instock_qty: 200, price: 10, user: @merchant)
        @item_3 = FactoryBot.create(:item, instock_qty: 200, price: 20, user: @merchant)
        @item_4 = FactoryBot.create(:item, instock_qty: 200, price: 40, user: @merchant)
        @item_5 = FactoryBot.create(:item, instock_qty: 200, price: 80, user: @merchant)
        @item_6 = FactoryBot.create(:item, instock_qty: 200, price: 50000, user: @merchant)

        @user_1 = FactoryBot.create(:user, city: 'Denver', state: 'CO')
        @user_1_order_1 = FactoryBot.create(:fulfilled, user: @user_1)
        @user_1_order_2 = FactoryBot.create(:fulfilled, user: @user_1)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_1_order_1)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_1_order_2)
    # $1000, 200 pcs
        @user_2 = FactoryBot.create(:user, city: 'Denver', state: 'MI')
        @user_2_order_1 = FactoryBot.create(:fulfilled, user: @user_2)
        @user_2_order_2 = FactoryBot.create(:fulfilled, user: @user_2)
        @user_2_order_3 = FactoryBot.create(:fulfilled, user: @user_2)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_2_order_1)
        FactoryBot.create(:order_item, item: @item_2, price: @item_2.price, quantity: 105, fulfilled: true, order: @user_2_order_2)
        FactoryBot.create(:order_item, item: @item_3, price: @item_3.price, quantity: 50, fulfilled: true, order: @user_2_order_3)
    # $1550, 255 pcs,

        @user_3 = FactoryBot.create(:user, city: 'Salt Lake City', state: 'UT')
        @user_3_order_1 = FactoryBot.create(:fulfilled, user: @user_3)
        @user_3_order_2 = FactoryBot.create(:fulfilled, user: @user_3)
        @user_3_order_3 = FactoryBot.create(:fulfilled, user: @user_3)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_3_order_1)
        FactoryBot.create(:order_item, item: @item_4, price: @item_4.price, quantity: 50, fulfilled: true, order: @user_3_order_2)
        FactoryBot.create(:order_item, item: @item_4, price: @item_4.price, quantity: 51, fulfilled: true, order: @user_3_order_3)
    # $4540, 201 pcs

        @user_4 = FactoryBot.create(:user, city: 'Los Angeles', state: 'CA')
        @user_4_order_1 = FactoryBot.create(:fulfilled, user: @user_4)
        @user_4_order_2 = FactoryBot.create(:fulfilled, user: @user_4)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_4_order_1)
        FactoryBot.create(:order_item, item: @item_5, price: @item_5.price, quantity: 1, fulfilled: true, order: @user_4_order_2)
    # $580, 101 pcs

        @user_5 = FactoryBot.create(:user, city: 'Fort Collins', state: 'CO')
        @user_5_order_1 = FactoryBot.create(:fulfilled, user: @user_5)
        @user_5_order_2 = FactoryBot.create(:fulfilled, user: @user_5)
        FactoryBot.create(:order_item, item: @item_6, price: @item_6.price, quantity: 2, fulfilled: true, order: @user_5_order_1)
        FactoryBot.create(:order_item, item: @item_1, price: @item_1.price, quantity: 100, fulfilled: true, order: @user_5_order_2)
    # $100,500, 102 pcs

        @user_6 = FactoryBot.create(:user, city: 'Dallas', state: 'TX')
        @user_6_order_1 = FactoryBot.create(:pending, user: @user_6)
        FactoryBot.create(:order_item, item: @item_6, price: @item_6.price, quantity: 2, fulfilled: false, order: @user_6_order_1)
    # 0
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      end
      it '.top_5_items' do
        expect(@merchant.top_5_items).to eq([@item_1, @item_2, @item_4, @item_3, @item_6])
      end
      it '.total_items_sold' do
        expect(@merchant.total_items_sold).to eq(859)
      end
      it '.percent_items_sold' do
        expect(@merchant.percent_items_sold).to eq('35%')
      end
      it '.top_3_states' do
        top_states = @merchant.top_3_states.map { |state| state.state }
        expect(top_states).to eq(['CO', 'MI', 'UT'])
      end
      it '.top_3_city_states' do
        top_cities = @merchant.top_3_city_states.map { |citystate| "#{citystate.city}, #{citystate.state}"}
        expect(top_cities).to eq(["Denver, MI", "Salt Lake City, UT", "Denver, CO"])
      end
      it '.top_customer_by_orders' do
        expect(@merchant.top_customer_by_orders).to eq(@user_2)
      end
      it '.top_customer_by_qty' do
        expect(@merchant.top_customer_by_qty).to eq(@user_2)
      end
      it '.top_3_customers_by_total_paid' do
        expect(@merchant.top_3_customers_by_total_paid).to eq([@user_5, @user_3, @user_2])
      end
    end
  end
end
