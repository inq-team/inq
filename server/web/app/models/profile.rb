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
			:conditions => ['(model_id IS NULL OR model_id=?) AND is_deleted=0', model_id],
			:include => :model,
			:order => 'model_id DESC, feature, timestamp DESC'
		)
		return r1 if r1.empty?
		r2 = [r1.shift]
		last_feature = r2[0].feature
		last_model_id = r2[0].model_id
		r1.each { |x|
			r2 << x if x.feature != last_feature or x.model_id != last_model_id
			last_feature = x.feature
			last_model_id = x.model_id
		}
		return r2
	end

	def deleted?
		is_deleted
	end
end
