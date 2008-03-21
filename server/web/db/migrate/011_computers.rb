class Computers < ActiveRecord::Migration
	def self.up
		add_index "computers", ["order_id"], :name => "order_id"
	end
	
	def self.down
		remove_index 'computers', :name => 'order_id'
	end
end
