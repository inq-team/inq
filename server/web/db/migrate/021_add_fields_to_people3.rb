class AddFieldsToPeople3 < ActiveRecord::Migration
	def self.up
		add_column :people, :is_admin,    :boolean, :default => false
		add_column :people, :recent_days, :integer, :default => 3
	end

	def self.down
		remove_column :people, :is_admin
		remove_column :people, :recent_days
	end
end
