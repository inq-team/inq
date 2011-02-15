class OrdersController < ApplicationController
	auto_complete_for :order, :manager
	auto_complete_for :order, :customer
	enable_sticker_printing

	before_filter :login_required, :except => [ :index, :show, :search ]

	# GET /orders
	# GET /orders.xml
	def index
		@selected_manager = params[:manager][:name] if params[:manager]
		@managers = Order.find_by_sql('SELECT DISTINCT manager FROM orders').map { |x| x.manager }
		@staging = Order.staging(@selected_manager)
		@autorefresh = true
	end

	def staging
		@staging = Order.staging
	end

	def testings
		@orders = Order.with_testings
	end

	# GET /orders/1
	# GET /orders/1.xml
	def show
		@order = Order.find(params[:id])
		@computers = Computer.find_all_by_order_id(@order.id, :include => [:model, :profile, :computer_stages], :order => 'computers.id, computer_stages.start')

		@profiles = Profile.find(:all, :order => 'timestamp').reject { |p| p.deleted? }.map{ |p| [p.name, p.id] }.unshift(['--', 0])
		@models = Model.find(:all, :order => :name).map { |x| [x.name, x.id] }

		@qty = @computers.size

		if @qty == 0 then
                        # Guess quantity of computers to create
                        @default_qty = @order.order_lines.map { |x| x.qty }.min
                        @default_qty = 1 if @default_qty.nil?

                        # Start and end of ID range
                        @start_id = Computer.free_id
                        @end_id = @start_id + @default_qty - 1

                        # Try to guess default creation model from order
                        @order_title = @order.title.to_s.gsub(/(\d)(S(A|C))/){$1}.gsub(/(\d)(G(2|3))/){$1.to_s + ' ' + $2.to_s}
                        model_names = Model.find_by_sql(['SELECT id, name FROM models WHERE MATCH(name) AGAINST(?) ORDER BY name;', @order_title]).map { |x| [x.name, x.id] }
                        @default_model = nil

                        if model_names.size > 0
                                [/G2/, /G3/].each { |g|
                                        if @order_title =~ g
                                                model_names.each { |m|
                                                        if m[0] =~ g
                                                                @default_model = m[1]
                                                                break
                                                        end
                                                }
                                        end
                                }
                        end

                        @default_model = model_names[0][1] if (@default_model == nil) && (model_names.size > 0)

                        # Prepare profiles list
                        @profiles = Profile.list_for_model(@default_model).map { |x| [x.name, x.id] }
		else
			@models = @models.unshift(['--', 0])
                end

		# ==============================================================
		# Prepare stages progress bar
		# ==============================================================

		# Existing order stages
                now = Time.new
                @order_stages = @order.order_stages.find_all { |s| s.stage != 'manufacturing' }.inject([]) do |a, stage|
			aa = {
				:stage => stage.stage, :person => stage.person,
                                :start => stage.start,
                                :end => stage.end, :elapsed => (stage.end || now) - (stage.start || now),
                                :comment => stage.comment, :status => (stage.start.blank? || stage.start > now) ? :planned : stage.end ? :finished : :running
                        }
			aa[:overdue] = (stage.end || now) - (stage.start || now) > stage.default_timespan if stage.default_timespan
			a << aa
                end.sort { |a, b| (a[:start] ? a[:start].to_f : 0) <=> (b[:start] ? b[:start].to_f : 0) }

		# Planned order stages
		['ordering', 'warehouse', 'acceptance'].each { |stage_name|
			@order_stages << {
				:stage => stage_name,
				:status => :planned
			} unless @order_stages.find { |stage| stage[:stage] == stage_name }
		}

		# Calculate computer stage breakup
		in_progress_by_stage = {}
		done_by_stage = {}
		@computers.each { |c|
			unique_cs = []
			c.computer_stages.each { |st|
				next if unique_cs.include?(st.stage)
				in_progress_by_stage[st.stage] ||= 0
				done_by_stage[st.stage] ||= 0
				st.end ? done_by_stage[st.stage] += 1 : in_progress_by_stage[st.stage] += 1
				unique_cs << st.stage
			}
		}

		# Computer stages
		['assembling', 'testing', 'checking', 'packaging'].each { |stage|
			h = { :stage => stage }
			if done_by_stage[stage] == @qty
				h[:status] = :finished
			elsif in_progress_by_stage[stage] and in_progress_by_stage[stage] > 0
				h[:status] = :running
				h[:progress] = "#{in_progress_by_stage[stage]} / #{@qty}"
			elsif done_by_stage[stage] and done_by_stage[stage] > 0
				h[:status] = :running
				h[:progress] = "#{done_by_stage[stage]} / #{@qty}"
			else
				h[:status] = :planned
			end
			@order_stages << h
		}

		respond_to do |format|
			format.html # show.rhtml
			format.xml  { render :xml => @order.to_xml(:include => [:order_lines, :manager]) }
		end
	end

