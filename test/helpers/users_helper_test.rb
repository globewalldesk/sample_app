require 'test_helper'

class UsersHelperTest < ActionView::TestCase

  test "tosses dups" do
    messages = ["Foo", "Foo", "Bar"]
    assert_equal(massage_error_messages(messages).length, 2)
  end
  
end
