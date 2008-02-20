class Audit < ActiveRecord::Base
	belongs_to :person
	belongs_to :testing	
end
