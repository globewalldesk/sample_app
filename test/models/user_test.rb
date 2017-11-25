require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "Foobar1", password_confirmation: "Foobar1")
  end

  test "should be valid" do
    assert @user.valid?
  end

  
  # name tests ##########################################

  test "name should not be too long" do
    @user.name = "a" * 51
    refute @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end
  
  
  # email tests ##########################################
  
  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    refute @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice_bob@baz.cn)
    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "emails should be downcased before saving" do
    mixed_case_email = "IamUPPERandlower@gmail.COM"
    @user.email = mixed_case_email
    @user.save
    assert_equal @user.reload.email, mixed_case_email.downcase 
  end

  # password tests ##########################################
  
  test "passwords should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?, "password is too short"
  end

  test "passwords should include num and lc and uc letters" do
    @user.password = @user.password_confirmation = "abcdef"
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "Abcdef"
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "abcdef5"
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "Abcdef5"
    assert @user.valid?
  end
  
  # micropost tests ######################################################
  
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  # following and feed tests #############################################

  test "should follow and unfollow a user" do
    god = users(:god)
    archer = users(:archer)
    assert_not god.following?(archer)
    god.follow(archer)
    assert god.following?(archer)
    assert archer.followers(god)
    god.unfollow(archer)
    assert_not god.following?(archer)
  end

  test "feed should have the right posts" do
    god = users(:god)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user should be included
    lana.microposts.each do |post_following|
      assert god.feed.include?(post_following)
    end
    # Posts from self should be included
    god.microposts.each do |post_self|
      assert god.feed.include?(post_self)
    end
    # Posts from unfollowed user NOT included
    archer.microposts.each do |post_unfollowed|
      assert_not god.feed.include?(post_unfollowed)
    end
  end


  # other tests #############################################
  
  # Subtle issue: if a user logs out in Chrome but not in Firefox, he would
  # have no remember digest in the database, which would mean he'd be logged
  # in but not authenticated. That's not how it should work; he should be
  # logged out in absence of a remember digest.
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

end
