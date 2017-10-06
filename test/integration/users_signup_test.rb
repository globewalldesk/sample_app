require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    # Since deliveries is a global, clear this first!
    ActionMailer::Base.deliveries.clear
  end

  test "invalid input does not create user" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path,  user: { name: "Foo Bar", email: "bad@ema%@il",
                                password: "yucky", 
                                password_confirmation: "fooey" }
    end
    assert_template "users/new"
    assert_template "shared/_error_messages" # test that the error_messages show up
  end
  
  test "valid signup info with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name:                  "Example User",
                               email:                 "user@example.com",
                               password:              "Password9",
                               password_confirmation: "Password9" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    assert_not_nil flash[:danger]
    # Invalid activation token.
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    assert_not_nil flash[:danger]
    # Valid token, wrong email.
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    assert_not_nil flash[:danger]
    # Valid token, right email!
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not_nil flash[:success]
  end
  
  test "flash messages appear as expected" do
    get signup_path
    post_via_redirect users_path, user: { name: "Foo Bar", email: "good@ex.com",
                                          password: "FooB4rry", 
                                          password_confirmation: "FooB4rry" }
    assert_select "div.alert"
    assert_select "div.alert-info"
    post_via_redirect users_path, user: { name: "Foo Bar", email: "bad@ema%@il",
                                          password: "FooB4rry", 
                                          password_confirmation: "FooB4rry" }
    assert_select "li", "Email is invalid."
    assert_select "div.alert"
    assert_select "div.alert-danger"
    post_via_redirect users_path, user: { name: "", email: "good@example.com",
                                          password: "FooB4rry", 
                                          password_confirmation: "FooB4rry" }
    assert_select "li", "Name can't be blank."
    assert_select "div.alert"
    assert_select "div.alert-danger"
    post_via_redirect users_path, user: { name: "L S", email: "good@example.com",
                                          password: "FooB4rry", 
                                          password_confirmation: "FooBarry" }
    assert_select "li", "Password confirmation doesn't match Password."
    assert_select "div.alert"
    assert_select "div.alert-danger"
  end

end
