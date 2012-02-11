class CreateCodeMethods < ActiveRecord::Migration
  def self.up
    create_table :code_methods do |t|
      t.column "code_file_id", :integer, :null => false, :default => 0
      t.column "name", :string, :null => false
      t.column "nature", :string
      t.column "description", :text

      t.timestamps
    end
  end

  def self.down
    drop_table :code_methods
  end
end
