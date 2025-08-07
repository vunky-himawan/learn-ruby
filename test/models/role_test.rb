require "test_helper"

class RoleTest < ActiveSupport::TestCase
  def setup
    @role = Role.new(name: "Admin")
  end

  test "should be valid with a name" do
    assert @role.valid?
  end

  test "should not be valid without a name" do
    @role.name = nil
    assert_not @role.valid?
  end

  test "should not be valid with a duplicate name" do
    @role.save
    duplicate_role = Role.new(name: "Admin")
    assert_not duplicate_role.valid?
  end

  test "should have a unique name" do
    @role.save
    another_role = Role.new(name: "Auditor")
    assert another_role.valid?
  end
end
