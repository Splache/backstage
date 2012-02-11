class CreateTasks < ActiveRecord::Migration
	def self.up
		create_table :tasks do |t|
		  t.column "project_id", :integer, :default => 0
		  t.column "created_by", :integer, :null => false
		  t.column "assigned_to", :integer, :default => 0
		  t.column "collection_id", :integer, :default => 0
			t.column "identifier_no", :integer, :default => 0
			t.column "name", :string, :null => false
			t.column "description", :text
			t.column "nature", :string
			t.column "priority", :integer, :default => 0
	    t.column "hours_estimated", :integer
	    t.column "hours_actual", :integer
	    t.column "due_on", :date
	    t.column "started_on", :date
	    t.column "ended_on", :date

      t.timestamps
		end
	end

	def self.down
		drop_table :tasks
	end
end
