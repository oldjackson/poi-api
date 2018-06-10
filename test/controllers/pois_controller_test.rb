require 'test_helper'

class PoisControllerTest < ActionDispatch::IntegrationTest
  test "should get museums" do
    get pois_museums_url
    assert_response :success
  end
end
