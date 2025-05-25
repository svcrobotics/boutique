require 'rails_helper'

RSpec.describe "Avoirs", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/avoirs/show"
      expect(response).to have_http_status(:success)
    end
  end

end
