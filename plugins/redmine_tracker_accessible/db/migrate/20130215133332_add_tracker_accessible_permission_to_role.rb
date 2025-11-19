class AddTrackerAccessiblePermissionToRole < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :tracker_accessible_permission, :string
  end
end
