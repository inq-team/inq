class OrdersController < ApplicationController
	# GET /orders
	# GET /orders.xml
	def index
		@orders = Order.find(:all)
		respond_to do |format|
			format.html # index.rhtml
			format.xml  { render :xml => @orders.to_xml }
		end
	end

	def staging
		@staging = Order.staging
	end

	# GET /orders/1
	# GET /orders/1.xml
	def show
		@order = Order.find(params[:id])
		@computers = Computer.find_all_by_order_id(params[:id])
		@st_comp_qty = {}
		@st_comp_qty[:assembling] = @computers.select{ |c| (c.computer_stages.select{ |s| s.end == nil }[0]).stage == 'assembling' if c.computer_stages.size > 0 }.size
		@st_comp_qty[:testing] = @computers.select{ |c| (c.computer_stages.select{ |s| s.end == nil }[0]).stage == 'testing' if c.computer_stages.size > 0 }.size
		@st_comp_qty[:packing] = @computers.select{ |c| (c.computer_stages.select{ |s| s.end == nil }[0]).stage == 'packing' if c.computer_stages.size > 0 }.size
		@qty = @computers.size
		@models = Model.find_all.map{ |x| x.name }
		@default_qty = @order.order_lines.map{ |x| x.qty }.min
		@profiles = Profile.find_all.map{ |x| x.id }
		@start_id = Computer.find_by_sql('SELECT MAX(id)+1 FROM computers')[0]['MAX(id)+1'].to_i
		@end_id = @start_id + @default_qty - 1

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
			flash[:notice] = 'Incorrect ids'
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
end
