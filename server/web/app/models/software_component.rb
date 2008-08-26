class SoftwareComponent < ActiveRecord::Base
	belongs_to :model, :class_name => 'SoftwareComponentModel', :foreign_key => 'software_component_model_id'
end
