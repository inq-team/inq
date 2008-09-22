module Sticker

class Library

attr_accessor :profiles

def initialize
	path = STICKER_PROFILE_LIBRARY_PATH
	files = Dir.glob("#{path}/*.xml")
	@profiles = files.inject({}) do |h, f| 
		if p = Profile.from_file(f)
			puts("Ok!: Loaded #{ p.title } from #{ f }\n")
			h.merge({ p.title => p })	
		else
			puts("ERR: Failed to load #{ f }\n")
			h
		end
	end	
	puts("INF: Loaded #{ @profiles.size } / #{ files.size }\n")
	@profiles.size > 0	
end

def by_scope(scope)
	@profiles.find_all { |k, v| v.scope == scope }.inject({}) { |h, p| h.merge({ p.last.title => p.last }) }
end

end

end
