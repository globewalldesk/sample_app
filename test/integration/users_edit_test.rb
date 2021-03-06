require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:god)
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), user: { name: "",
                                    email: "foo@invalid",
                                    password: "foo",
                                    password_confirmation: "bar" }
    assert_template "users/edit"
  end
 
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_not_nil session[:forwarding_url] # Yes, there is a forwarding url.
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert_nil session[:forwarding_url] # Now the forwarding url is gone.
    name  = "Fester Bestertester"
    email = "fester@tester.com"
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    password: "Festerfoo1",
                                    password_confirmation: "Festerfoo1" }
    assert flash[:success]
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name,  name
    assert_equal @user.email, email
  end
 
end
