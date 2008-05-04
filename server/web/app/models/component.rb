class Component < ActiveRecord::Base
	belongs_to :model, :class_name => 'ComponentModel', :foreign_key => 'component_model_id'

	def===(other)
		self.component_model_id == other.component_model_id and self.serial == other.serial
	end
end
