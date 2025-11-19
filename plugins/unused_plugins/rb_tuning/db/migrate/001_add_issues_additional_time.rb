class AddIssuesAdditionalTime < ActiveRecord::Migration[5.0]
  def up
    add_column :issues, :additional_time, :float
    add_column :issues, :planned_date, :date
    add_column :issues, :deadline_changed, :datetime
  end

  def down
    remove_column :issues, :additional_time
    remove_column :issues, :planned_date
    remove_column :issues, :deadline_changed
  end
end
