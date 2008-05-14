class AddAccumulatedIdleToTestingStage < ActiveRecord::Migration
	def self.up
		add_column :testing_stages, :accumulated_idle, :float, :default => 0, :null => false
	end

	def self.down
		remove_column :testing_stages, :accumulated_idle
	end
end
