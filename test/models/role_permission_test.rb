require "test_helper"

class RolePermissionTest < ActiveSupport::TestCase
  test "should not save role permission without role and permission" do
    role_permission = RolePermission.new
    assert_not role_permission.save, "Saved the role permission without a role and permission"
  end

  test "should save role permission with valid role and permission" do
    role = Role.create(name: "Admin New")
    permission = Permission.create(name: "Read Users")
    role_permission = RolePermission.new(role: role, permission: permission)

    assert role_permission.save, "Failed to save the role permission with valid role and permission"
  end

  test "should not save duplicate role permission" do
    role = Role.create(name: "Admin")
    permission = Permission.create(name: "Manage Users")
    RolePermission.create(role: role, permission: permission)

    duplicate_role_permission = RolePermission.new(role: role, permission: permission)
    assert_not duplicate_role_permission.save, "Saved a duplicate role permission"
  end
end
