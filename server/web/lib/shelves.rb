require 'rexml/document'
require 'builder'

module Shelves

class Config
	attr_reader :groups, :name

	def [](shelf)
		@shelves[shelf]
	end
	
	def initialize(filename)
		doc = REXML::Document.new(File.new(filename))
		root = doc.root
		@name = root.attributes['name']
		@shelves = {} 
		prefix = '';
		@groups = root.elements.inject('group', []) { |a, e| 
			ea = e.attributes
			gr = Group.new(ea['name'], prefix + (ea['name'] || ''), ea['prefix'])
			pf1 = prefix + gr.prefix
			gr.stacks = e.elements.inject('stack', []) { |b, f|
				fa = f.attributes
				st = Stack.new(fa['name'], pf1 + (fa['name'] || ''), fa['prefix'], fa['template'])
				pf2 = pf1 + st.prefix
				st.rows = f.elements.inject('row', []) { |c, g|
					ga = g.attributes
					rw = Row.new(ga['name'], pf2 + (ga['name'] || ''), ga['prefix'], ga['colour'])
					pf3 = pf2 + rw.prefix
					cl1 = rw.colour
					rw.shelves = g.elements.inject('shelf', []) { |d, h|
						ha = h.attributes
						sh = Shelf.new(ha['name'], pf3 + (ha['name'] || ''), ha['prefix'], ha['colour'] || cl1, ha['kind'], ha['ipnet'])
						@shelves[sh.full_name] = sh
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
end

end
