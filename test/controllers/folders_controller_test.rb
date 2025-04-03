require "test_helper"

class FoldersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get folders_index_url
    assert_response :success
  end
end
