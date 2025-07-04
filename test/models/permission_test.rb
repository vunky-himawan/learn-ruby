require "test_helper"

class PermissionTest < ActiveSupport::TestCase
  test "should not save permission without name" do
    permission = Permission.new
    assert_not permission.save, "Saved the permission without a name"
  end

  test "should save permission with valid name" do
    permission = Permission.new(name: "read")
    assert permission.save, "Failed to save the permission with a valid name"
  end

  test "should not save permission with duplicate name" do
    Permission.create(name: "read")
    permission = Permission.new(name: "read")
    assert_not permission.save, "Saved the permission with a duplicate name"
  end

  test "should have many roles through role_permissions" do
    role = Role.create(name: "Admin New")
    permission = Permission.create(name: "read")
    RolePermission.create(role_id: role.id, permission_id: permission.id)

    assert_includes permission.roles, role, "Permission does not include the role"
  end
end
