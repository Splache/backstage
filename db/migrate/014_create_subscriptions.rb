class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column "recipient_id", :integer, :default => 0
      t.column "target_id", :integer, :default => 0

      t.timestamps
    end

    add_column "users", "send_report_every", :string, :limit => 250
    add_column "users", "time_zone", :string, :limit => 250
  end

  def self.down
    remove_column "users", "time_zone"
    remove_column "users", "send_report_every"

    drop_table :subscriptions
  end
end
