class TestingStage < ActiveRecord::Base
	belongs_to :testing
	has_many :marks

	RUNNING = 0
	FINISHED = 1
	FAILED = 2
	HANGING = 3
	ATTENTION = 4
	MAYHANG = 5
end
