class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.column 'login', :string, :limit => 50, :null => false, :unique => true
			t.column 'hashed_password', :string, :limit => 50, :null => false
			t.column 'salt', :string, :null => false
			t.column 'last_name', :string
			t.column 'first_name', :string
			t.column 'email', :string, :null => false, :unique => true

      t.timestamps
		end
	end

	def self.down
		drop_table :users
	end
end
