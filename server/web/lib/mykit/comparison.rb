module MyKit

class Comparison

def self.compare(db, detect)
	detect = detect.inject({}) { |h, c| nm = "#{ c.model.vendor } + #{ c.model.name }" ; h[nm][:count] += 1 if h[nm] ; h[nm] ? h : h.merge({ nm => { :vendor => c.model.vendor, :name => c.model.name, :count => 1, :tokens => (c.model.name.split(/\s+/) + (c.model.vendor.blank? ? [] : [c.model.vendor])).inject({}) { |h, s| h.merge({ s.chars.upcase => s }) }, :group => (c.model.group ? c.model.group.name : '') } }) }.values
	groups = (db.inject([]) { |a, b| a | b.last.collect { |c| c.group } }) | (detect.collect { |a| a[:group] })

	Keywords::OMIT_FROM_COMPARISON.each { |g| groups.delete(g) }

	groups.inject({}) do |result, gr|
		db_gr = db.inject([]) { |a, b| a + b.last.find_all { |c| c.group == gr }.collect { |c| { :line => { :name => b.first.name, :qty => b.first.qty }, :comp => c, :searchable => (c.title.collect { |t| { :origin => :title, :string => t.chars.upcase } } + c.vendors.collect { |t| { :origin => :vendors, :string => t.chars.upcase } } + c.property_names.collect { |pr| { :origin => :properties, :string => c.send(pr).value } } + c.keywords.collect { |t| { :origin => :keywords, :string => t } }) } } }
		dists = { :vendors => Keywords::MAX_DISTANCE, :keywords => Keywords::SPAN_DISTANCE, 
			  :title => Keywords::SPAN_DISTANCE, :properties => Keywords::SPAN_DISTANCE }
		db_gr.each { |db_dev| db_dev[:searchable].each { |s| s[:distance] = dists[s[:origin]] } }
		db_prim, db_sec = db_gr.inject([[], []]) { |a, b| b[:comp].onboard ? [ a.first, a.last << b ] : [ a.first << b, a.last ] }
		detect_gr = detect.find_all { |a| a[:group] == gr }
		pairs = [] ; missing = [] ; extra = []
		matr = {} ; relevant = []

		db_prim.each do |db_dev|
			detect_devs = detect_gr
			matr[db_dev] = {}
			detect_devs.each do |d|
				d_data = {}
				d_mean = 0.0
				d_count = 0
				db_dev[:searchable].each do |t|
					raise t unless t[:distance]	
					ss = Strings.find_all_data(t[:string], d[:tokens].keys, t[:distance])
					unless ss.empty?
						ss.each { |da| da[:string] = d[:tokens][da[:string]] }
						d_data[t] = ss
						d_mean += ss.first[:distance] + 1
						d_count += 1
					end
				end
				d_mean = d_count / d_mean
				if d_mean < Keywords::COMP_MARGIN
					puts "#{db_dev[:line][:name]} <=> #{d[:vendor]} #{d[:name]} = #{d_mean}"
					matr[db_dev][d] = { :data => d_data, :mean => d_mean }
					relevant << d 
				end
			end
		end

		until relevant.empty?
			min = (1.0 / 0.0)
			db_dev = nil ; detect_dev = nil
			matr.each { |k, v| v.each { |z, y| (db_dev = k ; detect_dev = z ; min = y[:mean]) if min > y[:mean] } }
			break unless db_dev and detect_dev
			puts "#{db_dev[:line][:name]} <=> #{detect_dev[:vendor]} #{detect_dev[:name]} == #{ min }"
			db_dev.delete(:comp)
			pairs << { :db => db_dev, :detect => detect_dev, :data => matr[db_dev][detect_dev][:data] }
			matr.each { |k, v| v.delete(detect_dev) }
			relevant.delete(detect_dev)
			detect_gr.delete(detect_dev)
			matr.delete(db_dev)
		end

		missing = matr.keys

		matr = {} ; relevant = []
		
		detect_gr.each do |dev|
			db_devs = db_sec
			matr[dev] = {}
			db_devs.each do |d|
				d_likely = {}
				d_mean = 0.0
				d_count = 0
				d[:searchable].each  do |t|
					ss = Strings.find_all_data(t[:string], dev[:tokens].keys, Keywords::SPAN_DISTANCE)
					unless ss.empty?
						ss.each { |da| da[:string] = dev[:tokens][da[:string]] }
						d_data[t] = ss
						d_mean += ss.first[:distance] + 1
						d_count += 1
					end
				end
				d_mean = d_count / d_mean
				if d_mean < KeyWords::COMP_MARGIN
					matr[d][dev] = { :data => d_data, :mean => d_mean }
					relevant << dev 
				end
			end
		end

		until relevant.empty?
			min = (1.0 / 0.0)
			db_dev = nil ; detect_dev = nil
			matr.each { |k, v| v.each { |z, y| (db_dev = k ; detect_dev = z ; mean = y[:mean]) if min > y[:mean] } }
			db_dev.delete(:comp)
			pairs << { :db => db_dev, :detect => detect_dev, :data => matr[db_dev][detect_dev][:data] }
			matr.each { |k, v| v.delete(detect_dev) }
			relevant.delete(detect_dev)
			detect_gr.delete(detect_dev)
			matr.delete(db_dev)
		end

		extra = detect_gr
		missing.each { |m| m.delete(:comp) }

		result.merge({ gr => { :pairs => pairs, :missing => missing, :extra => extra } })
	end
end

def self.post_process(pair)
	#divide all tokens into good and bad ones
	spans = [] 
	db_dev = pair[:db]
	detect_dev = pair[:detect]
	data = pair[:data]
	r_prop = /^[^0-9]*$/
	r_word = /^[ \t?:+=()_-]*$/

	#cleanup ambigous links from hash; only closest strings are allowed
	mins = data.inject({}) { |h, dta| dta.last.inject(h) { |h, dt| !h[dt[:string]] || h[dt[:string]][:distance] > dt[:distance] ? h.merge({ dt[:string] => dt }) : h } }	
	data.each { |dta| dta.last.delete_if { |dt| mins[dt[:string]] != dt } }
	data.delete_if { |k, v| v.empty? }

	data.keys.each do |token|
		s = token[:string]
		d = data[token].first
		puts "#{ s }:#{ token[:origin] } <=> #{ data[token].collect { |d| "#{ d[:string] }:#{ d[:distance] }" }.join(", ") }"
		g = 0
		case token[:origin]
		when :properties
			ss = Strings.to_span(s, d[:string], d[:raw]) { |s1, s2| s1 =~ r_prop and s2 =~ r_prop }
		when :title, :keywords
			ss = Strings.to_span(s, d[:string], d[:raw]) { |s1, s2| s1 =~ r_word and s2 =~ r_word }
		when :vendors
			ss = Strings.to_span(s, d[:string], d[:raw]) { |s1, s2| 0 }
		end
		spans <<  { :token => token, :target => d[:string], :spans => ss }
	end
	spans
end

end

end
