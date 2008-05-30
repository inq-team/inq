module Sticker

module Layouts

class Layout

	attr_accessor :context, :id

	def initialize(id, el)
		@id = id
		@elem = el
	end

	def context=(context)
		@context = context
		context.layouts[@id] = layout
	end

	protected

	def layout
		@layout = []
		@layout = @elem.elements.to_a.collect do |le|
			case le.name
			when 'grid'
				layout_grid(le)
			when 'single-record-block'
				layout_single_record_block(le)
			end	
		end
		@layout
	end

	def layout_grid(el)
		template = @context.grids[el.attributes['template']].new_instance
		data = el.elements.to_a('./use-data-sources/use-data-source').collect do |ds|
			@context.data[ds.attributes['ref']]
		end.inject([]) { |a, b| a + b }		
		columns = template.columns
		data = template.order(data)
		data = data.collect do |d|
			columns.collect { |c| c.value_of(d) }
		end
		head = columns.collect do |col|
			disp = el.elements["./display-columns/display-column[@ref='#{ col.id }']"]
			disp && disp.attributes["display"]
                end
		{ :kind => :grid, :head => head, :body => data, :id => el.attributes['id'] }
	end

	def layout_single_record_block(el)
		data = {}
		datasources = el.elements.to_a('./use-data-sources/use-data-source').each do |ds|
			d = @context.data[ds.attributes['ref']]
			data.merge!(d.is_a?(Array) ? d.first : d) rescue nil
		end
		{ :kind => :single_record_block, :data => data, :id => el.attributes['id'], :display => el.attributes['display'] }
	end
end

def self.from_element(el)
	Layout.new(el.attributes['id'], el)
end

end

end

