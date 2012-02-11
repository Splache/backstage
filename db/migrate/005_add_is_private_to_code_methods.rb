class AddIsPrivateToCodeMethods < ActiveRecord::Migration
  def self.up
    add_column "code_methods", "is_private", :boolean, :default => false
  end

  def self.down
    remove_column "code_methods", "is_private"
  end
end
