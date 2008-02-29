require 'mykit/components'
require 'mykit/comparison'
require 'planner/planner'
require 'tempfile'

class ComputersController < ApplicationController
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],
#	       :redirect_to => { :action => :archive }

	layout nil, :only => ['audit_comparison', 'check_audit_js']

	@@default_config = Shelves::Config.new(DEFAULT_SHELVES_CONFIG)

	def archive
		@computer_pages, @computers = paginate :computers, :per_page => 20
		render :action => 'list'
	end

	def ordered
		ids = Computer.find_by_sql("select distinct computers.id from computers left join testings on computers.id = testings.computer_id where computers.order_id is not null and testings.id is not null").collect { |c| c.id }
		@computers = Computer.find(*ids)		
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
		@computer.set_assembler(params[:assembler_id])
		head :ok
	end

	def set_tester
		@computer = Computer.find(params[:id])		
		@computer.set_tester(params[:tester_id])
		head :ok
	end

	def set_shelf
		@computer = Computer.find(params[:id])
		@computer.shelf = params[:shelf]
		@computer.save!
		head :ok
	end

	def add_component
		@computer = Computer.find(params[:id])
		testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		testing.components << Component.new(
			:serial => params[:serial],
			:model => ComponentModel.find_or_create_by_name_and_vendor_and_component_group_id(params[:model], params[:vendor], ComponentGroup.find_or_create_by_name(params[:type]).id)
		)
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

	def index	
		config = Shelves::Config.new(params[:config]) if params[:config]
		@computers = Computer.find_testing()
		@shelves = config || @@default_config 
		@byshelves = @computers.inject({}) { |h, c| sh = @shelves.by_ipnet(c.ip) ; h[!sh.blank? ? sh.full_name : c.shelf] = c ; h }
		render(:layout => 'computer_shelves', :template => 'computers/shelves')
	end

	def show
		@computer = Computer.find(params[:id])
                @sorted_testings = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }
		if @sorted_testings
			@testing_number = params[:testing] ? params[:testing].to_i() : @sorted_testings.size - 1
			redirect_to(:action => 'hw', :id => params[:id], :testing => @testing_number)
		else
			redirect_to(:action => 'hw', :id => params[:id])
		end
	end

	def hw
		prepare_computer_tabs
		@components = @testing ? @testing.components : []
		render(:layout => 'computer_tabs')
	end

	def audit_popup
		prepare_computer_and_testing
		@confirmation = params[:confirmation].to_i
		@comment = params[:comment] || ''
		@close = params[:close]
		render(:layout => 'popup')
	end

	def audit_confirmation		
		prepare_computer_and_testing
		@confirmation = params[:confirmation].to_i 
		@comment = params[:comment] || ''
		@close = params[:close]
		@audit = @testing.audit
		if @audit.confirmation 
			flash[:error] = "Testing confirmed already!" 		
			render(:layout => 'popup', :action => 'audit_popup')
			return
		end
		@audit.confirmation = @confirmation
		@audit.confirmation_date = Time.new
		@audit.comment = @comment
		#TODO: add
		# @audit.person = ... ?
		unless @audit.save
			flash[:error] = @audit.errors
			render(:layout => 'popup', :action =>  'audit_popup')
			return
		end
		render(:layout => 'popup')
	end

	def check_audit
		prepare_computer_and_testing
		check = @testing && @testing.audit && @testing.audit.confirmation
                respond_to() do |format|
                        format.html { 
				if check
					redirect_to(:action => 'audit', :id => @computer, :testing => @testing_number) 
				else
					head :status => 404
				end
			}
                        format.xml { 
				if check
					render(:xml => @testing.audit.to_xml()) 
				else
					head :status => 404
				end
			}
			format.js { 
				render :update do |page|
					page << (check ? 'window.close();' : ';')
				end
			}
                end
	end

	def audit
		prepare_computer_and_testing
		@close = params[:close]
		if cached = @testing.audit
			@audit = cached
			@comparison = load_comparison(@audit.comparison)
			render(:layout => 'computer_audit', :action => 'audit_cached')
		else
			render(:layout => 'computer_audit')
		end
	end

	def audit_comparison
		prepare_computer_and_testing
                @testing ? @components = @testing.components : @components = []
		@components.each { |c| c.model.group.name = MyKit::Keywords::GROUP_TRANS[c.model.group.name] if c.model.group and MyKit::Keywords::GROUP_TRANS[c.model.group.name] }
		lines = @computer.order.order_lines
		unless lines.blank?
			min = lines.inject(lines.first.qty) { |i, j| i > j.qty ? j.qty : i } 
			lines.each { |l| l.qty /= min }	
		end
                @items = lines.inject({}) { |h, l| h.merge({ l => MyKit::Parser.parse(l.name) }) } 
		@comparison = MyKit::Comparison.compare(@items, @components)
		@audit = Audit.new
		@audit.comparison = dump_comparison(@comparison)
		@audit.save!
		@testing.audit = @audit
		@testing.save!
	end
	
	def sticker
		prepare_computer_tabs
		@count = params[:count] 
		@components = @testing.components.collect { |c| c.model }.inject({}) { |h, m| h[m] = h[m] ? h[m] + 1 : 1 ; h }.collect { |k, v| { :name => k.short_name.blank? ? k.name : k.short_name, :count => v, :model => k  } }.sort() { |q, w| a = q[:model] ; b = w[:model] ; (z = ((a.group ? a.group.name : '') <=> (b.group ? b.group.name : ''))) == 0 ? (q[:name] || 'NULL') <=> (w[:name] || 'NULL') : z }
		render(:layout => 'computer_tabs')
	end

	def free_form
		sticker()
	end

	def print_sticker		
		@computer = Computer.find(params[:id])
		@testing_number = params[:testing].to_i()
                @sorted_testings = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }
		@testing = @sorted_testings[@testing_number]			
		count = params[:count].to_i()
	
		prn = '/dev/ttyS0'
		srv = 'tos'
		
		options = {}
		options[:name] = @computer.model.dmi_name
		options[:copies] = count
		options[:components] = []
		options[:serial] = @computer.serial_no
		options[:date] = @computer.manufacturing_date.strftime("%d.%m.%Y")
		options[:docno] = Order.buyer_order_num(@computer.id)

		if params[:commit] == 'Print'
			if params[:raw]
				@testing.custom_sticker = params[:raw] 
				@testing.save!
				options[:components] = @testing.custom_sticker.split("\n").collect() { |s| s.chomp }
			else
				@testing.components.collect { |c| c.model }.inject({}) { |h, m| h[m] = h[m] ? h[m] + 1 : 1 unless m.short_name.blank? ; h }.collect { |k, v| { :name => k.short_name, :count => v, :model => k  } }.sort() { |q, w| a = q[:model] ; b = w[:model] ; (z = ((a.group ? a.group.name : '') <=> (b.group ? b.group.name : ''))) == 0 ? q[:name] <=> w[:name] : z }[0..14].inject(1) { |i, y| options[:components] << sprintf("%2s %-38s %s", i, y[:name][0..37], y[:count]) ; i + 1 }
			end
			
			sticker = Sticker.new(options)
			sticker.send_to_printer(srv, prn)
						
			#if sticker.send_to_printer(srv, prn)
 				flash[:notice] = "Sent sticker to printer <strong class='printer'>#{srv}:#{prn}</strong>"
			#else
			#	flash[:error] = "Printer <strong class='printer'>#{srv}:#{ prn }</strong> reported errors."
			#end
		end
		redirect_to(:action => 'sticker', :id => params[:id], :count => count.to_s(), :testing => @testing_number)
	end

	def log
		prepare_computer_tabs
		@logs = File.open("/var/log/HOSTS/c#{ @computer.id }").readlines()
		render(:layout => 'computer_tabs')
	end

	def mark
		prepare_computer_and_testing
		@marks = Mark.by_testing(@testing)
		render(:layout => 'computer_tabs')
	end

	def graph
		prepare_computer_and_testing
		respond_to { |format|
			format.html {
				render(:layout => 'computer_tabs')
			}
			format.png {
				png_file = Tempfile.new('graph_png')
				data_file = Tempfile.new('graph_data')
				Graph.find_all_by_testing_id(@testing).each { |g|
					data_file.puts "#{g.timestamp.to_f}\t#{g.value}"
				}
				chart_file = Tempfile.new('graph_chart')
				chart_file.puts <<__EOF__
set terminal png size 800, 400
set output "#{png_file.path}"
set key below box
set grid
set size 1,1
set lmargin 7
set rmargin 5
set tmargin 1
set bmargin 2

plot '#{data_file.path}' using 1:2 title "Value" with lines
__EOF__

				data_file.flush
				chart_file.flush

				system("gnuplot #{chart_file.path}")
				send_file(png_file.path)

#				data_file.close!
#				chart_file.close!
#				png_file.close!
			}
		}
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
			testing = Testing.new(
				:profile_id => @computer.profile_id,
				:test_start => Time.new(),
				:components => components.collect() { |h|
					Component.new(
						:serial => h[:serial],
						:model => ComponentModel.find_or_create_by_name_and_vendor_and_component_group_id(
							h[:model],
							h[:vendor],
							ComponentGroup.find_or_create_by_name(h[:type]).id
						)
					)
				}
			)
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

	def submit_additional_components
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

		t = @computer.last_testing
		components.each { |h|
			t.components << Component.new(
				:serial => h[:serial],
				:model => ComponentModel.find_or_create_by_name_and_vendor_and_component_group_id(
					h[:model],
					h[:vendor],
					ComponentGroup.find_or_create_by_name(h[:type]).id
				)
			)
		}
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

	def testing_finished
		ts = Time.now
		@computer = Computer.find(params[:id])

		lt = @computer.last_testing
		lt.test_end = ts
		lt.save!

		lcs = @computer.last_computer_stage
		lcs.end = ts
		lcs.save!

		flash[:notice] = 'Testing finished'
		respond_to() do |format|
			format.html { redirect_to(:action => 'show', :id => @computer) }
			format.xml { render(:xml => lt.to_xml()) }
		end
	end

	def test_promise_time
		@computer = Computer.find(params[:id])
		testing = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }.last
		testing.progress_promised_time = params[:sec].to_f()
		if testing.save
			flash[:notice] = 'Set promised time'
			respond_to() do |format|
				format.html { redirect_to(:action => 'show', :id => @computer) }
				format.xml { render(:xml => testing.to_xml()) }
			end
		else
			head(:status => 500)
		end
	end

	def set_profile
		prepare_computer_and_testing
		@computer.profile_id = params[:profile].to_i
		@testing.profile_id = params[:profile].to_i
		@computer.save!
		@testing.save!
		head(:status => 200)
	end

	def plan
		prepare_computer_and_testing
		prev_testing = @sorted_testings[@testing_number - 1]
		@pl = Planner.new(
			@computer.profile.xml,
			@testing ? @testing.testing_stages : [],
			prev_testing ? prev_testing.testing_stages : [],
			@testing ? @testing.components : nil,
			prev_testing ? prev_testing.components : nil
		)
		@pl.calculate
		render :text => @pl.script
	end

	def ip
		@computer = Computer.find(params[:id])
		render(:text => @computer.ip || '')
	end

	def set_ip
		@computer = Computer.find(params[:id])
		ip = params[:ip]
		if @computer.claim_ip(ip)
			head(:ok)
		else
			head(:status => 500)
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

	def benchmark_submit_float
		stage = Computer.find(params[:id]).last_testing.last_stage
		stage.marks << Mark.new(
			:key => params[:key],
			:value_float => params[:value]
		)
		if stage.save!
			head(:status => 200)
		else
			head(:status => 500)
		end
	end

	def benchmark_submit_string
		stage = Computer.find(params[:id]).last_testing.last_stage
		stage.marks << Mark.new(
			:key => params[:key],
			:value_str => params[:value]
		)
		if stage.save!
			head(:status => 200)
		else
			head(:status => 500)
		end
	end

	def monitoring_submit
		g = Graph.new(
			:testing => Computer.find(params[:id]).last_testing,
			:monitoring_id => params[:monitoring_id].to_i,
			:timestamp => params[:timestamp] ? Time.at(params[:timestamp].to_i) : Time.now,
			:key => params[:key].to_i,
			:value => params[:value].to_f			
		)
		g.save!
		head(:status => 200)
	end

	def destroy
		Computer.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
	
	def label_epassport
		@computer = Computer.find(params[:id])
		@testing_number = params[:testing].to_i()
                @sorted_testings = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }
		@current_testing = @sorted_testings[@testing_number]
		
		t = if @computer.model.id == 67
			`/srv/inq/script/printer-epassport/epassport-250g3 #{params[:id]} #{@current_testing.id}`
		else
			`/srv/inq/script/printer-epassport/epassport #{params[:id]} #{@current_testing.id}`
		end

		`echo '#{t}' | ssh tos "sudo cat >/dev/ttyS0"`
