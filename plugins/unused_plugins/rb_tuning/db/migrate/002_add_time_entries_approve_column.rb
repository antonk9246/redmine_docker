class AddTimeEntriesApproveColumn < ActiveRecord::Migration[5.0]
  def up
    add_column :time_entries, :approve, :boolean, :default => false
  end

  def down
    remove_column :time_entries, :approve
  end
end
