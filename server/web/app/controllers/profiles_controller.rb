require 'rexml/document'

class ProfilesController < ApplicationController
	def index
		@profiles = Profile.find(:all).reject { |p| p.deleted? }
	end

	def index_all
		@profiles = Profile.find(:all)
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
               :redirect_to => { :action => :list }

	def show
		@profile = Profile.find(params[:id])
#		@text = PrettyXML.make(REXML::Document.new(@profile.xml)).gsub(/^\n\n/, '')
		@text = ''
		REXML::Document.new(@profile.xml, { :compress_whitespace => :all }).write(@text, 0)
		@text.gsub!(/\'/, "\"")
	end

	def new
		@profile = Profile.new
		@models = Model.find(:all, :order => :name).map { |x| [x.name, x.id] }.unshift(['', nil])
		@default_model_id = @profile.model ? @profile.model.id : nil
	end

	def create
		@profile = Profile.new
		@profile.xml = params[:profile][:xml]
		@profile.feature = params[:profile][:feature]
 		@profile.model_id = params[:model][:id]
		@profile.timestamp = Time.now		
		@models = Model.find(:all, :order => :name).map { |x| [x.name, x.id] }.unshift(['', nil])
		@default_model_id = @profile.model ? @profile.model.id : nil
	
		if params[:profile][:xml].blank?
			flash[:notice] = 'Empty XML'
			if params[:id]
				render :action => 'edit', :id => params[:id]
			else
				render :action => 'new'
			end
			return
		end

		begin
			REXML::Document.new(params[:profile][:xml])
		rescue REXML::ParseException
			flash[:notice] = 'Wrong XML'
			if params[:id]
				render :action => 'edit', :id => params[:id]
			else
				render :action => 'new'
			end
			return
		end

		if @profile.save!
			flash[:notice] = 'Profile was successfully created.'
			redirect_to :action => 'index'
		else
			if params[:id]
				render :action => 'edit', :id => params[:id]
			else
				render :action => 'new'
			end
		end
	end

	def edit
		@profile = Profile.find(params[:id])
		@models = Model.find(:all, :order => :name).map { |x| [x.name, x.id] }.unshift(['', nil])
		@default_model_id = @profile.model ? @profile.model.id : nil
	end

	def delete
		profile = Profile.find(params[:id])
		profile.is_deleted = true
		if profile.save!
			flash[:notice] = 'Profile was successfully marked as deleted.'
		end
		redirect_to :action => 'index'
	end
end
