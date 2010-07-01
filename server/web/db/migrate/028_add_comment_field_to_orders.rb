class AddCommentFieldToOrders < ActiveRecord::Migration
	def self.up
		add_column :orders, :comment, :text
	end
	def self.down
		remove_column :orders, :comment
	end
end
