class ComputersController < ApplicationController
	def index
		archive
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],
#	       :redirect_to => { :action => :archive }

	def archive
		@computer_pages, @computers = paginate :computers, :per_page => 20
		render :action => 'list'
	end

	def latest
		@computer = Computer.find(params[:id])
		@testing = @computer.testings[-1]
		@components = @testing.components
		respond_to { |format|
			format.html { render :action => 'testing' }
			format.xml  { render :xml => @computer.to_xml }
		}
	end

	def testing
		@computer = Computer.find(params[:id])
		@testing = Testing.find(params[:testing_id])
		respond_to { |format|
			format.html { render :action => 'testing' }
			format.xml  { render :xml => @testing.to_xml(:include => :components) }
		}
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

	def set_assembler
		@computer = Computer.find(params[:id])
		@computer.assembler_id = params[:assembler_id]
		@computer.assembling_start = Time.now
		@computer.save!
		head :ok
	end

	def set_tester
		@computer = Computer.find(params[:id])
		@computer.tester_id = params[:tester_id]
		@computer.save!
		head :ok
	end

	def update
		@computer = Computer.find(params[:id])
		puts params[:id]
		p params[:computer]
		if @computer.update_attributes(params[:computer])
			flash[:notice] = 'Computer was successfully updated.'
			format.html { redirect_to :action => 'show', :id => @computer }
			format.xml  { head :ok }
		else
			format.html { render :action => 'edit' }
			format.xml  { render :xml => @computer.errors.to_xml }
		end
	end

	def submit_components
		@computer = Computer.find(params[:id])
		d = REXML::Document.new(params[:list])
		components = []
		d.root.each_element { |c|
			components << {
				:type => c.elements['type'] ? c.elements['type'].text : '',
				:vendor => c.elements['vendor'] ? c.elements['vendor'].text : '',
				:model => c.elements['model'] ? c.elements['model'].text : '',
				:serial => c.elements['serial'] ? c.elements['serial'].text : ''
			}
		}
		p components
	end

	def destroy
		Computer.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
