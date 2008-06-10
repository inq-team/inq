class OrderStage < ActiveRecord::Base
	belongs_to :order
	belongs_to :person
	belongs_to :comment_by, :class_name => 'Person', :foreign_key => 'comment_by'

	include Timespans
end
