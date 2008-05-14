class AddCodeToOrder < ActiveRecord::Migration
	def self.up
		add_column :orders, :code, :string, :limit => 16
	end

	def self.down
		remove_column :orders, :code
	end
end
