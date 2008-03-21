module Sticker

module Grids

module Columns

class AbstractColumn
	attr_accessor :id

	def initialize(id, elem)
		@id = id
		@elem = elem		
	end
end

class AutoColumn < AbstractColumn
	def initialize(id, elem)
		super(id, elem)
		@value = elem.attributes["start"].to_i
		@step = elem.attributes["step"].to_i
	end

	def value_of(data)
		result = @value
		@value += @step
		result
	end
end

class PropertyColumn < AbstractColumn
	def initialize(id, elem)
		super(id, elem)
		@property = elem.attributes["property"]
	end

	def value_of(data)
		data[@property]
	end
end

def self.from_element(el)
	case el.name
	when "auto-column"
		AutoColumn.new(el.attributes["id"], el)
	when "property-column"		
		PropertyColumn.new(el.attributes["id"], el)
	end
end

end

end

end
