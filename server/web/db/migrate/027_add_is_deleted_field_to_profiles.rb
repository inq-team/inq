class AddIsDeletedFieldToProfiles < ActiveRecord::Migration
	def self.up
		add_column :profiles, :is_deleted, :boolean, :default => false
	end
	def self.down
		remove_column :profiles, :is_deleted
	end
end
