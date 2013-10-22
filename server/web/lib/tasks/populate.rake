namespace :db do
	desc "Erase and fill database with fake data"

	UPPER = ('A'..'Z').to_a
	LOWER = ('a'..'z').to_a
	DIGITS = ('0'..'9').to_a
	UPPER_DIGITS = UPPER + DIGITS

	def random_id(min_len, max_len, chars = UPPER_DIGITS)
		len = rand(max_len - min_len) + min_len
		res = ''
		len.times {
			res << chars[rand(chars.size)]
		}
		return res
	end

	def random_object(record_type)
		all_ids = record_type.ids
		all_ids[rand(all_ids.length)]
	end

	task :populate => :environment do
		[Computer, Order, Component, Model].each(&:delete_all)

		# Seed the random generator
		srand(42)

		5.times {
			m = Model.new
			m.name = random_id(3, 6, UPPER) + '-' + random_id(3, 6, DIGITS)
			m.save!
		}

		200.times {
			c = Computer.new
			c.model_id = random_object(Model)
			c.save!
		}
	end
end
