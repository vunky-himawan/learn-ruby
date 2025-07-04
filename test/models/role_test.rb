require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "should not save role without name" do
    role = Role.new
    assert_not role.save, "Saved the role without a name"
  end

  test "should save role with valid name" do
    role = Role.new(name: "Admin New")
    assert role.save, "Failed to save the role with a valid name"
  end

  test "should not save role with duplicate name" do
    Role.create(name: "Admin New")
    role = Role.new(name: "Admin New")
    assert_not role.save, "Saved the role with a duplicate name"
  end

  test "should soft delete role" do
    role = Role.create(name: "Admin New")
    assert role.soft_delete, "Failed to soft delete the role"
  end

  test "should restore soft deleted role" do
    role = Role.create(name: "Admin New")
    role.soft_delete
    assert role.restore, "Failed to restore the soft deleted role"
  end

  test "should have many users" do
    role = Role.create(name: "Admin New")
    user1 = User.create(email: "user3@example.com", password_digest: "password", role_id: role.id)
    user2 = User.create(email: "user4@example.com", password_digest: "password", role_id: role.id)
    assert role.users.include?(user1), "Role does not include user1"
    assert role.users.include?(user2), "Role does not include user2"
  end

  test "should have many permissions through role_has_permissions" do
    role = Role.create(name: "Admin New")
    permission1 = Permission.create(name: "read")
    permission2 = Permission.create(name: "write")
    RolePermission.create(role_id: role.id, permission_id: permission1.id)
    RolePermission.create(role_id: role.id, permission_id: permission2.id)

    assert role.permissions.include?(permission1), "Role does not include permission1"
    assert role.permissions.include?(permission2), "Role does not include permission2"
  end
end
