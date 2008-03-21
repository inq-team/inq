class AddManagerToOrder < ActiveRecord::Migration
	def self.up
		add_column(:orders, :manager, :string, :null => true, :limit => 96)
		add_index 'orders', ['manager'], :name => 'manager'
	end
	
	def self.down
		remove_column(:orders, :manager)
	end
end
