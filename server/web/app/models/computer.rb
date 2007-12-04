class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :customer
	belongs_to :assembler, :class_name => 'Person', :foreign_key => 'assembler_id'
	belongs_to :tester, :class_name => 'Person', :foreign_key => 'tester_id'
	belongs_to :order
	has_many :testings
	has_many :computer_stages

	def serial_no
		sprintf "%010d", id
	end

	def title
		model.name + ' ' + serial_no
	end

	def short_title
		model.name.split(' ')[1]
	end

	def self.find_by_hw_serials(serials)
		param1 = serials.sort() { |a,b| a <=> b }
		self.find_by_sql(["SELECT DISTINCT computers.*, group_concat(serial ORDER BY serial SEPARATOR ',') AS serials FROM `computers` JOIN `testings` on testings.computer_id = computers.id JOIN `components` ON components.testing_id = testings.id JOIN component_models ON components.component_model_id = component_models.id JOIN component_groups ON component_models.component_group_id = component_groups.id AND component_groups.name in ('LAN', 'NIC') GROUP BY testings.id HAVING serials = ?", param1.join(',')])
	end

	def self.find_testing()
		self.find_by_sql(["SELECT distinct computers.* FROM computers join testings on computers.id = testings.computer_id WHERE testings.test_start <= now() AND (testings.test_end IS NULL OR testings.test_end > now())"])
	end

end
