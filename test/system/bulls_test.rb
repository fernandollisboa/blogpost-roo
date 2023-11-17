require "application_system_test_case"

class BullsTest < ApplicationSystemTestCase
  setup do
    @bull = bulls(:one)
  end

  test "visiting the index" do
    visit bulls_url
    assert_selector "h1", text: "Bulls"
  end

  test "should create bull" do
    visit bulls_url
    click_on "New bull"

    fill_in "Born on", with: @bull.born_on
    fill_in "Name", with: @bull.name
    fill_in "Offspring count", with: @bull.offspring_count
    click_on "Create Bull"

    assert_text "Bull was successfully created"
    click_on "Back"
  end

  test "should update Bull" do
    visit bull_url(@bull)
    click_on "Edit this bull", match: :first

    fill_in "Born on", with: @bull.born_on
    fill_in "Name", with: @bull.name
    fill_in "Offspring count", with: @bull.offspring_count
    click_on "Update Bull"

    assert_text "Bull was successfully updated"
    click_on "Back"
  end

  test "should destroy Bull" do
    visit bull_url(@bull)
    click_on "Destroy this bull", match: :first

    assert_text "Bull was successfully destroyed"
  end
end
