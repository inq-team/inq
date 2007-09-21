class ComponentsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @component_pages, @components = paginate :components, :per_page => 10
  end

  def show
    @component = Component.find(params[:id])
  end

  def new
    @component = Component.new
  end

  def create
    @component = Component.new(params[:component])
    if @component.save
      flash[:notice] = 'Component was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @component = Component.find(params[:id])
  end

  def update
    @component = Component.find(params[:id])
    if @component.update_attributes(params[:component])
      flash[:notice] = 'Component was successfully updated.'
      redirect_to :action => 'show', :id => @component
    else
      render :action => 'edit'
    end
  end

  def destroy
    Component.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
