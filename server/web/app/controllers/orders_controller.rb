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
#		@computers = []
		respond_to do |format|
			format.html # show.rhtml
			format.xml  { render :xml => @order.to_xml(:include => [:order_lines, :manager]) }
		end
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
