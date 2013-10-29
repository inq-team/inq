#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'shelves'
require 'planner/planner'

require 'active_record/fixtures'
require 'csv'

namespace :db do
	desc "Erase and fill database with fake data"

	# Some constants to tune configuration of generated content
	RANDOM_SEED = 42
	NUM_CUSTOMERS = 15
	NUM_MODELS = 5
	NUM_PEOPLE = 7
	NUM_ORDERS = 20

	UPPER = ('A'..'Z').to_a
	LOWER = ('a'..'z').to_a
	DIGITS = ('0'..'9').to_a
	UPPER_DIGITS = UPPER + DIGITS

	CUSTOMER_WORDS = %w(
		acoustics
		adorable
		ancient
		angry
		beautiful
		better
		bewildered
		black
		blue
		brief
		careful
		clean
		clever
		clumsy
		dead
		defeated
		drab
		early
		easy
		elegant
		embarrassed
		famous
		fancy
		fierce
		ghost
		gifted
		glamorous
		gray
		green
		grumpy
		handsome
		helpful
		helpless
		horse
		important
		incomes
		inexpensive
		itchy
		jealous
		late
		lazy
		long
		magnificent
		modern
		mushy
		mysterious
		nervous
		odd
		old
		old-fashioned
		orange
		panicky
		passenger
		plain
		police
		powerful
		purple
		quaint
		quick
		rapid
		realty
		red
		repulsive
		rich
		scary
		scene
		scent
		short
		shy
		slow
		sparkling
		stream
		swift
		technologies
		tender
		thoughtless
		ugliest
		uninterested
		unsightly
		uptight
		vast
		white
		wide-eyed
		worried
		wrong
		yellow
		young
	)
	CUSTOMER_ENDINGS = ['ltd', 'a.s.', 's.r.o', 'S.A.', 'AG', 'plc', 'AB', 'AS', 'GmbH', 'N.V.', 'Oy', 'LLC', 'Corporation']
	NAMES = %w(
		Aiden
		Amelia
		Ava
		Charlotte
		Ella
		Emily
		Emma
		Ethan
		Isabella
		Jack
		Jackson
		Jacob
		Liam
		Logan
		Lucas
		Mason
		Mia
		Noah
		Olivia
		Sophia
	)

	# Random distribution of order stages
	ORDER_STAGES_DIST = [0] * 3 + [1] * 3 + [2] * 5 + [3] * 10
	ORDER_STAGES = ['ordering', 'warehouse', 'acceptance']

	# Generate uniformly distributed integer random number in range of [min; max] inclusive
	# Can be invoked either:
	# * with two numeric arguments: `random_num(3, 5)`
	# * with one array argument: `random_num([3, 5])`
	def random_num(min, max = nil)
		if max.nil?
			min, max = min
		end
		rand(max - min + 1) + min
	end

	# Picks a random element from an array
	def random_element(arr)
		arr[rand(arr.length)]
	end

	# Generates a random string that looks like ID, constructed from chars
	# of random length in range of [min_len, max_len]
	def random_id(min_len, max_len, chars = UPPER_DIGITS)
		len = random_num(min_len, max_len)
		res = ''
		len.times {
			res << random_element(chars)
		}
		return res
	end

	# Picks a random element from all of ActiveRecord-based objects of certain class
	def random_object(record_type)
		all_ids = record_type.ids
		record_type.find_by_id(all_ids[rand(all_ids.length)])
	end

	def random_customer_name
		cust = []
		random_num(1, 3).times {
			cust << random_element(CUSTOMER_WORDS).capitalize
		}
		cust << random_element(CUSTOMER_ENDINGS)
		return cust.join(' ')
	end

	def random_model_name
		random_id(3, 6, UPPER) + '-' + random_id(3, 6, DIGITS)
	end

	ORDER_LINE_COMMENTS = ['supercharged', 'really fast', 'extra PSU', 'barebone', '12U rack']
	def random_order_line(order_id, qty)
		ol = OrderLine.new
		ol.order_id = order_id

		model = random_object(Model)
		ol.name = model.name
		if rand < 0.2
			ol.name += ' / '
			ol.name += random_element(ORDER_LINE_COMMENTS)
		end

		ol.sku = "#{model.id}M"
		ol.qty = qty
		ol.save
	end

	def random_person_name
		[random_element(NAMES), random_element(CUSTOMER_WORDS).capitalize].join(' ')
	end

	def generate_account(login, is_admin, is_assembler, is_tester)
		Person.new(
			login: login,
			name: "Demo #{login}",
			display_name: "Demo #{login}",
			password: 'inq',
			is_admin: is_admin,
			is_assembler: is_assembler,
			is_tester: is_tester
		).save!
	end

	def random_mac_number
		Array.new(6) { sprintf('%02x', rand(256)) }.join(':')
	end

	def random_component_serial(group)
		case group
		when 'CPU'
			# CPU serial number is normally undetectable by software
			''
		when 'NIC'
			random_mac_number
		else
			random_id(7, 10, DIGITS + UPPER)
		end
	end

	def random_components
		cc = []

		ComponentGroup.all.each { |cg|
			model = ComponentModel.where(component_group_id: cg.id).order('RAND()').first
			next unless model

			# Some black magic to make it look better
			qty = case cg.name
			when 'CPU'
				rand < 0.3 ? 2 : 1
			when 'Memory'
				2 ** random_num(0, 3)
			when 'HDD'
				rand(6) + 1
			when 'NIC'
				random_num(2, 4)
			else
				1
			end

			qty.times {
				cc << Component.new(component_model_id: model.id, hw_qty: qty, version: '123ABC', serial: random_component_serial(cg.name))
			}
		}

		cc
	end

	def generate_testing_stage(step, result)
		ts = TestingStage.new(
			stage: step.id,
			test_type: step.type,
			start: @last_time,
			comment: '',
			test_version: 1,
			result: result
		)

		# Close testing stage if it's not running
		if result != TestingStage::RUNNING
			@last_time += random_num(600, 2400)
			ts.end = @last_time

			# Generate some benchmarks, if applicable
			case step.type
			when 'net'
				2.times { |n|
					ts.marks << Mark.new(key: "NIC eth#{n} download speed", value_float: random_num(4500000, 15000000))
				}
			end
		end
		return ts
	end

	def generate_testing_stages(t, completed_stages)
		@last_time = t.test_start
		completed_stages.times { |i|
			t.testing_stages << generate_testing_stage(@plan[i], TestingStage::FINISHED)
		}

		# Create last in-progress stage, if not all steps are completed
		if completed_stages < @plan.size
			t.testing_stages << generate_testing_stage(@plan[completed_stages], TestingStage::RUNNING)
		end
	end

	task :populate => :environment do
		# A list of entities that would be completely deleted and regenerated
		TO_CLEANUP = [
			Computer,
			Order,
			OrderStage,
			Person,
			Component,
			Model,
			Profile,
			ComponentGroup,
			ComponentModel,
			ComputerStage,
			Testing,
			TestingStage,
		]
		TO_CLEANUP.each(&:delete_all)

		# Seed the random generator
		srand(RANDOM_SEED)

		# Set time mark
		now = Time.new

		# Generate customers
		customers = []
		NUM_CUSTOMERS.times {
			customers << random_customer_name
		}

		# Generate models
		NUM_MODELS.times {
			Model.new(name: random_model_name).save!
		}

		# Upload some data from fixture sets
		FIXTURE_DATA_DIR = 'lib/tasks/populate-fixtures'
		['profiles', 'component_groups'].each { |f|
			ActiveRecord::FixtureSet.create_fixtures(FIXTURE_DATA_DIR, f)
		}
		CSV.foreach("#{FIXTURE_DATA_DIR}/component_models.csv", :headers => true) { |row|
			ComponentModel.create!(row.to_hash)
		}

		# Calculate testing plan
		@plan = Planner.new(Profile.find(1).xml, [], [], nil, nil, false, nil, 1).plan

		# Load shelves configuration
		@shelves = []
		Shelves::Config.new(Inquisitor::Application::DEFAULT_SHELVES_CONFIG).groups.each { |group|
			group.stacks.each { |stack|
				stack.rows.each { |row|
					row.shelves.each { |shelf|
						@shelves << shelf.full_name if shelf.kind == :testing
					}
				}
			}
		}
		@shelves.shuffle!

		# Generate people to work with the system
		NUM_PEOPLE.times {
			p = Person.new
			p.name = random_person_name
			p.display_name = p.name
			p.is_assembler = true
			p.login = p.name.tr(' ', '_')
			p.save!
		}

		NUM_ORDERS.times {
			o = Order.new
			o.buyer_order_number = 'BON' + random_id(3, 6, DIGITS)
			o.mfg_task_number = 'MTN' + random_id(3, 6, DIGITS)
			o.mfg_report_number = 'MRN' + random_id(3, 6, DIGITS)
			o.customer = random_element(customers)
			o.title = random_id(3, 6, UPPER + DIGITS)
			o.manager = random_object(Person).name
			o.save!

			if rand < 0.7
				# Single computer type order
				random_order_line(o.id, random_num(20, 26))
			else
				# Many computer types order
				(rand(5) + 2).times {
					random_order_line(o.id, random_num(1, 4))
				}
			end

			# Choose max order stage for current order
			stage = random_element(ORDER_STAGES_DIST)

			last_time = now

			# Create max order stage as unclosed, except for #3, which means we're already in computer stages
			if stage < 3
				os = OrderStage.new
				os.order_id = o.id
				os.stage = ORDER_STAGES[stage]
				os.person = random_object(Person)
				last_time -= rand(3600)
				os.start = last_time
				os.save!
			else
				# Time to generate computers!
				o.order_lines.each { |ol|
					ol.qty.times {
						c = Computer.new
						c.order_id = o.id
						c.model_id = ol.sku.to_i
						c.profile_id = 1
						c.save!
					}
				}
			end

			# Create closed stages
			if stage > 0
				ORDER_STAGES[0..(stage - 1)].reverse.each { |st|
					os = OrderStage.new
					os.order_id = o.id
					os.stage = st
					os.person = random_object(Person)
					os.end = last_time
					last_time -= rand(3600)
					os.start = last_time
					os.save!
				}
			end
		}

		# Generate computer stages
		Computer.all.each { |c|
			# Assembly stage
			cs1 = ComputerStage.new
			cs1.computer_id = c.id
			cs1.stage = 'assembling'
			cs1.start = c.order.order_stages.last.end
			cs1.person = random_object(Person)
			cs1.end = cs1.start + rand(3600 * 2) if rand < 0.7
			cs1.save!

			# Assembly stage finished, let's start testing
			if cs1.end
				cs2 = ComputerStage.new
				cs2.computer_id = c.id
				cs2.stage = 'testing'
				cs2.start = cs1.end
				cs2.person = random_object(Person)
				cs2.save!

				# Place computer on a random shelf
				c.shelf = @shelves.pop
				c.save!

				t = Testing.new
				t.computer_id = c.id
				t.test_start = cs2.start
				t.profile_id = c.profile_id
				random_components.each { |c| t.components << c }

				completed_stages = rand(@plan.size + 1)
				generate_testing_stages(t, completed_stages)
				last_stage = t.testing_stages.last
				if last_stage.result != TestingStage::RUNNING
					t.test_end = last_stage.end
				end

				t.save!
			end
		}

		# Generate sample user accounts - we do it as a last step to prevent these users used by random attributions
		generate_account('admin', true, true, true)
		generate_account('assembler', false, true, false)
		generate_account('tester', false, false, true)
	end
end
