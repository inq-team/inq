class Testing < ActiveRecord::Base
	belongs_to :computer
	has_many :components
	has_many :testing_stages, :order => 'start'
	has_one :audit
	has_many :graphs
	belongs_to :profile

	def last_stage
		TestingStage.find_by_sql(["SELECT testing_stages.* FROM testing_stages WHERE testing_id = ? AND result <> 1 ORDER BY start DESC LIMIT 1", id]).first()
	end

	# Closes obviously hanging testing that are still shown as
	# running in database. Returns true if any changes to database
	# were done. 
	def close_hanging
		changed = false
		testing_stages.each { |ts|
			if ts.result == TestingStage::RUNNING or ts.end.nil?
				ts.result = TestingStage::HANGING
				ts.end = Time.new if ts.end.nil?
				ts.save!
				changed = true
			end
		}
		if changed
			self.test_end = Time.new if self.test_end.nil?
			save!
		end
		return changed
	end
end
