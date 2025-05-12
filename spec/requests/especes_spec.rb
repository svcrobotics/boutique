require 'rails_helper'

RSpec.describe "Especes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/especes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/especes/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/especes/create"
      expect(response).to have_http_status(:success)
    end
  end

end
