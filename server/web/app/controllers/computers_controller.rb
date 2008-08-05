require 'planner/planner'
require 'tempfile'

class ComputersController < ApplicationController
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],
#	       :redirect_to => { :action => :archive }

	layout nil, :only => ['audit_comparison', 'check_audit_js']

	enable_sticker_printing

	@@default_config = Shelves::Config.new(DEFAULT_SHELVES_CONFIG)

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

	def set_checker
		@computer = Computer.find(params[:id])		
		@computer.set_checker(params[:checker_id])
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
		testing = @computer.testings.last
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

	def show_components
		render :text => Computer.find(params[:id]).last_testing.components.collect { |com|
			"#{com.model.vendor}::#{com.model.name}::#{com.model.group.name}"
		}.join("\n")
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
		@sorted_testings = @computer.testings
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
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

		prepare_computer_and_testing
		@confirmation = params[:confirmation].to_i
		@comment = params[:comment] || ''
		@close = params[:close]
		render(:layout => 'popup')
	end

	def audit_confirmation
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

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
		@audit.person_id = current_person.id
		unless @audit.save
			flash[:error] = @audit.errors
			render(:layout => 'popup', :action =>  'audit_popup')
			return
		end
		Waitstring.send_to_computer(@computer, @confirmation == 1 ? 'OK' : 'ERROR', @@default_config)
		render(:layout => 'popup')
	end

	def check_audit
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

		prepare_computer_and_testing
		check = @testing && @testing.audit && @testing.audit.confirmation || !@computer.order
		respond_to() do |format|
			format.html { 
				if check
					redirect_to(:action => @computer.order ? 'audit' : 'show', :id => @computer, :testing => @testing_number) 
				else
					head :status => 404
				end
			}
			format.xml { 
				if check
					render(:xml => @testing.audit ? @testing.audit.to_xml() : "<thursday_hack />")
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

	def compare_fast
		reffilenames = (params[:files] || '').split(',').map{|fn| "#{TFTP_DIR}/#{fn}"}
		
		for file_name in reffilenames
			unless File.exist?(file_name)
				head(:status => 500)
				return
			end
		end

		components = Computer.find(params[:id]).last_testing.components
		source = {}
		for c in components
			 source[c.component_model_id] = components.find_all{|x| x.component_model_id == c.component_model_id }.size
		end
	
		excluded = (params[:excluded] || '').split(',').map{|x| x.to_i }
		excluded.each{|e| source.delete(e) }
		
		for ref in reffilenames.map{|fn| File.open(fn) }.map{|f| YAML::load(f) }
			excluded.each{|e| ref.delete(e) }
			if ref != source
				head(:status => 500)
				return
			end
		end
		
		head :ok
	end
	
	def list_components
		components = Computer.find(params[:id]).last_testing.components
		source = {}
		for c in components
			 source[c.component_model_id] = components.find_all{|x| x.component_model_id == c.component_model_id }.size
		end
		render :text => source.to_yaml		
	end

	def audit
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

		prepare_computer_tabs
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
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

		prepare_computer_and_testing
		@testing ? @components = @testing.components : @components = []
		@components.each { |c| c.model.group.name = Mykit::Keywords::GROUP_TRANS[c.model.group.name] if c.model.group and Mykit::Keywords::GROUP_TRANS[c.model.group.name] }
		lines = @computer.order.order_lines
		unless lines.blank?
			min = lines.inject(lines.first.qty) { |i, j| i > j.qty ? j.qty : i } 
			lines.each { |l| l.qty /= min }	
		end
		@items = lines.inject({}) { |h, l| h.merge({ l => Mykit::Parser.parse(l.name, l.sku) }) } 
		@comparison = Mykit::Comparison.compare(@items, @components)
		@audit = Audit.new
		@audit.comparison = dump_comparison(@comparison)
		@audit.save!
		@testing.audit = @audit
		@testing.save!
	end

	def force_audit
		unless logged_in?
			login_required; return
		end
		unless current_person.tester?
			access_denied; return
		end

		prepare_computer_tabs
		@testing ? @components = @testing.components : @components = []
		@components.each { |c| c.model.group.name = Mykit::Keywords::GROUP_TRANS[c.model.group.name] if c.model.group and Mykit::Keywords::GROUP_TRANS[c.model.group.name] }
		lines = @computer.order.order_lines
		unless lines.blank?
			min = lines.inject(lines.first.qty) { |i, j| i > j.qty ? j.qty : i } 
			lines.each { |l| l.qty /= min }	
		end
		@items = lines.inject({}) { |h, l| h.merge({ l => Mykit::Parser.parse(l.name, l.sku) }) } 
		@comparison = Mykit::Comparison.compare(@items, @components)
		@forced = 0
		render(:action => 'audit_cached', :layout => 'computer_audit')
	end
	
	def sticker
		prepare_computer_tabs
		@count = params[:count]
		@components = {}
		if @testing 
			@components = @testing.components.collect { |c| c.model }.inject({}) { |h, m| h[m] = h[m] ? h[m] + 1 : 1 ; h }.collect { |k, v| { :name => k.short_name.blank? ? k.name : k.short_name, :count => v, :model => k, :hidden => k.short_name.blank? } }.sort() { |q, w| a = q[:model] ; b = w[:model] ; (z = ((a.group ? a.group.name : '') <=> (b.group ? b.group.name : ''))) == 0 ? (q[:name] || 'NULL') <=> (w[:name] || 'NULL') : z }
		end
		render(:layout => 'computer_tabs')
	end

	def free_form
		sticker()
	end

	def print_sticker_compat
		@computer = Computer.find(params[:id])
		@testing_number = params[:testing].to_i()
		@sorted_testings = @computer.testings
		@testing = @sorted_testings[@testing_number]			
		count = params[:count].to_i()
	
		prn = '/dev/ttyS0'
		srv = 'checker'
		
		options = {}
		options[:name] = @computer.model.name
		options[:copies] = count
		options[:components] = []
		options[:serial] = @computer.serial_no
		options[:date] = @computer.manufacturing_date.strftime("%d.%m.%Y") if @computer.manufacturing_date
		options[:docno] = @computer.order.buyer_order_number if @computer.order
		options[:qc] = @computer.checker

		if params[:commit] == 'Print'
			if params[:raw]
				@testing.custom_sticker = params[:raw] 
				@testing.save!
				options[:components] = @testing.custom_sticker.split("\n").collect() { |s| s.chomp }
			else
				@testing.components.collect { |c| c.model }.inject({}) { |h, m| h[m] = h[m] ? h[m] + 1 : 1 unless m.short_name.blank? ; h }.collect { |k, v| { :name => k.short_name, :count => v, :model => k  } }.sort() { |q, w| a = q[:model] ; b = w[:model] ; (z = ((a.group ? a.group.name : '') <=> (b.group ? b.group.name : ''))) == 0 ? q[:name] <=> w[:name] : z }[0..14].inject(1) { |i, y| options[:components] << sprintf("%2s %-4s %-32s  %s", i, y[:model].group ? y[:model].group.name : '', y[:name], y[:count]) ; i + 1 }
			end
			
			sticker = Stickercompat.new(options)
			sticker.send_to_printer(srv, prn)
						
			#if sticker.send_to_printer(srv, prn)
				flash[:notice] = "Sent sticker to printer <strong class='printer'>#{srv}:#{prn}</strong>"
			#else
			#	flash[:error] = "Printer <strong class='printer'>#{srv}:#{ prn }</strong> reported errors."
			#end
		end
		redirect_to(:action => 'sticker', :id => params[:id], :count => count.to_s(), :testing => @testing_number)
	end

	def print_sticker_profile
		lib = Sticker::Library.new
		@profiles = lib.by_scope('computer')
		@profile = @profiles[DEFAULT_STICKER_PROFILE_FIXME]
		if @profile
			prepare_computer_and_testing
	                @copies = params[:count].to_i 
			print_sticker(DEFAULT_STICKER_PROFILE_FIXME, @copies)
			flash[:notice] = "Sent sticker to printer <strong class='printer'>#{@profile.printers.first.class}</strong>"
		else
			flash[:error] = "Profile not specified"
		end
		redirect_to(:action => 'sticker', :id => params[:id], :count => @copies.to_s(), :testing => @testing_number)
	end

	def print_warranty
		lib = Sticker::Library.new
		@profiles = lib.by_scope('computer')
		@profile = @profiles['Гарантийный талон']
		raise 'Profile not found' unless @profile
		prepare_computer_and_testing
		@sticker = render_sticker('Гарантийный талон', 1)
		render :text => @sticker
	end

	def create_iso
		prepare_computer_and_testing
		out = `ssh checker \"/srv/generate_drivers_iso/generate_mount #{params[:id]} /srv/iso \\\"#{@computer.model.name}\\\"\"`
		render :text => "<html><body><pre>#{out}</pre></body></html>"
#		redirect_to(:action => 'sticker', :id => params[:id], :count => @copies.to_s(), :testing => @testing_number)
	end

	def log
		prepare_computer_tabs
		render(:layout => 'computer_tabs')
	end

	def mark
		prepare_computer_tabs
		@marks = Mark.by_testing(@testing)
		render(:layout => 'computer_tabs')
	end

	def graph
		prepare_computer_tabs
	
		respond_to { |format|
			format.html {
				render(:layout => 'computer_tabs')
			}
			format.png {
				png_file = Tempfile.new('graph_png')
				monitoring_ids = Graph.find_all_by_testing_id(@testing, :select => 'DISTINCT monitoring_id').map{ |x| x[:monitoring_id] }
				plot_script = "set terminal png size 800, #{monitoring_ids.size * 300}
set output \"#{png_file.path}\"
set multiplot layout #{monitoring_ids.size}, 1
set xdata time
set timefmt \"%s\""

				data_files_hash = {}

				monitoring_ids.each do |monitoring_id|
					uniq_keys = Graph.find_all_by_testing_id_and_monitoring_id(@testing, monitoring_id, :select => 'DISTINCT graphs.key').map{ |x| x[:key] }
					data_files_hash[monitoring_id] = {} if data_files_hash[monitoring_id].nil?
					uniq_keys.each{ |key| data_files_hash[monitoring_id][key] = Tempfile.new('data') }
					
					format_x = '%H:%M'
					data_files_hash[monitoring_id].each_pair do |key, data_file|
						x_min = @testing.test_start
						unless (@from_time == 0) or (@to_time == 0)
							cond = ['timestamp >= ? AND timestamp <= ?', Time.at(@from_time), Time.at(@to_time)]
							x_min = @from_time
							if (@to_time - @from_time).round < 500
								format_x = '%H:%M:%S'
							end
						else
							cond = ['timestamp >= ?', x_min]
						end
						
						plot_script += "\nset format x \"#{format_x}\"
set key below box
set grid"						
						
						graphs = Graph.find_all_by_testing_id_and_monitoring_id_and_key(@testing, monitoring_id, key, :conditions => cond, :order => 'timestamp')
						graphs.each{ |x| data_file.puts "#{x.timestamp.to_f + 14400}\t#{x.value}" }
					end
					
					data_files_hash[monitoring_id].each_pair{ |k, f| f.flush }

					line_title = (($MONITORINGS.find{|x| x[1][:id] == monitoring_id }||[])[1]||{})[:measurement]
					plot_title = (($MONITORINGS.find{|x| x[1][:id] == monitoring_id }||[])[1]||{})[:name]
					
					line_title = 'ln_ttl' unless line_title
					plot_title = 'plt_ttl' unless plot_title
					plot_string = "set title \"#{plot_title}\"\n" + 'plot ' + data_files_hash[monitoring_id].map{ |x| "'#{x[1].path}' using 1:2 title \"#{line_title} #{x[0]}\" with lines" }.join(', ')
					plot_script += "\n"
					plot_script += plot_string
					plot_script += "\n"									
				end
				
				chart_file = Tempfile.new('chart')
				chart_file.puts(plot_script)
				chart_file.flush

				system("gnuplot #{chart_file.path}")
				send_file(png_file.path, :type => 'image/png')

#				data_file.close!
#				chart_file.close!
#				png_file.close!
			}
		}
	end

	def ssh
		prepare_computer_tabs
		render(:layout => 'computer_tabs')
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
		variance = 0
		d.root.each_element { |c|
			components << {
				:type => c.elements['type'] && c.elements['type'].text || '',
				:vendor => c.elements['vendor'] && c.elements['vendor'].text || '',
				:model => c.elements['model'] && c.elements['model'].text || '',
				:serial => c.elements['serial'] && c.elements['serial'].text || '',
				:variance => variance += 1
			} if c.elements['model'].text || c.elements['vendor'].text
		}
		if need_new_testing(@computer.testings.last, components)
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
				format.xml { render(:xml => @computer.testings.last.to_xml()) }
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
				format.xml { head(:status => 200) }
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
		raise "Event not supported: #{ event }." unless [:start, :finish, :fail, :require_attention, :dismiss_attention].include?(event)
		testing = @computer.testings.last
		stage = testing.testing_stages.last
		case event
		when :start
			testing.testing_stages << TestingStage.new(:start => Time.new(), :comment => comment, :stage => name)
			z = testing
		when :finish, :fail
			stage.comment = comment
			stage.end = Time.new
			stage.result = (event == :finish) ? TestingStage::FINISHED : TestingStage::FAILED
			z = stage
		when :require_attention
			stage.end = Time.new
			stage.result = TestingStage::ATTENTION
			z = stage
		when :dismiss_attention
			stage.accumulated_idle += Time.new - stage.end
			stage.end = nil
			stage.result = TestingStage::RUNNING
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
		testing = @computer.testings.last
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
			@testing ? @testing.profile.xml : @computer.profile.xml,
			prev_testing ? prev_testing.testing_stages : [],
			@testing ? @testing.testing_stages : [],
			prev_testing ? prev_testing.components : nil,
			@testing ? @testing.components : nil,
			false,
			prev_testing ? prev_testing.profile_id : nil,
			@testing ? @testing.profile_id : nil
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

	def monitoring_submit_multiple
		@testing = Computer.find(params[:id]).last_testing
		@monitoring_id = params[:monitoring_id].to_i

		params[:monitoring_data].each_line { |l|
			key, timestamp, value = l.split(/,/)

			g = Graph.new(
				:testing => @testing,
				:monitoring_id => @monitoring_id,
				:timestamp => Time.at(timestamp.to_i),
				:key => key,
				:value => value
			)
			g.save!
		}
		head(:status => 200)
	end

	def destroy
		Computer.find(params[:id]).destroy
		redirect_to :action => 'list'
	end

	def boot_from_image
		image = params[:image]
		@computer = Computer.find(params[:id])
		@testing = @computer.last_testing

		@macs = Component.find(:all, :include => :model, :conditions => ['testing_id=? AND component_group_id=?', @testing.id, ComponentGroup.find_by_name('NIC')]).map { |x| x.serial }
		@macs.collect! { |mac| mac.gsub(/:/,'-') }

		to_delete = @macs.collect { |mac| "pxelinux.cfg/01-" + mac }.join(" ")
		add_options = File.size("#{TFTP_DIR}/firmwares/#{image}") == 16777216 ? "floppy c=16 s=32 h=64" : ""

		@macs.each { |mac|
			cfgfile = File.new("#{TFTP_DIR}/pxelinux.cfg/01-#{mac}", "w")
			cfgfile.puts <<__EOF__
##{to_delete}
default firmware
label firmware
 kernel memdisk
 append initrd=firmwares/#{image} #{add_options}
__EOF__
			cfgfile.close
		}

		head(:status => 200)
	end

	def get_needed_firmwares_list
		@computer = Computer.find(params[:id])
		@testing = @computer.last_testing
		@components = Component.find_all_by_testing_id(@testing.id)
		@firmwares=""
		@components.each { |com|
			Firmware.find_all_by_component_model_id(com.component_model_id).each { |fw|
				group=ComponentGroup.find_by_id(ComponentModel.find_by_id(com.component_model_id).component_group_id).name
				@firmwares+="#{group}::#{fw.version}::#{fw.image}\n"
			}
		}
		render :text => @firmwares
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

	def update_profile
		prepare_computer_and_testing
		@computer.profile_id = params[:profile][:id]
		@computer.save!
		redirect_to :action => 'hw', :id => params[:id], :testing => @testing_number
	end

	def comment_edit
		prepare_computer_tabs
		@num = params[:num]
		@comment = @computer_stages[params[:num].to_i][:entity].comment
		render(:layout => 'computer_plain')
	end

	def comment_update
		prepare_computer_tabs
		cs = @computer_stages[params[:num].to_i][:entity]
		cs.comment = params[:comment]
		cs.comment_by = current_person
		cs.save!
		redirect_to :action => 'hw', :id => params[:id], :testing => @testing_number
	end

	def comment_history
		prepare_computer_tabs
		@stage = @computer_stages[params[:num].to_i][:entity]
		render(:layout => 'computer_plain')
	end

	private
	
	RESULT_MAPPING = {
		TestingStage::RUNNING => 'running',
		TestingStage::FINISHED => 'finished',
		TestingStage::FAILED => 'failed',
		TestingStage::HANGING => 'hanging',
		TestingStage::ATTENTION => 'attention',
	}
	
	def prepare_computer_tabs
		prepare_computer_and_testing

		@profiles = Profile.list_for_model(@computer.model_id).map { |x| [x.name, x.id] }

		now = Time.new
		@computer_stages = (@computer.computer_stages + (@computer.order ? @computer.order.order_stages.find_all { |stage| stage.stage != 'manufacturing' } : [])).inject([]) do |a, stage|
			a << {
				:stage => stage.stage, :person => stage.person,
				:start => stage.start,
				:end => stage.end,
				:elapsed => (stage.end || now) - (stage.start || now),
				:overdue => stage.default_timespan ? (stage.end || now) - (stage.start || now) > stage.default_timespan : false,
				:comment => stage.comment,
				:status => (stage.start.blank? || stage.start > now) ? :planned : stage.end ? :finished : :running,
				:entity => stage,
			}
		end.sort { |a, b| (a[:start] ? a[:start].to_f : 0) <=> (b[:start] ? b[:start].to_f : 0) }

		['ordering', 'warehouse', 'acceptance', 'assembling', 'testing', 'checking', 'packaging'].each do |stage_name|
			unless @computer_stages.find { |stage| stage[:stage] == stage_name }
				@computer_stages << { :stage => stage_name, :status => :planned }
			end
		end

		return if @sorted_testings.empty?
		prev_testing = @sorted_testings[@testing_number - 1]

		# Completed or running stages
		@stages = @testing.testing_stages.sort { |a, b| a.start <=> b.start }.collect { |stage|
			{
				:id => stage.stage,
				:elapsed => ((stage.end || Time.new()) - stage.start - stage.accumulated_idle).round,
				:finished => (stage.end || Time.new),
				:started => stage.start + stage.accumulated_idle,
				:result => RESULT_MAPPING[stage.result] || 'unknown',
				:comment => (RESULT_MAPPING[stage.result] || 'unknown') + (stage.comment ? ": #{stage.comment}" : ''),
			}
		}

		# Planned stages
		if @testing.profile
			pl = Planner.new(@testing.profile.xml, @testing.testing_stages, prev_testing.testing_stages, @testing.components, prev_testing.components, true, @testing.profile_id, prev_testing.profile_id)
			pl.plan.each { |stage|
				@stages << {
					:id => stage.id,
					:result => 'planned',
					:comment => 'planned'
				}
			}
		end
		
	end

	def prepare_computer_and_testing
		@computer = Computer.find(params[:id])
		@sorted_testings = @computer.testings
		if @sorted_testings.empty?
			@testing_number = 0
			return
		end
		@testing_number = params[:testing] ? params[:testing].to_i() : @sorted_testings.size - 1
		@testing = @sorted_testings[@testing_number]
		
		@from_time = params[:from].to_f if params[:from]
		@to_time = params[:to].to_f if params[:to]
	end

	def dump_comparison(comparison)
		Marshal.dump(comparison)
	end

	def load_comparison(str)
		Marshal.load(str)
	end

	# Decide if we have to open new testing or we can continue the last one
	def need_new_testing(testing, components)
		return true unless testing
		return true unless testing.components.size == components.size
		return true unless testing.profile_id == @computer.profile_id
		return true if testing.close_hanging

		ccp = components.dup
		return true unless testing.components.inject(true) { |b, cmp|
			b && ccp.delete(ccp.find() { |h|
				(h[:vendor] == cmp.model.vendor && h[:model] == cmp.model.name) || (!h[:serial].blank? && h[:serial] == cmp.serial)
			})
		}
		return false
	end
end
