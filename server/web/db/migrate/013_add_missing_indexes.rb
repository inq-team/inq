class AddMissingIndexes < ActiveRecord::Migration
	def self.up
		add_index 'computers', ['model_id'], :name => 'model_id'
		add_index 'components', ['testing_id'], :name => 'testing_id'
		add_index 'components', ['component_model_id'], :name => 'component_model_id'
		add_index 'marks', ['testing_stage_id'], :name => 'testing_stage_id'
		add_index 'orders', ['buyer_order_number'], :name => 'buyer_order_number'
	end
	
	def self.down
		remove_index 'computers', :name => 'model_id'
		remove_index 'components', :name => 'testing_id'
		remove_index 'components', :name => 'component_model_id'
		remove_index 'marks', :name => 'testing_stage_id'
		remove_index 'orders', :name => 'buyer_order_number'
	end
end
