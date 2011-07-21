class Computer < ActiveRecord::Base
	belongs_to :model
	belongs_to :order
	has_many :testings, :order => 'test_start'
	has_many :computer_stages, :order => 'start'
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

	def checker
		Person.find_by_sql(["SELECT people.* from people join computer_stages on people.id = computer_stages.person_id join computers on computer_stages.computer_id = computers.id where computers.id = ? and computer_stages.stage = ? order by computer_stages.start desc limit 1", id, "checking"]).first()
	end

	def title
		model.name + ' ' + serial_no
	end

	def short_title
		z = model.name.split(' ')
		z[2] =~ /G\d+/ ? z[1] + z[2] : z[1]
	end

	def self.find_by_hw_serials(serials)
		self.find_by_sql(["SELECT * FROM computers c WHERE c.id IN (SELECT DISTINCT(computer_id) FROM (SELECT testings.computer_id, group_concat(serial ORDER BY serial SEPARATOR ',') AS serials FROM testings JOIN components ON components.testing_id = testings.id JOIN component_models ON components.component_model_id = component_models.id JOIN component_groups ON component_models.component_group_id = component_groups.id AND component_groups.name in ('LAN', 'NIC') GROUP BY testings.id HAVING serials = ?) t2)", serials.sort.join(',')])
	end

	def self.find_testing()
		self.find_by_sql(["select computers.*, start from computers join computer_stages on computers.id = computer_stages.computer_id  where stage = 'testing' and end is null order by start"])
	end

	def last_testing
		Testing.find_by_sql(["SELECT testings.* FROM `testings` where testings.computer_id = ? ORDER BY test_start DESC LIMIT 1", id]).first()
	end

	def last_computer_stage
		ComputerStage.find_by_computer_id(id, :order => 'start DESC')
	end

	def claim_ip(ip)
		transaction do
			Computer.update_all('shelf = NULL, ip = NULL', ['ip = ?', ip])
			self.ip = ip		
			save!
		end	
	end

	def ip_addresses
		config = Shelves::Config.new(DEFAULT_SHELVES_CONFIG)
		return config.by_ipnet(ip).get_addresses.find_all { |a| s = `/sbin/arp -n | grep #{ a }` ; !s.empty? && s !~ /incomplete/ }
	end

	def set_assembler(person_id)
		set_stage_person('assembling', person_id, false)
	end

	def set_tester(person_id)
		set_stage_person('testing', person_id, false)
	end

	def set_checker(person_id)
		set_stage_person('checking', person_id, true)
	end

	def manufacturing_date
		stage = computer_stages.find_all() { |s| s.stage == 'testing' && s.end }.sort() { |a, b| a.start <=> b.start }.last
		stage.end if stage
	end

	def self.with_orders
		find_by_sql("select distinct computers.* from computers left join testings on computers.id = testings.computer_id where computers.order_id is not null and testings.id is not null order by computers.order_id")
	end

	def self.free_id
		Computer.find_by_sql('SELECT MAX(id)+1 FROM computers')[0]['MAX(id)+1'].to_i
	end
	
	def self.stage_in_process(order_id, stage)
		Computer.find_by_sql(["SELECT computers.*
		FROM computers INNER JOIN computer_stages 
		ON computer_stages.computer_id=computers.id
		WHERE computers.order_id=?
		AND computer_stages.stage=?
		AND computer_stages.end IS NULL", order_id, stage])
	end
		
	def self.stage_done(order_id, stage)
		Computer.find_by_sql(["SELECT computers.*
		FROM computers INNER JOIN computer_stages 
		ON computer_stages.computer_id=computers.id
		WHERE computers.order_id=?
		AND computer_stages.stage=?
		AND computer_stages.end IS NOT NULL", order_id, stage])
	end
	
	##
	# If computer_stage is now running, then just set a person for
	# it. If it's not running, close last stage, start this stage and
	# set a person for it.
	def set_stage_person(stage_name, person_id, stage_complete = false)
		Computer.transaction do 
			#raise 'racoon mushrooms' if ComputerStage.find_by_computer_id_and_stage(id, stage_name, :conditions => 'end is not null')
			return if ComputerStage.find_by_computer_id_and_stage(id, stage_name, :conditions => 'end is not null')
			last_cs = last_computer_stage
			if last_cs and last_cs.stage == stage_name
				last_cs.person_id = person_id
				last_cs.end = Time.new if stage_complete
				last_cs.save!
			else
				if last_cs
					last_cs.end = Time.new
					last_cs.save!
					sleep 1 # GREYFIX: a crude workaround for MySQL datetime 1 sec granularity to make sure that stages go in the right order
				end
				computer_stages << ComputerStage.new(
					:start => Time.new(),
					:person_id => person_id,
					:stage => stage_name
				)
				save!
			end
		end
	end
end
