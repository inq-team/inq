class AddFieldsToPeople2 < ActiveRecord::Migration
	def self.up
		add_column :people, :remember_token_expires_at, :datetime
		add_column :people, :remember_token,            :string
	end

	def self.down
		remove_column :people, :remember_token_expires_at
		remove_column :people, :remember_token
	end
end
