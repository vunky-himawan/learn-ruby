require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @role = Role.create(name: "Admin")
    @user = User.new(email: "admin@example.com", password: "password", password_confirmation: "password", role: @role, name: "Admin User")
  end

  test "should be valid with a name" do
    assert @user.valid?
  end

  test "should be invalid without a name" do
    @user.name = nil
    assert_not @user.valid?
  end

  test "should be invalid without an email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should be invalid without a role" do
    @user.role = nil
    assert_not @user.valid?
  end

  test "should be invalid with a duplicate email" do
    @user.save
    duplicate_user = User.new(email: "admin@example.com", password: "password", password_confirmation: "password", role: @role, name: "Admin User")
    assert_not duplicate_user.valid?
  end
end