#	def computer_stickers
#		@order = Order.find(params[:id])
#		if(Object.const_defined?('DEFAULT_SERIAL_STICKER_PROFILE_FIXME'))
#	                @order.computers.each do |comp|
#				@computer = comp
#				print_sticker(DEFAULT_SERIAL_STICKER_PROFILE_FIXME, 2)
#			end
#			flash[:notice] = "Stickers sent to #{ Sticker::Library.new.profiles[DEFAULT_SERIAL_STICKER_PROFILE_FIXME].printers.first.class }" 
#		else
#			flash[:error] = "Misconfiguration issue"
#		end
#		redirect_to :action => :show, :id => @order.id
#	end

	def create_computers
		model_id = params[:model][:id]
		profile_id = params[:profile][:id]
		start_id = params[:new_computers][:start_id].to_i
		end_id = params[:new_computers][:end_id].to_i

		if (start_id > end_id) || ((start_id..end_id).to_a.map{ |i| Computer.find_by_id(i) }.compact.size > 0)
			flash[:notice] = 'Incorrect indexes'
			redirect_to :action => 'show', :id => params[:id]
			return
		end		

		(start_id..end_id).to_a.each do |id|
			c = Computer.new
			c.id = id
			c.model_id = model_id
			c.order_id = params[:id]
			c.profile_id = profile_id
			c.computer_stages << ComputerStage.new(:stage => 'assembling', :start => Time.new)
			c.save!
		end

		OrderStage.find_all_by_order_id_and_stage(params[:id], 'acceptance').each { |os|
			os.end = Time.new
			os.save!
		}

		redirect_to :action => 'show', :id => params[:id]
	end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1;edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        format.html { redirect_to order_url(@order) }
        format.xml  { head :created, :location => order_url(@order) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors.to_xml }
      end
    end
  end

	# PUT /orders/1
	# PUT /orders/1.xml
	def update
		@order = Order.find(params[:id])
		respond_to do |format|
			if @order.update_order(params[:order])
				flash[:notice] = 'Order was successfully updated.'
				format.html { redirect_to order_url(@order) }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @order.errors.to_xml }
			end
		end
	end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.xml  { head :ok }
    end
  end

	def items
		@orders = Order.with_testings
		@order = Order.find(params[:id])
		@next_id = @prev_id = nil
		if @orders.include?(@order)
	 		i = @orders.inject(0) { |i, o| break(i) if o == @order; i + 1 }
			@next_id = @orders[i + 1].id if i + 1 < @orders.size 
			@prev_id = @orders[i - 1].id if i > 0 
		end
		
		lines = @order.order_lines
		@items = lines.collect { |l| Mykit::Item.new(l.name) }
	end

	def components
		@orders = Order.with_testings
		@order = Order.find(params[:id])
		@next_id = @prev_id = nil
		if @orders.include?(@order)
	 		i = @orders.inject(0) { |i, o| break(i) if o == @order; i + 1 }
			@next_id = @orders[i + 1].id if i + 1 < @orders.size 
			@prev_id = @orders[i - 1].id if i > 0 
		end
		
		lines = @order.order_lines
		@items = lines.inject({}) { |h, l| h.merge({ l => Mykit::Parser.parse(l.name) }) }
	end

	def live_profile
		@profiles = Profile.list_for_model(params[:model]).map { |x| [x.name, x.id] }
                render(:layout => false)
	end
	
	def handle_computers
		@profile = Profile.find(params[:profile][:id]) if params[:profile][:id].to_i != 0
		@model = Model.find(params[:model][:id]) if params[:model][:id].to_i != 0
		@order = Order.find(params[:id])
		comps= params.to_a.select{ |x| x[0].to_s =~ /comp_[\d]+/ && x[1]['update'] == '1' }.map{ |x|  Computer.find_by_id(x[0].gsub(/comp_/, '').to_i) }
		comps.sort! {|x,y| x.id<=>y.id}

		case params[:commit]
		when /Change/
			comps.each do |c|
				c.model = @model if @model
				c.profile = @profile if @profile
				c.save!
			end
		when /Print labels/
			quantity = params[:labels_quantity].to_i
			if(Object.const_defined?('DEFAULT_SERIAL_STICKER_PROFILE_FIXME') and quantity > 0)
				comps.each do |c|
					@computer = c
					print_sticker(DEFAULT_SERIAL_STICKER_PROFILE_FIXME, quantity)
				end
				flash[:notice] = "Stickers sent to #{ Sticker::Library.new.profiles[DEFAULT_SERIAL_STICKER_PROFILE_FIXME].printers.first.class }" 
			else
				flash[:error] = "Misconfiguration issue"
			end			
		end
		
		redirect_to :action => 'show', :id => params[:id]
	end
	
	def search
		# Prepare and parse form parameters
		@component_serial = params[:component_serial] if params[:component_serial] and not params[:component_serial].empty?
		@computer_serial = params[:computer_serial] if params[:computer_serial] and not params[:computer_serial].empty?
		@customer = params[:order][:customer].to_s if params[:order] and params[:order][:customer] and not params[:order][:customer].empty?
		@number = params[:number].to_s if params[:number] and not params[:number].empty?
		@manager = params[:order][:manager].to_s if params[:order] and params[:order][:manager] and not params[:order][:manager].empty?
		@model_id = params[:model][:id].to_i if params[:model] and params[:model][:id] and params[:model][:id].to_i != 0
		@component_model_id = params[:component_model][:id].to_i if params[:component_model] and params[:component_model][:id] and params[:component_model][:id].to_i != 0
		begin
			@start_date = parse_date((params[:date] || {})[:start], :format => :start_date)
			@end_date = parse_date((params[:date] || {})[:end], :format => :end_date)
			@start_date = nil if @start_date.empty?
			@end_date = nil if @end_date.empty?
		rescue ArgumentError => e
			flash[:notice] = e.to_s
			render :action => 'search'
			return
		end

		# Prepare selection lists
		@models = Model.find(:all, :order => 'name').map { |x| [x.name, x.id] }
		@models.unshift ['', 0]
		@component_models = ComponentModel.find(:all, :order => 'vendor, name').select { |x| x.name.to_s.size > 0 }.map { |x| ["#{x.vendor} #{x.name.to_s[0..20]} (#{x.short_name})", x.id] }
		@component_models.unshift ['', 0]

		# Execute the search query, if available
		cond_var = {
			:manager => "%#{@manager}%",
			:customer => "%#{@customer}%",
			:order_number => @number,
			:computer_serial => @computer_serial.to_i,
			:model_id => @model_id,
			:component_model_id => @component_model_id,
			:start_date => @start_date,
			:end_date => @end_date,
			:component_serial => "%#{@component_serial }%"
		}

		cond = []
		cond << 'manager LIKE :manager' if @manager
		cond << 'customer LIKE :customer' if @customer
		cond << 'buyer_order_number=:order_number' if @number
		cond << 'computers.id=:computer_serial' if @computer_serial
		cond << 'computers.model_id=:model_id' if @model_id
		cond << '(order_stages.start >= :start_date OR computer_stages.start >= :start_date)' if @start_date
		cond << '(order_stages.start <= :end_date OR computer_stages.start <= :end_date)' if @end_date

		if @component_serial
			@computers_by_component_serial = Computer.find_by_sql("SELECT DISTINCT(computers.id) FROM computers INNER JOIN testings ON testings.computer_id=computers.id JOIN components ON components.testing_id=testings.id WHERE components.serial LIKE '%#{ @component_serial }'").collect{ |id| Computer.find_by_id( id ) }
		end

		if cond.size > 0
			@orders = Order.find(
				:all,
				:conditions => [ cond.join(' AND '), cond_var ],
				:include => [ :order_stages, { :computers => :computer_stages }  ],
				:order => 'order_stages.start'
			)

			cond << 'orders.id IS NULL'
			@computers = Computer.find(
				:all,
				:conditions => [ cond.join(' AND '), cond_var ],
				:include => [ { :order => :order_stages}, :computer_stages, { :testings => :components } ],
				:order => 'computer_stages.start'
			)

			if @component_model_id
				computers = Computer.find_by_sql("SELECT computers.* FROM computers INNER JOIN testings ON testings.computer_id=computers.id JOIN components ON components.testing_id=testings.id JOIN component_models ON components.component_model_id=component_models.id WHERE component_models.id=#{@component_model_id}")

				@orders.reject! { |o| computers.select{ |c| o.computers.include? c }.empty? }
				@computers.select! { |c| computers.include? c }
			end
			
			redirect_to :action => 'show', :id => @orders[0] if @orders.size == 1 and @computers.size == 0 and not params[:no_redirect] and not @component_serial
			redirect_to :controller => 'computers', :action => 'show', :id => @computers[0] if @orders.size == 0 and @computers.size == 1 and not params[:no_redirect]
		end
	end

	private
	def parse_date(s, options)
		s = s.to_s
		case s
		when /^(\d{4})-(\d{2})-(\d{2})$/
			s
		when ''
			s
		when /^(\d{4})-(\d{2})$/
			case options[:format]
			when :start_date
				"#{s}-01"
			when :end_date
				"#{s}-12"
			else
				raise ArgumentError.new("unknown format: #{options[:format]}")
			end
		when /^(\d{4})$/
			case options[:format]
			when :start_date
				"#{s}-01-01"
			when :end_date
				"#{s}-12-31"
			else
				raise ArgumentError.new("unknown format: #{options[:format]}")
			end
		else
			raise ArgumentError.new("invalid date: #{s}")
		end
	end
end
