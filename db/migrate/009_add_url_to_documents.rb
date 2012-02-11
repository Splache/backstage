class AddUrlToDocuments < ActiveRecord::Migration
	def self.up
		add_column "documents", "url", :string, :limit => 250
	end

	def self.down
	  remove_column "documents", "url"
	end
end
