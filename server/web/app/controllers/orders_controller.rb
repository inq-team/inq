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
		ids = Order.find_by_sql("select distinct computers.order_id as id from computers left join testings on testings.computer_id = computers.id where computers.order_id is not null and testings.id is not null").collect { |o| o.id }
		@orders = Order.find(*ids)
	end


	# GET /orders/1
	# GET /orders/1.xml
	def show
		@order = Order.find(params[:id])
		@computers = Computer.find_all_by_order_id(params[:id])
		@st_comp_qty = {}
		
		[:assembling, :testing, :packing].each do |st|
			stage_comp = @computers.select do |c|
				if c.computer_stages.size > 0
					(s = c.computer_stages.select{ |s| s.end == nil }[0]) ? s.stage == st.to_s : false
				else
					false
				end
			end
			@st_comp_qty[st] = stage_comp.size
		end
		
		@qty = @computers.size
		@models = Model.find(:all).map{ |x| x.name }
		@default_qty = @order.order_lines.map{ |x| x.qty }.min
		@profiles = Profile.find(:all).map{ |x| x.id }
		@start_id = Computer.find_by_sql('SELECT MAX(id)+1 FROM computers')[0]['MAX(id)+1'].to_i
		@end_id = @start_id + @default_qty - 1

		@order_title = @order.title.gsub(/(\d)(S(A|C))/){$1}.gsub(/(\d)(G(2|3))/){$1 + ' ' + $2}
		model_names = Model.find_by_sql(['SELECT name FROM models WHERE MATCH(name) AGAINST(?);', @order_title]).sort{ |a,b| a.name <=> b.name }.map{ |x| x.name }
		@default_model = nil

		if model_names.size > 0
			[/G2/, /G3/].each do |g|
				if @order_title =~ g
					model_names.each do |name|
						if name =~ g
							@default_model = name
							break
						end
					end
				end
			end
		end

		if (@default_model == nil) && (model_names.size > 0)
			@default_model = model_names[0]
		end

#		@computers = []
		respond_to do |format|
			format.html # show.rhtml
			format.xml  { render :xml => @order.to_xml(:include => [:order_lines, :manager]) }
		end
	end

	def create_computers
		model = params[:model][:name]
		profile_id = params[:profile][:id]
		start_id = params[:new_computers][:start_id].to_i
		end_id = params[:new_computers][:end_id].to_i
		
		if (start_id > end_id) || ((start_id..end_id).to_a.map{ |i| Computer.find_by_id(i) }.compact.size > 0)
			flash[:notice] = 'Incorrect indexes'
			redirect_to :action => 'show'
			return
		end		
		
		(start_id..end_id).to_a.each do |id|
			c = Computer.new
			c.id = id
			c.model = Model.find_by_name(model)
			c.order_id = params[:id]
			c.profile = Profile.find_by_id(profile_id)
			c.save!
		end
		redirect_to :action => 'show'				
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
		ids = Order.find_by_sql("select distinct computers.order_id as id from computers left join testings on testings.computer_id = computers.id where computers.order_id is not null and testings.id is not null").collect { |o| o.id }
		@orders = Order.find(*ids)
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
		ids = Order.find_by_sql("select distinct computers.order_id as id from computers left join testings on testings.computer_id = computers.id where computers.order_id is not null and testings.id is not null").collect { |o| o.id }
		@orders = Order.find(*ids)
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

end
