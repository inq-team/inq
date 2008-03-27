module Sticker

module Datasources

class AbstractSource

	attr_accessor :context, :id

	def initialize(id, el)
		@elem = el
		@id = id
	end

	def fetch_data
		raise NotImlementedError
	end

	def context=(context)
		@context = context
		context.sources[@id] = self		
		context.data[@id] = data
	end

	def data
		@inner = fetch_data
		@elem.elements.to_a('./apply-restrictions/apply-restriction').each do |r| 
			@inner = @context.restrictions[r.attributes['ref']].restrict(@inner)
		end
		@elem.elements.to_a('./apply-filters/apply-filter').each do |r|
			@inner = @context.filters[r.attributes['ref']].filter(@inner)
		end
		@inner
	end

end


class DetectSource < AbstractSource

	def fetch_data
		data = []
		testing = context.proxy.get_property('testing')
		testing.components.each do |component|
			data << {
				'name' => component.model.name,
				'shortname' => component.model.short_name,
				'vendor' => component.model.vendor,
				'group' => component.model.group && component.model.group.name,
				'serial' => component.serial
			}
                end if testing
		data
	end

end

class DatabaseSource < AbstractSource
	
	def fetch_data
		data = []
		computer = context.proxy.get_property('computer')
		computer.order.order_lines.each do |line|
			MyKit::Parser.parse(line.name).each do |component|
				data << {
					'name' => line.name,
					'vendor' => component.vendors.first,
					'group' => component.group
				}
			end
		end if computer && computer.order
		data
	end

end

class ComputerSource < AbstractSource
	
	def fetch_data
		data = []
		computer = context.proxy.get_property('computer')
		if computer
			data << {
				"short_title" => computer.short_title,
				"title" => computer.title,
				"name" => computer.model.name,
				"id" => computer.id,
				"manufacturing_date" => computer.manufacturing_date && computer.manufacturing_date.strftime("%d.%m.%Y"),
				"buyer_order_number" => computer.order && computer.order.buyer_order_number,
				"serial_no" => computer.serial_no,
			}
		end
		data
	end

end


def self.from_element(el)
	case el.attributes['source']
	when 'database'
		DatabaseSource.new(el.attributes['id'], el)
	when 'detects'
		DetectSource.new(el.attributes['id'], el)		
	when 'computer'
		ComputerSource.new(el.attributes['id'], el)
	end	
end


end

end
