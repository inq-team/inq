module Sticker

class Proxy
	
	attr_accessor :context, :client 
	
	def create_context
		@context = Context.new
		@context.proxy = self	
		@context
	end

	def get_property(name)
		@client.instance_variable_get("@#{ name }")
	end

	def property_defined?(name)
		@client.instance_variable_defined("@#{ name }")
	end

	def apply(profile)
		lib = Library.new
		profile = lib.profiles[profile]
		create_context
		profile.context = context
		profile.sticker
	end

	def print(profile, count)
		lib = Library.new
		profile = lib.profiles[profile]
		create_context
		profile.context = context
		sticker = profile.sticker
		printer = profile.printers.first
		printer.context = context
		printer.print(sticker, count)
	end

	def render(profile, count)
		lib = Library.new
		profile = lib.profiles[profile]
		create_context
		profile.context = context
		sticker = profile.sticker
		printer = profile.printers.first
		printer.context = context
		printer.render(sticker, count)
	end

	def self.inject_into(klass)
		klass.module_eval do 
			before_filter :create_sticker_printing_proxy			

			def print_sticker(profile, count)
				@__sticker_printing_proxy.print(profile, count)
			end

			def render_sticker(profile, count)
				@__sticker_printing_proxy.render(profile, count)
			end

			def apply_profile(profile)
				@__sticker_printing_proxy.apply(profile)
			end

			def create_sticker_printing_proxy
				@__sticker_printing_proxy = Sticker::Proxy.new
				@__sticker_printing_proxy.client = self
			end
		end		
	end

end

end
