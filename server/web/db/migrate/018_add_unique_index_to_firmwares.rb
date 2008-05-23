class AddUniqueIndexToFirmwares < ActiveRecord::Migration
	def self.up
		add_index 'firmwares', ['component_model_id'], :unique => true
	end

	def self.down
		remove_index 'firmwares', :unique => true
	end
end
