require 'rails_helper'

describe 'as a registered user' do
  xit 'can log out as a user' do
    user = FactoryBot.create(:user)

    visit login_path

    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_on 'Log In'

    click_on 'Log Out'

    within ".flash-flex" do
      expect(page).to have_content("You are logged out.")
    end
    expect(user.cart.empty?).to eq(true)
  end

  xit 'can log out as a admin' do
    admin = FactoryBot.create(:admin)

    visit login_path

    fill_in :email, with: admin.email
    fill_in :password, with: admin.password
    click_on 'Log In'
    click_on 'Log Out'

    within ".flash-flex" do
      expect(page).to have_content("You are logged out.")
    end

    expect(user.cart.empty?).to eq(true)
  end

  xit 'can log out as a merchant' do
    merchant = FactoryBot.create(:merchant)

    visit login_path

    fill_in :email, with: merchant.email
    fill_in :password, with: merchant.password
    click_on 'Log In'
    click_on 'Log Out'

    within ".flash-flex" do
      expect(page).to have_content("You are logged out.")
    end

    expect(user.cart.empty?).to eq(true)
  end
end