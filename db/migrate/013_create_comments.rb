class CreateComments < ActiveRecord::Migration
	def self.up
		create_table :comments do |t|
		  t.column "task_id", :integer, :default => 0
		  t.column "user_id", :integer, :default => 0
			t.column "description", :text
	    
      t.timestamps
		end
	end
	
	def self.down
		drop_table :comments
	end
end
