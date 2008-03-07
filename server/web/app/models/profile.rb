class Profile < ActiveRecord::Base
	belongs_to :model
	
	def name
		res = ''
		res << "#{model.name}: " if model_id
		res << if feature then feature else 'default' end
		res << " (#{timestamp})"
	end
end
