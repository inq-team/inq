class FirmwaresController < ApplicationController

	layout 'orders'

	def index
		@firmwares = Firmware.find(:all)
	end

	def show
		@firmware = Firmware.find(params[:id])
	end

	def new
		@firmware = Firmware.new
	end

	def edit
		@firmware = Firmware.find(params[:id])
	end

	def create
		@firmware = Firmware.new(params[:firmware])

		if @firmware.save
			flash[:notice] = 'Firmware was successfully created.'
			redirect_to :action => 'index'
		else
			render :action => 'new'
		end
	end

	def update
		@firmware = Firmware.find(params[:id])

		if @firmware.update_attributes(params[:firmware])
			flash[:notice] = 'Firmware was successfully updated.'
			redirect_to :action => 'index'
		else
			render :action => 'edit'
		end
	end

	def destroy
		@firmware = Firmware.find(params[:id])
		@firmware.destroy

		redirect_to :action => 'index'
	end

	def live_component
		computer = Computer.find_by_id(params[:computer])
		@components = computer ? computer.last_testing.components.collect { |x| [x.model.name, x.model.id] } : []
		render(:layout => false)
	end
end
