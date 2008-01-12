class TestingStage < ActiveRecord::Base
	belongs_to :testing
	has_many :marks
end
