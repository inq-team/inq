class Testing < ActiveRecord::Base
	belongs_to :computer
	has_many :components
	has_many :testing_stages

	def last_stage
		TestingStage.find_by_sql(["SELECT testing_stages.* FROM testing_stages WHERE testing_id = ? ORDER BY start DESC LIMIT 1", id]).first()
	end
end
