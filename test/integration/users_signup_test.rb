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
  
end