#		File.open('/dev/ttyS0', 'w') { |f|
#			f.write()
#		}
		redirect_to :action => 'hw', :id => params[:id], :testing => @testing_number
	end

	private
	
	RESULT_MAPPING = {
		0 => 'running',
		1 => 'finished',
		2 => 'failed',
		3 => 'hanging',
	}
	
	def prepare_computer_tabs
		prepare_computer_and_testing
		return if @sorted_testings.empty?
		prev_testing = @sorted_testings[@testing_number - 1]

		# Completed or running stages
		@stages = @testing.testing_stages.sort { |a, b| a.start <=> b.start }.collect { |stage|
			{
				:id => stage.stage,
				:elapsed => ((stage.end || Time.new()) - stage.start).round,
				:result => RESULT_MAPPING[stage.result] || 'unknown',
			}
		}

		# Planned stages
		if @computer.profile
			pl = Planner.new(@computer.profile.xml, @testing.testing_stages, prev_testing.testing_stages, @testing.components, prev_testing.components, true)
			pl.plan.each { |stage|
				@stages << {
					:id => stage.id,
					:result => 'planned'
				}
			}
		end
	end

	def prepare_computer_and_testing
		@computer = Computer.find(params[:id])
                @sorted_testings = @computer.testings.sort() { |a, b| a.test_start <=> b.test_start }
		if @sorted_testings.empty?
			@testing_number = 0
			return
		end
		@testing_number = params[:testing] ? params[:testing].to_i() : @sorted_testings.size - 1
		@testing = @sorted_testings[@testing_number]
	end


	def dump_comparison(comparison)
		Marshal.dump(comparison)
	end


	def load_comparison(str)
		Marshal.load(str)
	end
end
