class ShelvesController < ApplicationController

@@default_config = Shelves::Config.new(DEFAULT_SHELVES_CONFIG)

def addresses
	config = params[:config] ? Shelves::Config.new(params[config]) : @@default_config
	shelf = config[params[:id]]
	if shelf
		if shelf.ipnet =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/
			net = ($1.to_i() << 24) | ($2.to_i() << 16) | ($3.to_i() << 8) | ($4.to_i())
			p net
			render :text => (1..(1 << (32 - $5.to_i())) - 2).inject([]) { |a, i| p i ; a << (net | i) }.collect { |j| "#{j >> 24}.#{ (j >> 16) & 255 }.#{ (j >> 8) & 255 }.#{ j & 255 }" }.join("\n")
		else
			raise("Malformed ip network address") 
		end
	end
end

end

