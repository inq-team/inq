class Mark < ActiveRecord::Base
	belongs_to :testing_stage
	
	def self.by_testing(testing_id)
		Mark.find_by_sql(
			["SELECT m.* FROM marks m
INNER JOIN testing_stages ts ON m.testing_stage_id=ts.id
INNER JOIN testings t ON ts.testing_id=t.id
WHERE t.id=?
ORDER BY ts.start", testing_id]
		)
	end
end
