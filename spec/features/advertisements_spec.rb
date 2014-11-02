require 'rails_helper'
require 'spec_helper'

describe "Advertisement scope" do
  before do
    @user = FactoryGirl.create(:user, role: :admin, email: 'example@user.com')
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Пароль', with: @user.password
    click_button 'Войти'
  end
  describe "creation process" do
    describe "success creation" do
      it 'test' do
        pending 'should check email - capybara cant fill in email (2 elements with that name)'
        visit '/'
        click_button 'Добавить'
        fill_in 'Имя', with: 'Test user'
        fill_in 'Телефон', with: '23122333'
        click_button 'Агент'
        click_button 'Далее'
        click_button 'Выбрать'
        click_button 'Тюменская область'
        click_button 'Тюмень'
        click_button 'Центр'
        fill_in 'Этаж', with: 1
        fill_in 'Этажность', with: 5
        fill_in 'Площадь', with: 50
        fill_in 'Количество комнат', with: 3
        fill_in 'Цена', with: 300000
        fill_in 'Комментарий', with: 'hello guys do you want to'
        click_button 'Создать'
      end
    end
  end
end
