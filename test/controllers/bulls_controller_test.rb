require "test_helper"

class BullsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bull = bulls(:one)
  end

  test "should get index" do
    get bulls_url
    assert_response :success
  end

  test "should get new" do
    get new_bull_url
    assert_response :success
  end

  test "should create bull" do
    assert_difference("Bull.count") do
      post bulls_url, params: { bull: { born_on: @bull.born_on, name: @bull.name, offspring_count: @bull.offspring_count } }
    end

    assert_redirected_to bull_url(Bull.last)
  end

  test "should show bull" do
    get bull_url(@bull)
    assert_response :success
  end

  test "should get edit" do
    get edit_bull_url(@bull)
    assert_response :success
  end

  test "should update bull" do
    patch bull_url(@bull), params: { bull: { born_on: @bull.born_on, name: @bull.name, offspring_count: @bull.offspring_count } }
    assert_redirected_to bull_url(@bull)
  end

  test "should destroy bull" do
    assert_difference("Bull.count", -1) do
      delete bull_url(@bull)
    end

    assert_redirected_to bulls_url
  end
end
