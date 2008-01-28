require 'rexml/document'

class Planner
	attr_reader :start_new

	class Task
		attr_reader :id, :type, :var

		def initialize(id, type)
			@id = id
			@type = type
			@var = {}
		end
	end

	def initialize(profile, stages_prev, stages_now, comp_prev, comp_now, force_continue = false)
		@profile = REXML::Document.new(profile)	
		@plan = nil
		@stages_prev = stages_prev
		@stages_now = stages_now
		@comp_prev = comp_prev
		@comp_now = comp_now
		@start_new = !force_continue
	end

	def plan
		calculate unless @plan
		@plan
	end

	def calculate
		@plan = []
		@profile.root.each_element { |t|
			id = t.attribute('id').to_s
			type = t.attribute('type').to_s
			task = Task.new(id, type)
			t.each_element { |v|
				if v.name == 'var'
					task.var[v.attribute('name').to_s] = v.text
				end
			}
			@plan << task
		}
	end

	def script
		calculate unless @plan
		res = ''
		@plan.each { |t|
			res << "PLANNER=1 TEST_NAME=#{t.id} "
			t.var.each_pair { |k, v|
				res << "#{k}=#{v} "
			}
			res << "run_test #{t.type}\n"
		}
		return res
	end
end
