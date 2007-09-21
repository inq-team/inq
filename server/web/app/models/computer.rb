class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :customer
	belongs_to :assembler, :class_name => 'Person', :foreign_key => 'assembler_id'
	belongs_to :tester, :class_name => 'Person', :foreign_key => 'tester_id'
	has_many :testings

	def title
		sprintf "%s %010d", model.name, serial_no
	end
end
