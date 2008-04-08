require 'sticker/library'
require 'sticker/proxy'
require 'mykit/components'

class StickersController < ApplicationController

	enable_sticker_printing

	def index
		lib = Sticker::Library.new
		@profiles = lib.by_scope('computer')
		@copies = 1
	end

	def show
		lib = Sticker::Library.new
		@profiles = lib.by_scope('computer')
		@computer = params[:computer]
		@testing = params[:testing]
		@profile = params[:profile]
		@copies = params[:copies] || 1
		render(:action => 'index')
	end

	def apply
		lib = Sticker::Library.new
		@profiles = lib.by_scope('computer')
		@computer = Computer.find(params[:computer])
		@testing = @computer.testings.find(params[:testing]) if @computer.testings && !params[:testing].blank?
		@profile = params[:profile]
		@copies = params[:copies]
		@sticker = render_sticker(@profile, @copies)
		print_sticker(@profile, @copies)
		@computer = @computer.id
		@testing = @testing.id if @testing	
		render(:action => 'index')
	end

	def debug_clear_zebra
		begin
			Sticker::Printers.const_get('Abstractzebra').clear_tokens
			render(:text => "Image tokens reset")
		rescue NameError
			render(:text => "Class not defined")
		end
	end

end

