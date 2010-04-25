class CreateCodeFiles < ActiveRecord::Migration
	def self.up
		create_table :code_files do |t|
			t.column "name", :string, :null => false
			t.column "path", :string
			t.column "description", :text
	
      t.timestamps
		end
	end
	
	def self.down
		drop_table :code_files
	end
end
