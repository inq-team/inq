module ComputersHelper

HOR = 3
VER = 5 

# shelves A, C, D, E
def shelf_type_A()
	(1..VER).to_a.reverse.inject([]) { |a, i| a << ((1 + (i - 1) * HOR) .. (i * HOR)).to_a }
end

#shelf B
def shelf_type_B()
	fix = 2
	shift2 = 2
	(1..VER).to_a.reverse.inject([]) { |a, i| a << (1..HOR).to_a().collect() { |j| j == 1 || j == HOR || i < VER - fix ? i + (j -1 ) * (VER - fix) + (j > 1 ? shift2 : 0) : nil  } }
end

#shelf E
def shelf_type_E()
	fix = 2
	shift2 = 2
	(1..(VER - fix)).to_a.reverse.inject(((VER - fix + 1)..VER).to_a.inject([]) { |a, i| a << (1..HOR).to_a.collect() { nil } }) { |a, i| a << (1..HOR).to_a().collect() { |j| i + (j -1 ) * (VER - fix) + (j > 1 ? shift2 : 0)   } }
end

#shelves G, H, I, J, K, L
def shelf_type_G()
	hole = 2
	(1..VER).to_a.reverse.inject([(1..(VER * HOR)).to_a.inject([]) { |a, i| i > VER && i < VER * (HOR - 1) + 1 && (i - VER) % VER == hole ? a << nil : a << (a.empty? ? i : a.last ? a.last + 1 : a[-2] + 1) }, []]) { |a, i|  a.last << (1..HOR).to_a.collect { |j|  a.first[ (HOR - j) * VER + (VER - i) ] } ; a }.last
end

def shelf_content(computer)
	computer.id.to_s
end

def def_shelf(name, layout, computers)
	layout.collect do |a|  
        	a.collect do |i| 
			if i
				content = (c = computers[ shelf = "#{ name }#{ i }" ]) ? shelf_content(c) : ""
				content_tag(:td, content_tag(:p, shelf, :class => 'shelf_title') + content, :id => "shelf_#{ name }-#{ i }", :class => "#{ c ? 'occupied' : 'free' }_shelf")
			else
				content_tag(:td, '', :class => 'hole')
			end
                end 
        end
end

def stack_of_shelves(computers, arrays)
	y = []
	(z = arrays.collect() { |a| def_shelf(a.first, a.last, computers) }).first.size.times { |i| y[i] = z.inject([]) { |a, b| a << b[i] } }
	y	
end

def def_stack(computers, * arrays)
	content_tag(:table, stack_of_shelves(computers, arrays).collect() { |r| content_tag(:tr, r.join()) }.join(), :class => 'stack')
end

def def_nice_stack(computers, * names)
	p names.collect() { |n| [n, shelf_type_G()] }
	def_stack(computers, *names.collect() { |n| [n, shelf_type_G()] })
end

end
