class OrderStages < ActiveRecord::Migration
	def self.up
		add_index "order_stages", ["order_id"], :name => "order_id"
	end
	
	def self.down
		remove_index 'order_stages', :name => 'order_id'
	end
end
