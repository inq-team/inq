class BindProfilesToComputers < ActiveRecord::Migration
	def self.up
		add_column(:computers, :profile_id, :int)
	end

	def self.down
		remove_column(:computers, :profile_id)
	end
end
