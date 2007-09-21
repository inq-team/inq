class Testing < ActiveRecord::Base
	belongs_to :computer
	has_many :components
	has_many :testing_stages
end
