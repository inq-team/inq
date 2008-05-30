module Mykit

class Lexer
	@@keywords = Mykit::Keywords::WORDS.inject({}) { |h, a| h.merge({ a.first.chars.upcase.to_str => a.last }) } 
	@@vendors = Mykit::Vendors.find_all().inject({}) { |h, s| h.merge({ s.chars.upcase.to_str => s }) }
	@@measures = Mykit::Keywords::MEASURES.inject({}) { |h, a| h.merge({ a.first.chars.upcase.to_str => a.last }) } 
	@@units = Mykit::Keywords::UNITS.inject({}) { |h, a| h.merge({ a.first.chars.upcase.to_str => a.last }) } 

	@@ts1 = 0
	@@ts2 = 0
	@@ts3 = 0

	def self.ts
		r = [@@ts1, @@ts2, @@ts3]
		@@ts1 = @@ts2 = @@ts3 = 0
		r
	end

	def self.lex(string, sku = nil)
		_lex(string).merge({ :sku => sku })
	end	
	
	def self._lex(string)
		ts1 = Time.new
		
		chunks = string.split(/\s+/).collect { |r| r unless r.empty? }.compact
		components = Array.new(Mykit::Keywords::PROPS.first.size, 0)
		properties = {}
		keywords = []
		vendors = []
		sense = {}
		number0 = /^(\d+([.,]\d+)?)([^0-9]+)$/
		number2 = /^\d+([.,]\d+)?$/
		number1 = /(\d+([.,]\d+)?)([^0-9]+)$/
		sense_reg = /^[A-Z0-9@.:_\-]+$/
		remove = []
			
		# first run
		chunks.each do |c|
			_C = c.chars.upcase.to_str
			ms = kw = vs = kws = kw_dist = vs_dist = nil

			if c =~ number0
				first = $1
				last = $3.chars.upcase.to_str
				ms.each { |pr| properties[pr] = properties[pr].nil? ? [{ :value => first, :unit => $3 }] : properties[pr] + [{ :value => first, :unit => $3 }] } if ms = @@measures[last]
				kw.each_index { |i| components[i] += kw[i] } if kw = @@units[last]
				unless ms.blank? and kw.blank? 
					chunks.delete(c)
				end
			end
		end

		pairs = chunks[0..-2].zip(chunks[1..-1])
		pairs.collect do |p| 
			ms = kw = nil

			if p.first =~ number2
				first = p.first
				last = p.last.chars.upcase.to_str
				ms.each { |pr| properties[pr] = properties[pr].nil? ? [{ :value => first , :unit => p.last }] : properties[pr] + [{ :value => first , :unit => p.last }] } if ms = @@measures[last]
				kw.each_index { |i| components[i] += kw[i] } if kw = @@units[last]
				unless ms.blank? and kw.blank? 
					chunks.delete(p.first)
					chunks.delete(p.last)
					remove << p
				end
			end
		end
		pairs -= remove

		#second run

		chunks2 = chunks.collect { |r| r.split(/\\|,|\/|\(|\)|>|<|-|\+|=/).collect { |t| t unless t.empty? }.compact }.flatten
		pairs2 = chunks2[0..-2].zip(chunks2[1..-1])
		pairs3 = pairs | pairs2
		chunks3 = chunks | chunks2
		sense = chunks3.inject({}) { |h, s| h.merge({ s => 0 }) }

		pairs3.collect do |p| 
			ms = kw = nil

			if p.first =~ number2 
				first = p.first
				last = p.last.chars.upcase.to_str
				ms.each { |pr| properties[pr] = properties[pr].nil? ? [{ :value => first , :unit => p.last }] : properties[pr] + [{ :value => first , :unit => p.last }] } if ms = @@measures[last]
				kw.each_index { |i| components[i] += kw[i] } if kw = @@units[last]
				unless ms.blank? and kw.blank? 
					sense.delete(p.first)
					sense.delete(p.last)
				end
			end
		end

		chunks3.each do |c|
			_C = c.chars.upcase.to_str
			ms = kw = vs = kws = kw_dist = vs_dist = nil

			if c =~ number1
				first = $1
				last = $3.chars.upcase.to_str
				ms.each { |pr| properties[pr] = properties[pr].nil? ? [{ :value => first, :unit => $3 }] : properties[pr] + [{ :value => first, :unit => $3 }] } if ms = @@measures[last]
				kw.each_index { |i| components[i] += kw[i] } if kw = @@units[last]
			end

			ts2 = Time.new
			vs = Strings.find_all(_C, @@vendors.keys, Mykit::Keywords::MAX_DISTANCE)
			@@ts2 += Time.new - ts2

			ts3 = Time.new
			kws = Mykit::Strings.find_all(_C, @@keywords.keys, Mykit::Keywords::KW_DISTANCE)
			@@ts3 += Time.new - ts3

			kw_dist = Strings.distance(_C, kws.first) unless kws.blank?
			vs_dist = Strings.distance(_C, vs.first) unless vs.blank?
			which = (vs.blank? || kws.blank?) ? nil : vs_dist < kw_dist
			vendors |= vs.collect { |v| @@vendors[v] } if which.nil? || which == true
			kws.each { |s| keywords |= [ s ] ; (kw = @@keywords[s]).each_index { |i| components[i] += kw[i] } } if which.nil? || which == false
			sense.delete(c) unless ms.blank? and kw.blank? and (vs.blank? || vs_dist > Mykit::Keywords::SAFE_DISTANCE) and (kws.blank? || kw_dist > Mykit::Keywords::SAFE_DISTANCE) and _C =~ sense_reg
		end

		properties.keys.each { |i| components.each_index { |j| components[j] += Mykit::Keywords::PROPS[i][j] } }

		@@ts1 += Time.new - ts1

		{ :keywords => keywords, :string => string, :sense => sense.keys, :properties => properties, :components => components, :vendors => vendors }	
	end

end

end
