class ShelvesController < ApplicationController

@@default_config = Shelves::Config.new(DEFAULT_SHELVES_CONFIG)

def addresses
	config = params[:config] ? Shelves::Config.new(params[config]) : @@default_config
	shelf = config[params[:id]]
	render :text => shelf.get_addresses.join("\n")
end

end
