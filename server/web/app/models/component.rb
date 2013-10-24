class Component < ActiveRecord::Base
	belongs_to :model, :class_name => 'ComponentModel', :foreign_key => 'component_model_id'

	def===(other)
		self.component_model_id == other.component_model_id and self.serial == other.serial
	end

	def self.by_params(params)
		Component.new(
			:serial => params[:serial],
			:version => params[:version],
			:model => ComponentModel.find_or_create_by_name_and_vendor_and_component_group_id(params[:model], params[:vendor], ComponentGroup.find_or_create_by_name(params[:type]).id)
		)
	end
end
