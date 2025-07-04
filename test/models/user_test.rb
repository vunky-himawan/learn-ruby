require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    role = Role.create(name: "Admin")
    user = User.new(password_digest: "password", role_id: role.id)
    assert_not user.save, "Saved the user without an email"
  end

  test "should not save user without password" do
    role = Role.create(name: "Admin")
    user = User.new(email: "user@example.com", role_id: role.id)
    assert_not user.save, "Saved the user without a password"
  end

  test "should not save user with short password" do
    role = Role.create(name: "Admin")
    user = User.new(email: "user@example.com", password_digest: "short", role_id: role.id)
    assert_not user.save, "Saved the user with a short password"
  end

  test "should not save user without role" do
    user = User.new(email: "user@example.com", password_digest: "password")
    assert_not user.save, "Saved the user without a role"
  end

  test "should save user with valid attributes" do
    role = Role.create(name: "Admin New")
    user = User.new(email: "user@example.com", password_digest: "password", role_id: role.id)
    assert user.save, "Failed to save the user with valid attributes"
  end

  test "should not save user with duplicate email" do
    role = Role.create(name: "Admin")
    User.create(email: "user@example.com", password_digest: "password", role_id: role.id)
    user = User.new(email: "user@example.com", password_digest: "password", role_id: role.id)
    assert_not user.save, "Saved the user with a duplicate email"
  end

  test "should not save user with invalid role" do
    user = User.new(email: "user@example.com", password_digest: "password", role_id: 5)
    assert_not user.save, "Saved the user with an invalid role"
  end

  test "should soft delete user" do
    role = Role.create(name: "Admin New")
    user = User.create(email: "user@example.com", password_digest: "password", role_id: role.id)
    assert user.soft_delete, "Failed to soft delete the user"
  end

  test "should restore soft deleted user" do
    role = Role.create(name: "Admin New")
    user = User.create(email: "user@example.com", password_digest: "password", role_id: role.id)
    user.soft_delete
    assert user.restore, "Failed to restore the soft deleted user"
  end
end
