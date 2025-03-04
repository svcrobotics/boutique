require "test_helper"

class TextesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get textes_show_url
    assert_response :success
  end
end
