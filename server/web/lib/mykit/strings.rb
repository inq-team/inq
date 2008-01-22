module MyKit

class Strings

	@@ts = 0
	@@ts1 = 0	
	@@ts11 = 0
	@@ts12 = 0
	@@ts2 = 0
	@@ts3 = 0
	@@ts4 = 0

	def self.ts
		[@@ts, @@ts1, @@ts11, @@ts12, @@ts2, @@ts3, @@ts4]
	end

	def self.compare(s1, s2, deb = nil)
		ts = Time.new

		s1 = s1.chars if s1.is_a?(String) && s1.respond_to?(:chars)
		s2 = s2.chars if s2.is_a?(String) && s2.respond_to?(:chars)

		ts4 = Time.new
		a1 = s1.to_str.unpack('U*')
		a2 = s2.to_str.unpack('U*')
		l1 = a1.size
		l2 = a2.size
		@@ts4 += Time.new - ts4
	
		ts1 = Time.new
		# slice string into chunks
		i = 0
		chunks = []
		while i < l1 
			i1 = i
			j = 0
			while j < l2
				j1 = j
				l = 0
				ts11 = Time.new
				while i1 < l1 && j1 < l2 && a1[i1] == a2[j1]
					ts12 = Time.new
					j1 += 1 ; i1 += 1 ; l += 1
					@@ts12 += Time.new - ts12
				end
				@@ts11 += Time.new - ts11
				if l > 0
					chunks << [i, j, l]
					i1 = i
				end
				j += 1
			end
			i += 1
		end
		@@ts1 += Time.new - ts1

		# print all chunks
		if deb 
			print chunks.collect {|a| "#{a[0]},#{a[1]}~#{a[2]}=\"#{s1[a[0]..(a[0] + a[2] - 1)]}\"" }.join("\n")		
			print "\n" + chunks.inject("") { |s, a| s + s1[a[0]..(a[0] + a[2] - 1)] } + "\n"
		end

		ts2 = Time.new
		# remove chunks that are completely inside another chunk
		narr = []
		i = 0
		while i < chunks.size
			ch = chunks[i]
			unless narr.include?(ch)
				j = i + 1
				while j < chunks.size 
					dh = chunks[j]
					unless narr.include?(dh)
						if ch[0] >= dh[0] && ch[1] >= dh[1] && 
						   ch[0] + ch[2] <= dh[0]+ dh[2] && ch[1] + ch[2] <= dh[1] + dh[2]
							narr << ch
							break							
						elsif ch[0] <= dh[0] && ch[1] <= dh[1] &&
						      ch[0] + ch[2] >= dh[0] + dh[2] && ch[1] +ch[2] >= dh[1] + dh[2]
							narr << dh
						end
					end
					j += 1
				end
			end
			i += 1
		end
		narr.each { |ch| chunks.delete(ch) }

		# print independent chunks
		# print chunks.collect {|a| "#{a[0]},#{a[1]}~#{a[2]}=\"#{s1[a[0]..(a[0] + a[2] - 1)]}\"" }.join("\n")		
		# print "\n" + chunks.inject("") { |s, a| s + s1[a[0]..(a[0] + a[2] - 1)] } + "\n"

		# produce chunk intersection relation ; also do first two steps of closure generation
		sep = chunks.collect { |ch| [ ch ] }
		ava = []
		inter = {}
		inter.default = {}
		chunks.each_index { |i| ch = chunks[i] ;  inter[ch][ch] =  0 ; z = chunks.dup ; z.delete_at(i) ; ava[i] = z }
		i = 0
		while i < chunks.size
			ch = chunks[i]
			j = i + 1
			while j < chunks.size 
				dh = chunks[j]
				if (ch[0] + ch[2] - 1 < dh[0] && ch[1] + ch[2] - 1 < dh[1]) ||
				   (ch[0] > dh[0] + dh[2] - 1 && ch[1] > dh[1] + dh[2] - 1)
					z = chunks.dup
					z.delete_at(i)
					z.delete_at(j)
					sep << [ch, dh]
					ava[sep.size - 1] = z
					inter[ch][dh] = 0
					inter[dh][ch] = 0
				end
				j += 1
			end
			i += 1
		end
		@@ts2 += Time.new - ts2

		ts3 = Time.new
		# generate closures
		while 0
			new = []
			del = []
			i = 0
			while i < sep.size
				j = 0
				added = nil
				while j < ava[i].size
					ch = chunks[j]
					ks = inter[ch]
					if sep.inject(0) { |b, dh| b && ks[dh] or break }
						added = 0
						new << sep + ch
						z = ava[i].dup
						z.delete_at(j)					
						ava << z
					end
					j += 1
				end
				del.push(i) if added	
				i += 1
			end
			break if new.empty?
			while i = del.pop ; sep.delete_at(i) ; ava.delete_at(i) ; end
			sep += new
		end 
		@@ts3 += Time.new - ts3

		# compute close metrics and select the most appropriate one
		len = sep.inject({}) { |h, s| h.merge({ s => s.inject(0) { |i, ch| i + ch[2] } }) }
		met = sep.inject({}) { |h, s| h.merge({ s => len[s] - s.size }) }
		sor = sep.sort { |a, b| met[a] <=> met[b] }
		chunks  = sep.find_all { |s| met[s] == met[sor.last] }.inject(sor.last) { |a, b| len[a] > len[b] ? a : b } || []

		# print selected chunks
		if deb 
			print chunks.collect {|a| "#{a[0]},#{a[1]}~#{a[2]}=\"#{s1[a[0]..(a[0] + a[2] - 1)]}\"" }.join("\n")		
			print "\n" + chunks.inject("") { |s, a| s + s1[a[0]..(a[0] + a[2] - 1)] } + "\n"
		end
		
		@@ts += Time.new - ts

		chunks
	end

	def self.distance(s1, s2)
		s1 = s1.chars if s1.is_a?(String) && s1.respond_to?(:chars)
		s2 = s2.chars if s2.is_a?(String) && s2.respond_to?(:chars)

		chunks = compare(s1, s2)
		return (1.0/0.0) if chunks.empty?

		#transform the strings into two vectors of chunks and compute distance between them
		i = 0
		co1 = 0
		co2 = 0
		dist = 0 
		sz = chunks.size
		chf = chunks[0]
		chl = chunks[sz - 1]
		if chf[0] > 0
			co1 += chf[0]
		end
		if chf[1] > 0
			co2 += chf[1]
		end
		dist += (co1 + co2) ** 2 ; co1 = 0 ; co2 = 0
	#	dist += co1 > co2 ? co1 * co1 : co2 * co2 ; co1 = 0 ; co2 = 0
		while i < sz
			ch = chunks[i]
			j = i + 1
			if j < sz		
				co1 += chunks[j][0] - ch[0] - ch[2]
				co2 += chunks[j][1] - ch[1] - ch[2]
				dist += (co1 + co2) ** 2 ; co1 = 0 ; co2 = 0
	#			dist += co1 > co2 ? co1 * co1 : co2 * co2 ; co1 = 0 ; co2 = 0
			end
			co = 0
			i = j
		end
		if chl[0] + chl[2] < s1.size
			co1 += s1.size - chl[0] - ch[2]				
		end
		if chl[1] + chl[2] < s2.size
			co2 += s2.size - chl[0] - chl[2]	
		end
		Math.sqrt(dist + (co1 + co2) ** 2)	
	#	Math.sqrt(dist + (co1 > co2 ? co1 * co1 : co2 * co2))		
	end

	def self.to_vectors(s1, s2)
		s1 = s1.chars if s1.is_a?(String) && s1.respond_to?(:chars)
		s2 = s2.chars if s2.is_a?(String) && s2.respond_to?(:chars)

		chunks = compare(s1, s2)
		return [s1, s2] if chunks.empty?

		#transform the strings into two vectors of chunks and compute distance between them
		i = 0
		s1a = [] ; s2a = []
		sz = chunks.size
		chf = chunks[0]
		chl = chunks[sz - 1]
		if chf[0] > 0
			s1a << s1[0 .. chf[0] - 1] 
		elsif chf[1] > 0 
			s1a << ''
		end
		if chf[1] > 0
			s2a << s2[0 .. chf[1] - 1] 
		elsif chf[0] > 0
			s2a << ''
		end
		while i < sz
			ch = chunks[i]
			s1a << s1[ch[0]..(ch[0] + ch[2] - 1)]
			s2a << s2[ch[1]..(ch[1] + ch[2] - 1)]
			j = i + 1
			if j < sz		
				s1a << s1[(ch[0] + ch[2])..(chunks[j][0] - 1)]
				s2a << s2[(ch[1] + ch[2])..(chunks[j][1] - 1)]
			end
			i = j
		end
		if chl[0] + chl[2] < s1.size
			s1a << s1[(chl[0] + chl[2])..(s1.size - 1)] 
		elsif chl[1] + chl[2] < s2.size 
			s1a << ''
		end
		if chl[1] + chl[2] < s2.size
			s2a << s2[(chl[1] + chl[2])..(s2.size - 1)] 
		elsif chl[0] + chl[2] < s1.size 
			s2a << ''
		end
		[s1a, s2a]
	end

	def self.base(s1, s2)
		s1 = s1.chars if s1.is_a?(String) && s1.respond_to?(:chars)
		s2 = s2.chars if s2.is_a?(String) && s2.respond_to?(:chars)

		compare(s1, s2).inject("") { |s, a| s + s1[a[0]..(a[0] + a[2] - 1)] }
	end

	def self.find_all(s1, strings, max = nil)
		dist = strings.collect { |s| distance(s1, s) }
		min = dist.inject(dist[0]) { |i, j| i < j ? i : j }
		res = []
		strings.each_index { |i| res << strings[i] if dist[i] == min } unless max and max < min
		res
	end

end

end

