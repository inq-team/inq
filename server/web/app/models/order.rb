class Order < ActiveRecord::Base
	has_many :order_lines
	belongs_to :manager, :class_name => 'Person', :foreign_key => 'manager_id'

	def update_order(attr)
		order_lines = attr[:order_lines]
		attr.delete(:order_lines)
		p order_lines
		update_attributes(attr)
	end
end
