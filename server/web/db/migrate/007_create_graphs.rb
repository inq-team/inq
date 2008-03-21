class CreateGraphs < ActiveRecord::Migration
	def self.up
#		create_table :graphs do |t|
#			t.integer :testing_id
#			t.integer :monitoring_id
#			t.datetime :timestamp
#			t.integer :key
#			t.float :value
#		end
	end

	def self.down
		drop_table :graphs
	end
end
