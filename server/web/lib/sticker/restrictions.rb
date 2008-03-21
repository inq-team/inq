module Sticker

module Restrictions

class PropertyRestriction

	attr_accessor :context, :id

	def initialize(id, el)
		@id = id
		@policy = el.attributes['policy']
		@property = el.attributes['property']
		@conditions = el.elements.to_a			
	end

	def restrict(data)
		data = data.dup
		case @policy
		when 'include'
			@conditions.collect do |condition|
				case condition.name
				when 'property-value-match'
					data.find_all { |d| d[@property] == condition.attributes['value'] }
				when 'property-value-empty'
					data.find_all { |d| d[@property].nil? || d[@property].empty? }
				end
			end.inject([]) { |a, b| a + b }
		when 'exclude'
			@conditions.collect do |condition|
				case condition.name
				when 'property-value-match'
					data.delete_if { |d| d[@property] == condition.attributes[:value] }
				when 'property-value-empty'
					data.delete_if { |d| d[@property].nil? || d[@property].empty? }
				end
			end
			data
		end
	end

	def context=(context)
		@context = context
		context.restrictions[@id] = self
	end
end

def self.from_element(el)
	kind = el.elements[1]
	case kind.name
	when "property-restriction"
		PropertyRestriction.new(el.attributes['id'], kind)
	end
end

end

end
