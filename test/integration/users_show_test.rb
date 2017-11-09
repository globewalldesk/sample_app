require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:god)
    @non_admin = users(:archer)
  end
    
  test "should not show user/<id> if user is not activated" do
    @non_admin.update_attribute(:activated, false)
    log_in_as(@admin)
    get user_path(@non_admin)
    assert_redirected_to root_url
    assert flash[:danger]
  end

end