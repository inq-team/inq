require 'rexml/document'
require 'planner/meta'

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
		@stages = stages_prev + stages_now
		@comp_prev = comp_prev
		@comp_now = comp_now
		@start_new = !force_continue
		@force_continue = force_continue
	end

	def plan
		calculate unless @plan
		@plan
	end

	def calculate
		@plan = []
		@profile.root.each_element { |t|
			case t.name
			when 'test'
				if @stages.select { |st|
					st.stage == t.attribute('id').to_s and
					(st.result == TestingStage::FINISHED or @force_continue)
				}.empty? then
					add_test(t)
				end
			when 'submit-additional-components'
				@plan << 'submit-additional-components'
			else
				raise "Unknown element \"#{t.name}\" encountered in profile"
			end
		}
	end

	def script
		calculate unless @plan
		res = ''
		@plan.each { |t|
			if t == 'submit-additional-components'
				res << "submit_additional_components $HOME/components.xml\n"
			else
				res << "PLANNER=1 TEST_NAME=#{t.id} "
				t.var.each_pair { |k, v|
					res << "#{k}='#{v}' "
				}
				res << "run_test #{t.type}\n"
			end
		}
		return res
	end

	private
	##
	# Adds proper test to test plan from XML node 't' from profile
	def add_test(t)
		id = t.attribute('id').to_s
		type = t.attribute('type').to_s
		task = Task.new(id, type)
		t.each_element { |v|
			if v.name == 'var'
				task.var[v.attribute('name').to_s] = v.text
			end
		}
		@plan << task
	end
end
