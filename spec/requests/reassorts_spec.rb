require 'rails_helper'

RSpec.describe "Reassorts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/reassorts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/reassorts/create"
      expect(response).to have_http_status(:success)
    end
  end

end
