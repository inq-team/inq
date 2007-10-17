class ComputersController < ApplicationController
	def index
		archive
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],
#	       :redirect_to => { :action => :archive }

	def archive
		@computer_pages, @computers = paginate :computers, :per_page => 20
		render :action => 'list'
	end

	def latest
		@computer = Computer.find(params[:id])
		@testing = @computer.testings[-1]
		@components = @testing.components
		respond_to { |format|
			format.html { render :action => 'testing' }
			format.xml  { render :xml => @computer.to_xml }
		}
	end

	def testing
		@computer = Computer.find(params[:id])
		@testing = Testing.find(params[:testing_id])
		respond_to { |format|
			format.html { render :action => 'testing' }
			format.xml  { render :xml => @testing.to_xml(:include => :components) }
		}
	end

	def new
		@computer = Computer.new
	end

	def create
		@computer = Computer.new(params[:computer])
		if @computer.save
			flash[:notice] = 'Computer was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@computer = Computer.find(params[:id])
	end

	def set_assembler
		@computer = Computer.find(params[:id])
		@computer.assembler_id = params[:assembler_id]
		@computer.assembling_start = Time.now
		@computer.save!
		head :ok
	end

	def set_tester
		@computer = Computer.find(params[:id])
		@computer.tester_id = params[:tester_id]
		@computer.save!
		head :ok
	end

	def set_shelf
		@computer = Computer.find(params[:id])
		@computer.shelf = params[:shelf]
		@computer.save!
		head :ok
	end

	def update
		@computer = Computer.find(params[:id])
		if @computer.update_attributes(params[:computer])
			flash[:notice] = 'Computer was successfully updated.'
			format.html { redirect_to :action => 'show', :id => @computer }
			format.xml  { head :ok }
		else
			format.html { render :action => 'edit' }
			format.xml  { render :xml => @computer.errors.to_xml }
		end
	end

	def submit_components
		#serial_no = 4431, id = 4363
		@computer = Computer.find_by_id(params[:id])
		d = REXML::Document.new(params[:list])
		components = []
		d.root.each_element { |c|
			components << {
				:type => c.elements['type'] ? c.elements['type'].text : '',
				:vendor => c.elements['vendor'] ? c.elements['vendor'].text : '',
				:model => c.elements['model'] ? c.elements['model'].text : '',
				:serial => c.elements['serial'] ? c.elements['serial'].text : ''
			}
		}
		ccp = components.dup

		errors = []
		testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		unless testing && testing.components.size == components.size && testing.components.inject(true) { |b, cmp| b && ccp.delete(ccp.find() { |h| (h[:vendor] == cmp.model.vendor && h[:model] == cmp.model.name) || (!h[:serial].blank? && h[:serial] == cmp.serial)  }) }
			# BAD: component_group_id column used here directly
			testing = Testing.new(:test_start => Time.new(), :components => components.collect() { |h| Component.new(:serial => h[:serial], :model => ComponentModel.find_or_create_by_name_and_vendor_and_component_group_id(h[:model], h[:vendor], ComponentGroup.find_or_create_by_name(h[:type]).id)) })
			@computer.testings << testing
		end

		if @computer.save
			flash[:notice] = 'Components successfully updated.'
			respond_to() do |format|
				format.html { redirect_to(:action => 'show', :id => @computer) }
				format.xml { render(:xml => testing.to_xml()) }
			end
		else
			head(:status => 500)
		end
	end

	def identify
		@macs = params[:macs].split(",")
		p @macs
		@computers = Computer.find_by_hw_serials(@macs)
		if @computers.blank?
			head(:status => 404)
		elsif @computers.size > 1
			head(:status => 500)
		else
			respond_to() do |format|
				format.xml { render(:xml => @computers.first.to_xml()) }
				format.html { redirect_to(:action => 'show', :id => @computers.first.id) }
			end
		end
	end

	def advance
		@computer = Computer.find(params[:id])
		event = params[:event].to_sym() || :start
		name = params[:stage]
		comment = params[:comment] || ""
		raise "Event not supported: #{ event }." unless [:start, :finish, :fail].include?(event)
                testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		stage = testing.testing_stages.sort() { |a, b| a.start <=> b.start }.last
		case event
		when :start
			testing.testing_stages << TestingStage.new(:start => Time.new(), :comment => comment, :stage => name)
			z = testing
		when :finish, :fail
			stage.comment = comment
			stage.end = Time.new()
			stage.result = event == :finish ? 1 : 2
			z = stage
		end
		if z.save
			flash[:notice] = 'Stage #{stage}(#{event},"#{comment}") successfully updated.'
			respond_to() do |format|
				format.html { redirect_to(:action => 'show', :id => @computer) }
				format.xml { render(:xml => testing.to_xml()) }
			end
		else
			head(:status => 500)
		end
	end

	def progress
		@computer = Computer.find(params[:id])
                testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		progress = params[:complete].to_f() || 0
		total = params[:total].to_f()
		testing.progress_complete = progress
		testing.progress_total = total 
		if testing.save
			flash[:notice] = 'Progress of current stage set successfully to #{ progress }/#{ total }.'
			respond_to() do |format|
				format.html { redirect_to(:action => 'show', :id => @computer) }
				format.xml { render(:xml => testing.to_xml()) }
			end
		else
			head(:status => 500)
		end
	end

	def plan
		@computer = Computer.find(params[:id])
                testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		if testing.profile_id.blank? 
			respond_to() do |format|
				format.html { redirect_to(:action => 'show', :id => @computer) }
				format.xml do
					output = ""
					build = Builder::XmlMarkup.new(:target => output)
					build.instruct! 
					build.testing_plan do |plan|
						plan.script do |s| 
							s.cdata! <<__EOF__
#!/bin/sh -ef

PLANNED_TESTS=cpu memory hdd

for TEST in $PLANNED_TESTS; do
	if [ -x $TEST ] ; then
		case "$TEST" in
		cpu)
			CPU_NO_SCALE=0 
			CPU_WAIT_USERSPACE=20 
			CPU_WAIT_MAX_FREQ=60 
			CPU_WAIT_MIN_FREQ=60 
			CPU_WAIT_FREQ_STEP=60 
			CPU_RANDOM_TIMES=50 
			CPU_WAIT_RANDOM=3 
			;;
		memory)
			;
			;;
		hdd)
			;
			;;
		esac			
		run_test $TEST
	fi
done

__EOF__
						end
					end
					render(:xml => output) 
				end
			end
		else
			head(:status => 404)
		end
	end

	def watchdog
		@computer = Computer.find(params[:id])
		if @computer then
			@computer.last_ping = Time.now
			if @computer.save!
				head(:status => 200)
			else
				head(:status => 500)
			end
		else
			head(:status => 404)
		end
	end

	def destroy
		Computer.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
