class Profile < ActiveRecord::Base
	belongs_to :model
	
	def name
		res = ''
		res << "#{model.name}: " if model_id
		res << if feature then feature else 'default' end
		res << " (#{timestamp.strftime('%Y-%m-%d')})"
	end

	def self.list_for_model(model_id)
		r1 = find(
			:all,
			:conditions => ['model_id IS NULL OR model_id=?', model_id],
			:include => :model,
			:order => 'model_id DESC, feature, timestamp DESC'
		)
		r2 = []
		last_feature = last_model_id = nil
		r1.each { |x|
			r2 << x if x.feature != last_feature or x.model_id != last_model_id
			last_feature = x.feature
			last_model_id = x.model_id
		}
		return r2
	end
end
