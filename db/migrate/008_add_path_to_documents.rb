class AddPathToDocuments < ActiveRecord::Migration
	def self.up
		add_column "documents", "path", :string, :limit => 250
	end

	def self.down
	  remove_column "documents", "path"
	end
end
