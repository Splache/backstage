class AddStepToTasks < ActiveRecord::Migration
	def self.up
		add_column "tasks", "step", :string, :limit => 50
	end
	
	def self.down
	  remove_column "tasks", "step"
	end
end
