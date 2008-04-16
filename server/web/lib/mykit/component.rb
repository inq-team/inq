module Mykit


class Mykit::Component
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

	attr_accessor :vendors, :title, :group, :property_names, :onboard, :keywords, :item, :sku
	
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
		names = props.keys.collect { |k| Mykit::Keywords::Properties[k].downcase.gsub(/\s+/, '_').to_sym }
		self.property_names = names || []
		(class << self ; self ; end).class_eval { attr_accessor *names } unless names.empty?
		props.each { |k, v| send("#{ Mykit::Keywords::Properties[k].downcase.gsub(/\s+/, '_') }=".to_sym, Property.new(*v.collect { |a| [ a[:value], a[:unit] ] }.flatten)) }
	end
end

end

