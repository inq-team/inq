class SoftwareComponentModel < ActiveRecord::Base
	belongs_to :architecture, :class_name => 'SoftwareComponentArchitecture', :foreign_key => 'software_component_architecture_id'
end
