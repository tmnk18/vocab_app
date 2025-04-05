require "test_helper"

class WordEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get word_entries_index_url
    assert_response :success
  end

  test "should get new" do
    get word_entries_new_url
    assert_response :success
  end

  test "should get edit" do
    get word_entries_edit_url
    assert_response :success
  end
end
