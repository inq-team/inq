class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :customer
	belongs_to :assembler, :class_name => 'Person', :foreign_key => 'assembler_id'
	belongs_to :tester, :class_name => 'Person', :foreign_key => 'tester_id'
	has_many :testings

	def serial_no
		sprintf "%010d", id
	end

	def title
		model.name + ' ' + serial_no
	end

	def self.find_by_hw_serials(serials)
		param1 = serials.sort() { |a,b| a <=> b }
		self.find_by_sql(["SELECT DISTINCT computers.*, group_concat(hw_serial ORDER BY hw_serial SEPARATOR ',') AS serials  FROM `computers` JOIN `testings` on testings.computer_id = computers.id JOIN `components` ON components.testing_id = testings.id JOIN component_models ON components.component_model_id = component_models.id JOIN component_groups ON component_models.component_group_id = component_groups.id AND component_groups.name in ('LAN', 'NIC') GROUP BY testings.id HAVING serials = ?", param1.join(',')])
	end
end
