class CreateProjects < ActiveRecord::Migration
	def self.up
		create_table :projects do |t|
			t.column "name", :string, :null => false
			t.column "description", :text
	
      t.timestamps
		end
		
		add_column "code_files", "project_id", :integer, :default => 0
	end
	
	def self.down
	  remove_column "code_files", "project_id"
		drop_table :projects
	end
end
