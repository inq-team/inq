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

	def initialize(profile, stages_prev, stages_now, comp_prev, comp_now, force_continue, prev_profile_id, testing_profile_id)
		@profile = REXML::Document.new(profile)	
		@plan = nil
		@stages_prev = stages_prev
		@stages_now = stages_now
		@comp_prev = comp_prev
		@comp_now = comp_now
		@start_new = !force_continue
		@force_continue = force_continue
		@profile_now = testing_profile_id
		@profile_prev = prev_profile_id

		@stages = (@profile_now == @profile_prev) ? stages_prev + stages_now : stages_now
	end

	def plan
		calculate unless @plan
		@plan
	end

	def profile_includer(profile)
		parsed_profile_text = ""

		# We will work with text XML representation
		xml_text = ""
		profile.write(xml_text, indent = 0)

		xml_text.each_line { |l|
			if l =~ /<include-profile profile=\'(.*)\'/ then
				# Simply insert included profile's text
				parsed_profile_text << Profile.find_all_by_feature(Regexp.last_match(1)).last.xml.gsub(/<\/??tests>/, "")
			else
				parsed_profile_text << l
			end
		}

		parsed_profile = REXML::Document.new(parsed_profile_text)
		# Recursively replace all include-profile's instances
		if parsed_profile_text =~ /include-profile/ then
			parsed_profile = profile_includer(parsed_profile)
		end

		return parsed_profile
	end

	def calculate
		@plan = []
		
		# We need to parse include-profile tag before
		profile_includer(@profile).root.each_element { |t|
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
				res << "PLANNER=1 TEST_NAME=\"#{t.id}\" "
				t.var.each_pair { |k, v|
					res << "#{k.strip}='#{v.nil? ? "" : v.strip}' "
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
