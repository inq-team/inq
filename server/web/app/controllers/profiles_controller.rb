class ProfilesController < ApplicationController
	def index
		@profiles = Profile.find(:all)
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
               :redirect_to => { :action => :list }

	def show
		@profile = Profile.find(params[:id])
	end

	def new
		@profile = Profile.new
	end

	def create
		@profile = Profile.new(params[:profile])
		if @profile.save
			flash[:notice] = 'Profile was successfully created.'
			redirect_to :action => 'index'
		else
			render :action => 'new'
		end
	end

	def edit
		@profile = Profile.find(params[:id])
	end

	def update
		@profile = Profile.find(params[:id])
		if @profile.update_attributes(params[:profile])
			flash[:notice] = 'Profile was successfully updated.'
			redirect_to :action => 'show', :id => @profile
		else
			render :action => 'edit'
		end
	end

	def destroy
		Profile.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
