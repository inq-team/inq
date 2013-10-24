# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'authenticated_system'
require 'sticker/proxy'

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
	before_filter :login_from_cookie

	def self.enable_sticker_printing
		Sticker::Proxy.inject_into(self)
	end

	helper :date

private
	before_filter :instantiate_controller_and_action_names

	def instantiate_controller_and_action_names
		@current_action = action_name
		@current_controller = controller_name
	end
end
