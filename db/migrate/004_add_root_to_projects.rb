class AddRootToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "root", :string, :limit => 255
  end

  def self.down
    remove_column "projects", "root"
  end
end
