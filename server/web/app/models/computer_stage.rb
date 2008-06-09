class ComputerStage < ActiveRecord::Base
	belongs_to :person, :class_name => 'Person', :foreign_key => 'person_id'
	belongs_to :comment_by, :class_name => 'Person', :foreign_key => 'comment_by'

	include Timespans
end
