module Sticker

class Profile

	attr_accessor :title, :context, :sticker, :scope, :printers

	def initialize(doc)
		@doc = doc
		@root = @doc.root
		@title = @root.attributes["title"]
		@scope = @root.attributes["scope"]
		@printers = @root.attributes["printers"]
		@printers = @printers.split(' ').collect { |s| Sticker::Printers.const_get(s.capitalize).new } if @printers
	end

	def self.from_file(fname)
		begin
			open(fname) do |f|
				Profile.new(REXML::Document.new(f))
			end				
		rescue REXML::ParseException
			raise 
		rescue IOError	
			nil
		end
	end

	def context=(context)
		@context = context
		_restrictions
		_filters
		_data
		_grids
		_layouts
		@sticker = @context.layouts[@root.attributes['layout']]	
	end

	protected

	def _data
		@sources = @root.elements.to_a('./data-sources/data-source').collect do |el|
			source = Datasources.from_element(el)
			source.context = @context if source
			source
		end
	end

	def _restrictions
		@restrictions = []
		@restrictions = @root.elements.to_a('./data-restrictions/data-restriction').collect do |el|
			restriction = Restrictions.from_element(el)
			restriction.context = @context if restriction
			restriction
		end
	end

	def _filters
		@filters = []
		@filters = @root.elements.to_a('./data-filters/data-filter').collect do |el|
			filter = Filters.from_element(el)
			filter.context = @context if filter
			filter
		end
	end

	def _grids
		@grids = []
		@grids = @root.elements.to_a('./grid-templates/grid-template').collect do |el|
			grid = Grids::Grid.from_element(el)
			grid.context = @context if grid
			grid
		end				
	end

	def _layouts
		@layouts = []
		@layouts = @root.elements.to_a('./layouts/layout').collect do |el|
			layout = Layouts.from_element(el)
			layout.context = @context if layout
			layout
		end
	end

end

end
