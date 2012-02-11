class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.column "project_id", :integer, :default => 0
      t.column "name", :string, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :collections
  end
end
