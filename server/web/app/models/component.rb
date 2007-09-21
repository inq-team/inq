class Component < ActiveRecord::Base
	belongs_to :model, :class_name => 'ComponentModel', :foreign_key => 'component_model_id'
end
