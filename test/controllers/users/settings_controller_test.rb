require "test_helper"

class Users::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get users_settings_show_url
    assert_response :success
  end
end
