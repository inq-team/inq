class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :customer
	belongs_to :assembler, :class_name => 'Person', :foreign_key => 'assembler_id'
	belongs_to :tester, :class_name => 'Person', :foreign_key => 'tester_id'
	has_many :testings

	def title
		sprintf "%s %010d", model.name, serial_no
	end

	def self.find_by_hw_serials(serials)
		param1 = serials.sort() { |a,b| a <=> b }
		Computer.find_by_sql(["SELECT DISTINCT computers.id as comp_id, group_concat(hw_serial ORDER BY hw_serial SEPARATOR ',') AS serials  FROM `computers` JOIN `testings` on testings.computer_id = computers.id JOIN `components` ON components.testing_id = testings.id WHERE hw_serial in (?) GROUP BY testings.id HAVING serials = ?", param1, param1.join(',')])
	end
end
