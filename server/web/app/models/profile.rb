class Profile < ActiveRecord::Base
	belongs_to :model
	belongs_to :computer	
end
