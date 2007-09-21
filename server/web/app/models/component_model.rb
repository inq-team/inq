class ComponentModel < ActiveRecord::Base
	belongs_to :group, :class_name => 'ComponentGroup', :foreign_key => 'component_group_id'
end
