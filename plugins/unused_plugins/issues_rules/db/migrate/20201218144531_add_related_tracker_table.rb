class AddRelatedTrackerTable < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    create_table :related_trackers, :force => true do |t|
      t.column "parent_id", :integer
      t.column "child_id", :integer
    end
  end

  def self.down
    drop_table :related_trackers 
  end
end