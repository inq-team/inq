class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :customer
	belongs_to :assembler, :class_name => 'Person', :foreign_key => 'assembler_id'
	belongs_to :tester, :class_name => 'Person', :foreign_key => 'tester_id'
	belongs_to :order
	has_many :testings
	has_many :computer_stages
	belongs_to :profile

	def serial_no
		sprintf "%010d", id
	end

	def assembler
		Person.find_by_sql(["SELECT people.* from people join computer_stages on people.id = computer_stages.person_id join computers on computer_stages.computer_id = computers.id where computers.id = ? and computer_stages.stage = ? order by computer_stages.start desc limit 1", id, "assembling"]).first()
	end

	def tester
		Person.find_by_sql(["SELECT people.* from people join computer_stages on people.id = computer_stages.person_id join computers on computer_stages.computer_id = computers.id where computers.id = ? and computer_stages.stage = ? order by computer_stages.start desc limit 1", id, "testing"]).first()
	end

	def title
		model.name + ' ' + serial_no
	end

	def short_title
		z = model.name.split(' ')
		z[2] =~ /G\d+/ ? z[1] + z[2] : z[1]
	end

	def self.find_by_hw_serials(serials)
		param1 = serials.sort() { |a,b| a <=> b }
		self.find_by_sql(["SELECT DISTINCT computers.*, group_concat(serial ORDER BY serial SEPARATOR ',') AS serials FROM `computers` JOIN `testings` on testings.computer_id = computers.id JOIN `components` ON components.testing_id = testings.id JOIN component_models ON components.component_model_id = component_models.id JOIN component_groups ON component_models.component_group_id = component_groups.id AND component_groups.name in ('LAN', 'NIC') GROUP BY testings.id HAVING serials = ?", param1.join(',')])
	end

	def self.find_testing()
		self.find_by_sql(["SELECT distinct computers.* FROM computers join testings on computers.id = testings.computer_id WHERE testings.test_start <= now() AND (testings.test_end IS NULL OR testings.test_end > now())"])
	end

	def last_testing
		Testing.find_by_sql(["SELECT testings.* FROM `testings` where testings.computer_id = ? ORDER BY test_start DESC LIMIT 1", id]).first()
	end

	def claim_ip(ip)
		transaction do
			Computer.update_all('shelf = NULL, ip = NULL', ['ip = ?', ip])
			self.ip = ip		
			save!	
		end	
	end

	def set_assembler(id)
		transaction do			
			computer_stages << ComputerStage.new(:start => Time.new(), :person => Person.find(id), :stage => 'assembling')
			save!
		end
	end

	def set_tester(id)
		transaction do			
			now = Time.new()
			computer_stages << ComputerStage.new(:start => now, :person => Person.find(id), :stage => 'testing')
			testings << Testing.new(:test_start => now)
			save!
		end
	end

	def manufacturing_date
		computer_stages.find_all() { |s| s.stage == 'packaging' && s.stage.end }.sort() { |a, b| a.start <=> b.start }.last().end
	end

end
