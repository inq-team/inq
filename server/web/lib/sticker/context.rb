module Sticker

class Context

	attr_accessor :filters, :restrictions, :sources, :user_data, :data, :grids, :layouts, :printers, :proxy

	def initialize
		@filters = {}
		@restrictions = {}
		@data = {}
		@sources = {}
		@user_data = {}
		@grids = {}
		@layouts = {}
		@printers = {}
		@proxy
	end

end

end
