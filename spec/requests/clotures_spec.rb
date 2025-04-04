require 'rails_helper'

RSpec.describe "Clotures", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/clotures/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/clotures/create"
      expect(response).to have_http_status(:success)
    end
  end

end
