require 'mykit/components'

class OrdersController < ApplicationController
	# GET /orders
	# GET /orders.xml
	def index
		@staging = Order.staging
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
		p params
		@profiles = Profile.list_for_model(params[:model]).map { |x| [x.name, x.id] }
                render(:layout => false)
	end
	
	def search
		unless params[:date].to_s.empty?
			start_date = sprintf("%04d-%02d-%02d", params[:date]['start(1i)'], params[:date]['start(2i)'], params[:date]['start(3i)'])
			end_date = sprintf("%04d-%02d-%02d", params[:date]['end(1i)'], params[:date]['end(2i)'], params[:date]['end(3i)'])
			start_date = (params[:datetime_start][:use] == '1') ? start_date : ''
			end_date = (params[:datetime_end][:use] == '1') ? end_date : ''
			conditions1 = [ [:customer, params[:customer]], [:buyer_order_number, params[:number]] ].select{ |x| not x[1].to_s.empty? }.map{ |x| "#{x[0].to_s} LIKE '%%#{x[1]}%%'" }.join(' AND ')
			dates = [[:start, start_date], [:end, end_date]].select{ |d| not d[1].to_s.empty? }
			conditions2 = ['order_stages.start', 'computer_stages.start'].map { |start|	dates.map{ |d| "#{start}#{d[0]==:start ? '>' : '<'}='#{d[1]}'"}.join(' AND ') }
			conditions2 = conditions2.select{ |x| not x.to_s.empty? }
			conditions2 = conditions2.map{ |s| "(#{s})" }.join(' OR ') if conditions2.size > 1
			conditions = [conditions1, conditions2].select{ |x| not x.to_s.empty? }
			conditions = conditions.map{ |s| "(#{s})" }.join(' AND ') if conditions.size > 1
			conditions = conditions.to_s
			orders = Order.find(:all, :conditions => [conditions, start_date, end_date, start_date, end_date], :include => [:order_stages, { :computers => :computer_stages }])
			@search_result = '<table>'
			orders.each do |z|
				@search_result += "<tr><td><a href=\"/orders/show/#{z.id}\">#{z.customer}, #{z.title}</a></td></tr>"
			end
			@search_result += '</table>'		
		else
			@search_result = ''
		end		
	end
end
