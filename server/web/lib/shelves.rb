require 'rexml/document'
require 'builder'

module Shelves

class Config
	attr_reader :groups, :name

	def [](shelf)
		@shelves[shelf]
	end

	def by_ip(ip)
		if ip =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/
			ip = ($1.to_i() << 24) | ($2.to_i() << 16) | ($3.to_i() << 8) | ($4.to_i())
			@shelves.values.find() do |v|
 			        if v.ipnet =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/
	                	        (($1.to_i() << 24) | ($2.to_i() << 16) | ($3.to_i() << 8) | ($4.to_i())) == ip & (0xffffffff - ((1 << (32 - $5.to_i())) - 1))
				end
			end
		end
	end

	def by_ipnet(net)
		@ipnets[net]
	end
	
	def initialize(filename)
		doc = REXML::Document.new(File.new(filename))
		root = doc.root
		@name = root.attributes['name']
		@shelves = {} 
		@ipnets = {}
		prefix = '';
		@groups = root.get_elements('group').inject([]) { |a, e| 
			ea = e.attributes
			gr = Group.new(ea['name'], prefix + (ea['name'] || ''), ea['prefix'])
			pf1 = prefix + gr.prefix
			gr.stacks = e.get_elements('stack').inject([]) { |b, f|
				fa = f.attributes
				st = Stack.new(fa['name'], pf1 + (fa['name'] || ''), fa['prefix'], fa['template'])
				pf2 = pf1 + st.prefix
				st.rows = f.get_elements('row').inject([]) { |c, g|
					ga = g.attributes
					rw = Row.new(ga['name'], pf2 + (ga['name'] || ''), ga['prefix'], ga['colour'])
					pf3 = pf2 + rw.prefix
					cl1 = rw.colour
					rw.shelves = g.get_elements('shelf').inject([]) { |d, h|
						ha = h.attributes
						sh = Shelf.new(ha['name'], pf3 + (ha['name'] || ''), ha['prefix'], ha['colour'] || cl1, ha['kind'], ha['ipnet'])
						@shelves[sh.full_name] = sh
						@ipnets[sh.ipnet] = sh
						pf4 = pf3 + sh.prefix
						cl2 = sh.colour

						d << sh						
					}					
					c << rw
				}
				b << st
			} 
			a << gr
		}
	end

	def to_xml()
		result = ''
		builder = Builder::XmlMarkup.new(:target => result, :indent => 2)
		builder.instruct!
		builder.shelves('name' => @name) do |root|
			groups.each do |gr|
				root.group('name' => gr.name, 'prefix' => gr.prefix) do |group|
					gr.stacks.each do |st|
						group.stack('name' => st.name, 'prefix' => st.prefix, 'template' => st.template) do |stack|
							st.rows.each do |rw|
								stack.row('name' => rw.name, 'prefix' => rw.prefix, 'colour' => rw.colour) do |row|
									rw.shelves.each do |sh|
										row.shelf('name' => sh.name, 'prefix' => sh.prefix, 'colour' => sh.colour, 'kind' => sh.kind, 'ipnet' => sh.ipnet)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

class Group
	attr_accessor :name, :full_name, :prefix, :stacks

	def initialize(name, full_name, prefix, stacks = [])
		@name = name || ''
		@full_name = full_name || ''
		@prefix = prefix || ''
		@stacks = stacks
	end
end

class Stack
	attr_accessor :name, :full_name, :prefix, :template, :rows

	def initialize(name, full_name, prefix, template, rows = [])
		@name = name || ''
		@full_name = full_name || ''
		@prefix = prefix || ''
		@template = template || ''
		@rows = rows
	end
end

class Row
	attr_accessor :name, :full_name, :prefix, :colour, :shelves

	def initialize(name, full_name, prefix, colour, shelves = [])
		@name = name || ''
		@full_name = full_name || ''
		@prefix = prefix || ''
		@colour = colour
		@shelves = shelves
	end
end

class Shelf
	attr_accessor :name, :full_name, :prefix, :colour, :kind, :ipnet

	def initialize(name, full_name, prefix, colour, kind, ipnet)
		@name = name || ''
		@full_name = full_name || ''
		@prefix = prefix || ''
		@colour = colour
		@ipnet = ipnet || '' 
		@kind = kind.to_sym()
	end	

	def get_addresses(fmt = nil)
		fmt ||= "%1$d.%2$d.%3$d.%4$d"
                if ipnet =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/
                        net = ($1.to_i() << 24) | ($2.to_i() << 16) | ($3.to_i() << 8) | ($4.to_i())
                        (2..(1 << (32 - $5.to_i())) - 2).inject([]) { |a, i| a << (net | i) }.collect { |j| sprintf(fmt, j >> 24, (j >> 16) & 255, (j >> 8) & 255, j & 255) }
                else
                        raise("Malformed ip network address")
                end
        end

end

end
