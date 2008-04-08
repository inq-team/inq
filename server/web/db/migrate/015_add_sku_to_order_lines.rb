class AddSkuToOrderLines < ActiveRecord::Migration
	def self.up
		add_column(:order_lines, :sku, :string, :null => true, :limit => 96)
	end
	
	def self.down
		remove_column(:order_lines, :sku)
	end
end
