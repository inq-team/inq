class ComputerStage < ActiveRecord::Base
        belongs_to :person, :class_name => 'Person', :foreign_key => 'person_id'

	include Timespans
end

