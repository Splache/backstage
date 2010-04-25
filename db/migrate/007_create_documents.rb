class CreateDocuments < ActiveRecord::Migration
	def self.up
		create_table :documents do |t|
			t.column "project_id", :integer, :default => 0
			t.column "name", :string, :null => false
			t.column "description", :text
	
      t.timestamps
		end
	end
	
	def self.down
		drop_table :documents
	end
end
