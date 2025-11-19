class AddWriteoffColumnToIssuesTable < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    add_column :trackers, :writeoff_f, :boolean ,:default => false, :null => false
  end

  def self.down
    remove_column :trackers, :writeoff_f
  end
end