require 'mykit/lexer' 

module MyKit


class Component
	class Property
		def vector?
			@vector
		end	

		def [](i)
			@props[i]
		end

		def value
			@vector ? @props.first.value : @value
		end

		def unit
			@vector ? @props.first.unit : @unit
		end

		def initialize(*a)
			if @vector = (a.size > 2)						
				@props = []
				i = 0 ; while i < a.size 
					@props << Property.new(a[i], a[i + 1])
					i += 2
				end
			else
				@value = a.first
				@unit = a.last
			end			
		end

		def size
			@vector && @props.size
		end

		def ==(prop)
			prop.is_a?(Property) && ((prop.vector? && self.vector? && prop.value == self.value && prop.unit == self.unit) ||
				(!prop.vector && !self.vector? && @props.size == prop.props.size && [0..@props.size - 1].inject(true) { |b, i| @props[i] == prop.props[i] or break(nil) } ))
		end

		protected 
		def props
			@props
		end

	end

	attr_accessor :vendors, :title, :group, :property_names, :onboard, :keywords, :item
	
	def self.create(itm)
		Parser::parse_item(itm).collect do |i| 
			cmp = Component.new 
			i.each { |k, v| cmp.send("#{ k }=".to_sym, v) unless k == :properties } 
			cmp.send(:create_props, i[:properties])
			cmp.item = itm
			cmp
		end
	end

	protected
	def create_props(props)
		names = props.keys.collect { |k| MyKit::Keywords::Properties[k].downcase.gsub(/\s+/, '_').to_sym }
		self.property_names = names || []
		(class << self ; self ; end).class_eval { attr_accessor *names } unless names.empty?
		props.each { |k, v| send("#{ MyKit::Keywords::Properties[k].downcase.gsub(/\s+/, '_') }=".to_sym, Property.new(*v.collect { |a| [ a[:value], a[:unit] ] }.flatten)) }
	end
end

class Parser

	def self.compute(property, value, unit)
		_U = unit.chars.upcase
		v = value.to_f
		case property
		when MyKit::Keywords::Properties::CAPACITY, MyKit::Keywords::Properties::CACHE
			v *= 1024*1024 if _U == 'MB' || _U == 'M'
			v *= 1024*1024*1024 if _U == 'GB' || _U == 'G'
			v *= 1024 if _U == 'KB' || _U == 'K'
			v			
		when MyKit::Keywords::Properties::FREQUENCY
			v *= 1000 if _U == 'KHZ' || _U == 'КГЦ'
			v *= 1000 * 1000 if _U == 'MHZ' || _U == 'МГЦ'
			v *= 1000 * 1000 * 1000 if _U == 'GHZ' || _U == 'ГГЦ'
			v
		when MyKit::Keywords::Properties::SPEED
			v *= 1000 if _U == 'K' 
			v			
		else
			v
		end
	end

	def self.parse(str)
		Component.create(Item.new(str))
	end

	def self.parse_item(itm)
		i = (1..itm.components.size - 1).inject(0) { |i, j| (itm.components[i] < itm.components[j]) ? j : i }
		most_likely = (0..itm.components.size - 1).inject([]) { |a, j| (itm.components[j] == itm.components[i]) ? a + [j] : a }
		less_likely = (0..itm.components.size - 1).inject([]) { |a, j| ((d = itm.components[i] - itm.components[j]) > 0 && d <= MyKit::Keywords::COMP_DISTANCE && itm.components[j] > 0) ? a + [j] : a }
		props2 = Hash[*itm.properties.collect { |k, v| [ k, (v = v.dup ; vv = [] ; until v.empty? ; vv << v.delete(v.first) ; end ; vv)  ] }.inject([]) { |a, b| a + b }]

#		props2[MyKit::Keywords::Properties::CAPACITY].each do |c|
#			props2.dup.delete_if { |[MyKit::Keywords::Propertiews::CAPACITY]
#		end

		comps = most_likely | (most_likely.collect { |comp_i| less_likely.find_all() { |l| MyKit::Keywords::EMBED[comp_i].include?(l) } }.inject([]) { |a, b| a | b })

		comps = comps.collect do |comp_i|
			props = props2.inject({}) { |h, a| MyKit::Keywords::PROPS[a.first][comp_i] == 0 ? h : h.merge({ a.first => a.last.dup.collect { |h| h.merge({ :computed => compute(a.first, h[:value], h[:unit]) }) }}) }
			{ :onboard => !most_likely.include?(comp_i), :vendors => itm.vendors, :title => itm.sense, :group => MyKit::Keywords::Components[comp_i], :properties => props, :keywords => itm.keywords }
		end

		#heuristics to remove incorrectly assigned properties
		comps.each do |comp|
			if (caps = comp[:properties][MyKit::Keywords::Properties::CAPACITY]) && caps.size > 1
				max = caps.inject(caps.first[:computed].to_f) { |max, c| v = c[:computed].to_f ; max < v ? v : max }
				caps.delete_if { |c| c[:computed].to_f < max }
			end
			if (caps = comp[:properties][MyKit::Keywords::Properties::CACHE]) && caps.size > 1
				min = caps.inject(caps.first[:computed].to_f) { |min, c| v = c[:computed].to_f ; min > v ? v : min }
				caps.delete_if { |c| c[:computed].to_f > min }
			end
		end

		comps
	end
end

end
