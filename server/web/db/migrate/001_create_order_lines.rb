class CreateOrderLines < ActiveRecord::Migration
	def self.up
		create_table :order_lines do |t|
			t.column 'order_id', :integer, :null => false
			t.column 'name',     :string,  :null => false, :limit => 250
			t.column 'qty',      :integer, :null => false
		end
	end

	def self.down
		drop_table :order_lines
	end
end
