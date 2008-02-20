class Testing < ActiveRecord::Base
	belongs_to :computer
	has_many :components
	has_many :testing_stages
	has_one :audit

	def last_stage
		TestingStage.find_by_sql(["SELECT testing_stages.* FROM testing_stages WHERE testing_id = ? AND result <> 1 ORDER BY start DESC LIMIT 1", id]).first()
	end
end
