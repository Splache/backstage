class AddParametersToCodeMethods < ActiveRecord::Migration
	def self.up
		add_column "code_methods", "parameters", :text
	end
	
	def self.down
	  remove_column "code_methods", "parameters"
	end
end
