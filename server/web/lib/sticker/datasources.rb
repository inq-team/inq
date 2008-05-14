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

	#HACK: one shoud better find some other way to filter out unsupported chars
	CYRFILTER = /[^ A-Za-z0-9\/.:()_*=@%;|\\{}+\[\]""''-^]+[, \t.]*/
	
	def fetch_data
		data = []
		computer = context.proxy.get_property('computer')
                lines = computer.order.order_lines
                unless lines.blank?
                        min = lines.inject(lines.first.qty) { |i, j| i > j.qty ? j.qty : i }
			lines.each do |line|
				Mykit::Parser.parse(line.name).each do |component|
					name = line.name.chars.gsub(CYRFILTER, '')
					component.vendors.each { |v| name = name.gsub(/#{ v }\s*/i, '') }
					data << {
						'name' => name,
						'vendor' => component.vendors.first,
						'group' => component.group,
						'count' => line.qty % min == 0 ? line.qty / min : line.qty,
						'sku' => line.sku.chars.gsub(CYRFILTER, '')
					}
				end
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
				"checker_id" => computer.checker && computer.checker.id,
				"order_code" => computer.order && computer.order.code,
			}
		end
		data
	end

end

class CustomParamsSource < AbstractSource

	PATTERN = /([^=]+)\s*=\s*"(([^"]|"")*)"/
	
	def fetch_data
		data = []
		params = context.proxy.get_property('custom_sticker_params')
		if params
			if params.is_a? Hash 
				data << params
			else
				h = {}
				m = params.to_s.strip.match(PATTERN)
				while m
					h[m[1].strip] = m[2].gsub('""', '"')
					m = m.post_match.match(PATTERN)
				end
				data << h
			end
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
	when 'custom'
		CustomParamsSource.new(el.attributes['id'], el)
	end	
end


end

end
