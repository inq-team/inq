class ComputersController < ApplicationController
	def index
		archive
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
	       :redirect_to => { :action => :archive }

	def archive
		@computer_pages, @computers = paginate :computers, :per_page => 20
		render :action => 'list'
	end

	def latest
		@computer = Computer.find(params[:id])
		@testing = @computer.testings[-1]
		render :action => 'testing'
	end

	def testing
		@computer = Computer.find(params[:id])
		@testing = Testing.find(params[:testing_id])
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

  def update
    @computer = Computer.find(params[:id])
    if @computer.update_attributes(params[:computer])
      flash[:notice] = 'Computer was successfully updated.'
      redirect_to :action => 'show', :id => @computer
    else
      render :action => 'edit'
    end
  end

  def destroy
    Computer.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
