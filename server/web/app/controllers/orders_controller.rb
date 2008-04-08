require 'mykit/components'

class OrdersController < ApplicationController
	auto_complete_for :order, :manager
	auto_complete_for :order, :customer
	enable_sticker_printing

	# GET /orders
	# GET /orders.xml
	def index
		@selected_manager = params[:manager][:name] if params[:manager]
		@managers = Order.find_by_sql('SELECT DISTINCT manager FROM orders').map { |x| x.manager }
		@staging = Order.staging(@selected_manager)
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
		@computers = @order.computers
		@computer_stage_order = ['assembling', 'testing', 'checking', 'packaging']
		@st_comp_qty = @computer_stage_order.inject({}) do |h, stage|
			h.merge({ stage => @computers.find_all { |c| s = c.last_computer_stage ; s && (s.stage == stage) && s.end.blank? }.size })
		end

		@qty = @computers.size

                if @qty == 0 then
                        @models = Model.find(:all, :order => :name).map { |x| [x.name, x.id] }

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
                end

                now = Time.new
                @order_stages = @order.order_stages.find_all { |s| s.stage != 'manufacturing' }.inject([]) do |a, stage|
                        a << {  :stage => stage.stage, :person => stage.person,
                                :start => stage.start,
                                :end => stage.end, :elapsed => (stage.end || now) - (stage.start || now),
				:overdue => (stage.end || now) - (stage.start || now) > stage.default_timespan,
                                :comment => stage.comment, :status => (stage.start.blank? || stage.start > now) ? :planned : stage.end ? :finished : :running
                        }
                end.sort { |a, b| (a[:start] ? a[:start].to_f : 0) <=> (b[:start] ? b[:start].to_f : 0) }

                ['ordering', 'warehouse', 'acceptance'].each do |stage_name|
                        unless @order_stages.find { |stage| stage[:stage] == stage_name }
                                @order_stages << { :stage => stage_name, :status => :planned }
                        end
                end 

		['assembling', 'testing', 'checking', 'packaging'].each do |stage| 
			testing = @computers.find_all { |c| s = c.last_computer_stage ; s && s.stage == stage && s.end.blank? }
			done = @computers.find_all { |c| c.computer_stages.find_by_stage(stage, :conditions => "end is not null") }
			count = testing.size
			passed = done.size
			h = { :stage => stage, :progress => { :value => count > 0 ? count : passed, :total => @qty },
                                :status => @qty == 0 ? :planned : passed == @qty ? :finished : count == 0 ? :planned : :running
                        }
			h.delete(:progress) if [:planned, :finished].include?(h[:status])
			h[:blank] = 0 if h[:status] == :finished
			h[:computer_list] = { :computers => testing, :detail => :computer_stage } if h[:status] == :running
			@order_stages << h
                end

		respond_to do |format|
			format.html # show.rhtml
			format.xml  { render :xml => @order.to_xml(:include => [:order_lines, :manager]) }
		end
	end

	def computer_stickers
		@order = Order.find(params[:id])
		if(Object.const_defined?('DEFAULT_SERIAL_STICKER_PROFILE_FIXME'))
	                @order.computers.each do |comp|
				@computer = comp
				print_sticker(DEFAULT_SERIAL_STICKER_PROFILE_FIXME, 2)
			end
			flash[:notice] = "Stickers sent to #{ Sticker::Library.new.profiles[DEFAULT_SERIAL_STICKER_PROFILE_FIXME].printers.first.class }" 
		else
			flash[:error] = "Misconfiguration issue"
		end
		redirect_to :action => :show, :id => @order.id
	end

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
			c.save!
		end
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
		p params[:order]
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
		@items = lines.collect { |l| MyKit::Item.new(l.name) }
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
		@items = lines.inject({}) { |h, l| h.merge({ l => MyKit::Parser.parse(l.name) }) }
	end

	def live_profile
		@profiles = Profile.list_for_model(params[:model]).map { |x| [x.name, x.id] }
                render(:layout => false)
	end
	
	def update_computers
		@profile = Profile.find(params[:profile][:id]) if params[:profile][:id].to_i != 0
		@model = Model.find(params[:model][:id]) if params[:model][:id].to_i != 0
		@order = Order.find(params[:id])
		
		comps= params.to_a.select{ |x| x[0].to_s =~ /comp_[\d]+/ && x[1]['update'] == '1' }.map{ |x|  Computer.find_by_id(x[0].gsub(/comp_/, '').to_i) }
		comps.each do |c|
			c.model = @model if @model
			c.profile = @profile if @profile
			c.save!
		end
		
		redirect_to :action => 'show', :id => params[:id]
	end
	
	def search
		# Prepare and parse form parameters
		@computer_serial = params[:computer_serial] if params[:computer_serial] and not params[:computer_serial].empty?
		@customer = params[:order][:customer].to_s if params[:order] and params[:order][:customer] and not params[:order][:customer].empty?
		@number = params[:number].to_s if params[:number] and not params[:number].empty?
		@manager = params[:order][:manager].to_s if params[:order] and params[:order][:manager] and not params[:order][:manager].empty?
		@model_id = params[:model][:id].to_i if params[:model] and params[:model][:id] and params[:model][:id].to_i != 0
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

		# Execute the search query, if available
		cond_var = {
			:manager => "%#{@manager}%",
			:customer => "%#{@customer}%",
			:order_number => @number,
			:computer_serial => @computer_serial,
			:model_id => @model_id,
			:start_date => @start_date,
			:end_date => @end_date,
		}

		cond = []
		cond << 'manager LIKE :manager' if @manager
		cond << 'customer LIKE :customer' if @customer
		cond << 'buyer_order_number=:order_number' if @number
		cond << 'computers.id=:computer_serial' if @computer_serial
		cond << 'computers.model_id=:model_id' if @model_id
		cond << '(order_stages.start >= :start_date OR computer_stages.start >= :start_date)' if @start_date
		cond << '(order_stages.start <= :end_date OR computer_stages.start <= :end_date)' if @end_date

		if cond.size > 0
			@orders = Order.find(
				:all,
				:conditions => [cond.join(' AND '), cond_var],
				:include => [:order_stages, { :computers => :computer_stages }],
				:order => 'order_stages.start'
			)
			redirect_to :action => 'show', :id => @orders[0] if @orders.size == 1
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
