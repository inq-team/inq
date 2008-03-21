module Sticker

module Grids

module Orderings

class PropertyOrdering 

	def initialize(elem)
		@property = elem.attributes['property']	
		@conditions = elem.elements.to_a('./*')
	end

	def order(data)
		result = []
		unmatched = data.dup
		@conditions.each do |condition|
			case condition.name
			when "property-ordering-value-match"
				result += data.find_all { |d| d[@property] == condition.attributes['value'] }
				unmatched.delete_if { |d| d[@property] == condition.attributes['value'] }
			end
		end
		result + unmatched
	end

end

def self.from_element(el)
	case el.name
	when "property-ordering"
		PropertyOrdering.new(el)
	end
end

end

end

end
