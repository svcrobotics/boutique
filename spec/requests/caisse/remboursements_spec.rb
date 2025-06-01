require 'rails_helper'

RSpec.describe "Caisse::Remboursements", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/caisse/remboursements/index"
      expect(response).to have_http_status(:success)
    end
  end

end
