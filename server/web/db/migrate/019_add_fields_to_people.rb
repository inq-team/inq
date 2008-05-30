class AddFieldsToPeople < ActiveRecord::Migration
	def self.up
#		add_column :people, :login,                     :string
		add_column :people, :email,                     :string
		add_column :people, :display_name,              :string
		add_column :people, :given_name,                :string
		add_column :people, :last_login_at,             :datetime
		add_column :people, :created_at,                :datetime
		add_column :people, :updated_at,                :datetime
	end

	def self.down
#		remove_column :people, :login
		remove_column :people, :email
		remove_column :people, :display_name
		remove_column :people, :given_name
		remove_column :people, :last_login_at
		remove_column :people, :created_at
		remove_column :people, :updated_at
	end
end
