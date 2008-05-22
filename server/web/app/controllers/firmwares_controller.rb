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
		flash[:notice] = 'Unentered parameters will stay default. Previous firmware image will be deleted if another one is going to be uploaded.'
	end

	def create
		@firmware = Firmware.new(params[:firmware])

		orig = @firmware.image.original_filename
		if File.exists?("#{FIRMWARES_DIR}/#{orig}")
			flash[:notice] = 'Such firmware image is already exists.'
			render :action => 'new'
			return
		end
		image_file = File.new("#{FIRMWARES_DIR}/#{orig}", "wb")
		image_file.write(@firmware.image.read)
		image_file.close
		@firmware.image = orig

		if Firmware.find_by_component_model_id(@firmware.component_model_id)
			flash[:notice] = 'Such component model is already exists.'
			render :action => 'new'
		elsif !@firmware.save
			flash[:notice] = 'An error occured during applying changes.'
			render :action => 'new'
		else
			flash[:notice] = 'Firmware was successfully created.'
			redirect_to :action => 'index'
		end	
	end

	def update
		@firmware = Firmware.find(params[:id])
		new_firmware = Firmware.new(params[:firmware])
		updated_values = params[:firmware]
		to_be_deleted = "#{FIRMWARES_DIR}/#{@firmware.image}"

		if new_firmware.image != ""
			orig = new_firmware.image.original_filename.to_s
			if File.exists?("#{FIRMWARES_DIR}/#{orig}")
				flash[:notice] = 'Such firmware image is already exists.'
				render :action => 'edit'
				return
			end
			image_file = File.new("#{FIRMWARES_DIR}/#{orig}", "wb")
			image_file.write(new_firmware.image.read)
			image_file.close
			updated_values["image"] = orig
		end

		updated_values.each_key { |x| updated_values.delete x if updated_values[x] == "" }

		if Firmware.find_by_component_model_id(new_firmware.component_model_id)
			flash[:notice] = 'Such component model is already exists.'
			render :action => 'edit'
		elsif @firmware.update_attributes(updated_values)
			File.delete to_be_deleted
			flash[:notice] = 'Firmware was successfully updated.'
			redirect_to :action => 'index'
		else
			render :action => 'edit'
		end
	end

	def destroy
		@firmware = Firmware.find(params[:id])
		File.delete "#{FIRMWARES_DIR}/#{@firmware.image}"
		@firmware.destroy

		redirect_to :action => 'index'
	end

	def live_component
		computer = Computer.find_by_id(params[:computer])
		@components = computer ? computer.last_testing.components.collect { |x| [x.model.name, x.model.id] } : []
		render(:layout => false)
	end
end
