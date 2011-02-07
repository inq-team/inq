#require 'mykit/lexer' 

module Mykit

class Parser

	def self.compute(property, value, unit)
		_U = unit.chars.upcase
		v = value.to_f
		case property
		when Mykit::Keywords::Properties::CAPACITY, Mykit::Keywords::Properties::CACHE
			v *= 1024*1024 if _U == 'MB' || _U == 'M'
			v *= 1024*1024*1024 if _U == 'GB' || _U == 'G'
			v *= 1024 if _U == 'KB' || _U == 'K'
			v			
		when Mykit::Keywords::Properties::FREQUENCY
			v *= 1000 if _U == 'KHZ' || _U == 'КГЦ'
			v *= 1000 * 1000 if _U == 'MHZ' || _U == 'МГЦ'
			v *= 1000 * 1000 * 1000 if _U == 'GHZ' || _U == 'ГГЦ'
			v
		when Mykit::Keywords::Properties::SPEED
			v *= 1000 if _U == 'K' 
			v			
		else
			v
		end
	end

	def self.parse(str, sku = nil)
		Mykit::Component.create(Item.new(str, sku))
	end

	def self.parse_item(itm)
		i = (1..itm.components.size - 1).inject(0) { |i, j| (itm.components[i] < itm.components[j]) ? j : i }
		if itm.components[i] > 0  
			most_likely = (0..itm.components.size - 1).inject([]) { |a, j| (itm.components[j] == itm.components[i]) ? a + [j] : a }
			less_likely = (0..itm.components.size - 1).inject([]) { |a, j| ((d = itm.components[i] - itm.components[j]) > 0 && d <= Mykit::Keywords::COMP_DISTANCE && itm.components[j] > 0) ? a + [j] : a }
		else
			most_likely = []
			less_likely = []
		end
		props2 = Hash[*itm.properties.collect { |k, v| [ k, (v = v.dup ; vv = [] ; until v.empty? ; vv << v.delete(v.first) ; end ; vv)  ] }.inject([]) { |a, b| a + b }]

#		props2[Mykit::Keywords::Properties::CAPACITY].each do |c|
#			props2.dup.delete_if { |[Mykit::Keywords::Propertiews::CAPACITY]
#		end

		comps = most_likely | (most_likely.collect { |comp_i| less_likely.find_all() { |l| (Mykit::Keywords::EMBED[comp_i] or []).include?(l) } }.inject([]) { |a, b| a | b })

		comps = comps.collect do |comp_i|
			props = props2.inject({}) { |h, a| Mykit::Keywords::PROPS[a.first][comp_i] == 0 ? h : h.merge({ a.first => a.last.dup.collect { |h| h.merge({ :computed => compute(a.first, h[:value], h[:unit]) }) }}) }
			{ :onboard => !most_likely.include?(comp_i), :vendors => itm.vendors, :title => itm.sense, :group => Mykit::Keywords::Components[comp_i], :properties => props, :keywords => itm.keywords, :sku => itm.sku }
		end

		#heuristics to remove incorrectly assigned properties
		comps.each do |comp|
			if (caps = comp[:properties][Mykit::Keywords::Properties::CAPACITY]) && caps.size > 1
				max = caps.inject(caps.first[:computed].to_f) { |max, c| v = c[:computed].to_f ; max < v ? v : max }
				caps.delete_if { |c| c[:computed].to_f < max }
			end
			if (caps = comp[:properties][Mykit::Keywords::Properties::CACHE]) && caps.size > 1
				min = caps.inject(caps.first[:computed].to_f) { |min, c| v = c[:computed].to_f ; min > v ? v : min }
				caps.delete_if { |c| c[:computed].to_f > min }
			end
		end

		comps
	end
end

end
