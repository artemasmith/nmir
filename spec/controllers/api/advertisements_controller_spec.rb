require 'rails_helper'
RSpec.describe Api::AdvertisementsController, :type => :controller do
  describe "GET 'show'" do
    it "returns http success" do
      sign_in
      @adv = create :advertisement
      xhr :get, :show, :id => @adv.id
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.body).to eq({name: @adv.name, phone: @adv.phone}.to_json)
    end
  end
end
