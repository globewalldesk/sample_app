require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  
  def setup
    @common_title = "Ruby on Rails Tutorial Sample App"
  end
  
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Home | #{@common_title}"
    assert_select "div.container"             # I added this, not in tutorial  
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | #{@common_title}"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | #{@common_title}"
  end

  test "should get contact" do
    get :contact
    assert_response :success
    assert_select "title", "Contact | #{@common_title}"
  end
  
end
