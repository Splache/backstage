class AddRsdeToTasks < ActiveRecord::Migration
	def self.up
		add_column "tasks", "rsde_obstacles", :text
		add_column "tasks", "rsde_work", :text
	end
	
	def self.down
	  remove_column "tasks", "rsde_work"
	  remove_column "tasks", "rsde_obstacles"
	end
end
