require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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
  
  test "valid input creates user" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Example User",
                                            email: "user@example.com",
                                            password:              "Password9",
                                            password_confirmation: "Password9" }
    end
    assert_template 'users/show' # Asserts that show.html.erb is rendered
                                 # after following the redirect.
  end
  
  test "flash messages appear as expected" do
    get signup_path
    post_via_redirect users_path, user: { name: "Foo Bar", email: "good@ex.com",
                                          password: "FooB4rry", 
                                          password_confirmation: "FooB4rry" }
    assert_select "div.alert"
    assert_select "div.alert-success"
    assert "div.alert-success", "Welcome to the Sample App!"
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
