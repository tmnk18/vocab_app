require "test_helper"

class ExtractionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get extractions_new_url
    assert_response :success
  end
end
