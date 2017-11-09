require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:god)
    @non_admin = users(:archer)
  end
  
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete',
                                                    method: :delete
      end
    end
    assert_difference('User.count', -1) do
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admin" do 
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "unactivated users don't show up in users/ list" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: @admin.name, count: 1 # Activated account seen.
    assert_select 'a', text: @non_admin.name, count: 1 # Activated account seen.
    @non_admin.update_attribute(:activated, false)
    log_in_as(@admin) # If user isn't activated, user can't see this page.
    get users_path
    assert_select 'a', text: @non_admin.name, count: 0  # But not inactivated.
  end
  
end
