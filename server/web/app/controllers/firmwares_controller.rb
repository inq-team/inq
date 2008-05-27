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

		orig = @firmware.image.original_filename.gsub(/ /, '_')
		begin
			File.new("#{FIRMWARES_DIR}/#{orig}", File::CREAT|File::EXCL|File::WRONLY).write(@firmware.image.read)
		rescue Errno::EEXIST
			flash[:notice] = 'Such firmware image already exists.'
			render :action => 'new'
			return
		end
		@firmware.image = orig

		begin
			@firmware.save!
		rescue ActiveRecord::StatementInvalid
			flash[:notice] = 'Such component model already exists.'
			render :action => 'new'
			return
		end

		flash[:notice] = 'Firmware was successfully created.'
		redirect_to :action => 'index'
	end

	def update
		@firmware = Firmware.find(params[:id])
		new_firmware = Firmware.new(params[:firmware])
		updated_values = params[:firmware]

		if new_firmware.image != ""
			orig = new_firmware.image.original_filename.gsub(/ /, '_')
			begin
				File.new("#{FIRMWARES_DIR}/#{orig}", File::CREAT|File::EXCL|File::WRONLY).write(new_firmware.image.read)
			rescue Errno::EEXIST
				flash[:notice] = 'Such firmware image already exists.'
				render :action => 'edit'
				return
			end
			updated_values["image"] = @firmware.image + " " + orig
			updated_values["image"].gsub!(/^ /, '')
		end

		updated_values.each_key { |x| updated_values.delete x if updated_values[x] == "" }

		if Firmware.find_by_component_model_id(new_firmware.component_model_id)
			flash[:notice] = 'Such component model already exists.'
			render :action => 'edit'
		elsif @firmware.update_attributes(updated_values)
			flash[:notice] = 'Firmware was successfully updated.'
			redirect_to :action => 'index'
		else
			render :action => 'edit'
		end
	end

	def destroy
		@firmware = Firmware.find(params[:id])
		@firmware.image.split(/ /).each { |f| File.delete "#{FIRMWARES_DIR}/#{f}" }
		@firmware.destroy

		redirect_to :action => 'index'
	end

	def live_component
		computer = Computer.find_by_id(params[:computer])
		@components = computer ? computer.last_testing.components.collect { |x| [x.model.name, x.model.id] } : []
		render(:layout => false)
	end

	def delete_file
		@firmware = Firmware.find(params[:id])
		file = params[:file]
		update = @firmware.image.split(/ /)
		update.delete(file)

		File.delete "#{FIRMWARES_DIR}/#{file}"
		@firmware.update_attribute("image", update.join(" ").gsub(/^ /, ''))

		flash[:notice] = "#{file} successfully deleted."
		render :action => 'edit'
	end
end
