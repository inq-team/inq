class ComputerStages < ActiveRecord::Migration
	def self.up
		add_index "computer_stages", ["computer_id"], :name => "computer_id"
	end
	
	def self.down
		remove_index("computer_stages", "computer_id")
	end
end
