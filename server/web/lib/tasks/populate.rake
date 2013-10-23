namespace :db do
	desc "Erase and fill database with fake data"

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

	def random_id(min_len, max_len, chars = UPPER_DIGITS)
		len = rand(max_len - min_len) + min_len
		res = ''
		len.times {
			res << chars[rand(chars.size)]
		}
		return res
	end

	def random_element(arr)
		arr[rand(arr.length)]
	end

	def random_object(record_type)
		all_ids = record_type.ids
		record_type.find_by_id(all_ids[rand(all_ids.length)])
	end

	ORDER_LINE_COMMENTS = ['supercharged', 'really fast', 'extra PSU', 'barebone', '12U rack']

	def random_order_line
		r = random_object(Model).name
		if rand < 0.2
			r += ' / '
			r += random_element(ORDER_LINE_COMMENTS)
		end
		return r
	end

	task :populate => :environment do
		[Computer, Order, Component, Model].each(&:delete_all)

		# Seed the random generator
		srand(42)

		customers = []
		15.times {
			cust = []
			(rand(3) + 1).times {
				cust << random_element(CUSTOMER_WORDS).capitalize
			}
			cust << CUSTOMER_ENDINGS
			customers << cust.join(' ')
		}

		5.times {
			m = Model.new
			m.name = random_id(3, 6, UPPER) + '-' + random_id(3, 6, DIGITS)
			m.save!
		}

		50.times {
			o = Order.new
			o.buyer_order_number = 'BON' + random_id(3, 6, DIGITS)
			o.mfg_task_number = 'MTN' + random_id(3, 6, DIGITS)
			o.mfg_report_number = 'MRN' + random_id(3, 6, DIGITS)
			o.customer = random_element(customers)
			o.title = random_id(3, 6, UPPER + DIGITS)
			o.save!

			if rand < 0.7
				# Single computer type order
				ol = OrderLine.new
				ol.order_id = o.id
				ol.name = random_order_line
				ol.qty = rand(20) + 7
				ol.sku = random_id(3, 6, UPPER + DIGITS)
				ol.save!
			else
				# Many computer types order
				(rand(5) + 2).times {
					ol = OrderLine.new
					ol.order_id = o.id
					ol.name = random_order_line
					ol.qty = rand(4) + 1
					ol.sku = random_id(3, 6, UPPER + DIGITS)
					ol.save!
				}
			end
		}

		200.times {
			c = Computer.new
			c.model_id = random_object(Model).id
			c.save!
		}
	end
end
