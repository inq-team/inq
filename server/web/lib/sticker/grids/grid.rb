module Sticker

module Grids

class GridInstance
	attr_accessor :columns

	#TODO: 	currently class only supports one ordering per template the sake of simplicity
	#	additional sorting rules may be enforced bt creating new classses in Orderings module
	#	to perform more sophisticated tasks, or by implementing nested orderings via
	#	a recursion of some kind

	def initialize(orderings, columns)
		@ordering = Orderings.from_element(orderings.first) unless orderings.empty?
		@columns = columns.collect do |col|
			Columns.from_element(col)
		end
	end

	def order(data)
		@ordering.order(data)
	end
end

class Grid

	attr_accessor :context, :id

	def initialize(id, elem)
		@id = id
		@orderings = elem.elements.to_a('./rows-ordering/*')
		@columns = elem.elements.to_a('./columns/*')
	end

	def context=(context)
		@context = context
		context.grids[@id] = self
	end

	def new_instance()
		GridInstance.new(@orderings, @columns)
	end

	def self.from_element(elem)
		Grid.new(elem.attributes['id'], elem)
	end

end

end

end

