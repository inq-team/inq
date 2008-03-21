module Sticker

module Filters

class PropertyFilter

	attr_accessor :context, :id

	def initialize(id, el)
		@id = id
		@property = el.attributes['property']
		@filters = el.elements.to_a	
	end

	def context=(context)
		@context = context
		context.filters[@id] = self
	end

	def filter(data)
		data = data.dup
		@filters.each do |df|
			case df.name
			when "copy-from"
				from = df.attributes['from']
				restrict = df.attributes['restrict']
				data.each { |d| d[@property] = d[from] unless restrict && restrict == 'nil' && d[from].nil? }
			when "copy-to"
				to = df.attributes['to']
				restrict = df.attributes['restrict']
				data.each { |d| d[to] = d[@property] unless restrict && restrict == 'nil' && d[@property].nil? }
			when "append-value"
				value = df.attributes['value']
				data.each { |d| d[@property] += value }				
			when "append-property"
				from = df.attributes['from']
				data.each { |d| d[@property] += d[from] }	
			when "rename"
				from = df.attributes['from']
				to = df.attributes['to']
				data.each { |d| d[@property] = to if d[@property] == from }					
			when "collapse"
				counter = df.attributes['counter-property']
				data = data.inject({}) do |h, d| 
					if h[d[@property]]
						h[d[@property]][:count] += 1
						h
					else
						h.merge({ d[@property] => { :data => d, :count => 1 } })
					end
				end.inject([]) do |a, h|
					a << h.last[:data].merge({ counter => h.last[:count] })
				end
			end
		end
		data
	end

end

def self.from_element(el)
	kind = el.elements[1]
	case kind.name
	when 'property-filter'
		PropertyFilter.new(el.attributes['id'], kind)
	end
end

end

end
