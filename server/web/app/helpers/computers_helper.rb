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
	testing = computer.last_testing 
	stage = testing.last_stage 
	state = :before
	if testing.testing_stages.size > 0
		if stage
			state = stage.result == 0 ? :running : :failed			 
		else
			state = :after
		end
	end
	percent = { :running => '50%', :failed => '50%', :before => '0%', :after => '100%' }[state]
	memo = render(:partial => 'memo', :locals => { :computer => computer, :testing => testing, :stage => stage, :state => state })
	progress = content_tag(:div, content_tag(:div, '&nbsp;', :class => state, :style => "width: #{ percent }"), :class => 'progress', :title => percent )
	content_tag(:div, progress + link_to(computer.short_title, { :action => 'show', :id => computer.id}) + memo, :class => 'computer_on_shelf')
end

def def_shelf(name, layout, computers, bonus = {})
	layout.collect do |a|  
		border = a.size 
        	a.collect do |i|
			border -= 1 
			if i
				content = (c = computers[ shelf = "#{ name }#{ i }" ]) ? shelf_content(c) : ""
				content_tag(:td, content + content_tag(:p, shelf, { :class => 'shelf_title' }), { :id => "shelf_#{ name }-#{ i }", :class => "#{ c ? 'occupied' : 'free' }_shelf"}.merge(border == 0 ? bonus: {}) )
			else
				content_tag(:td, '', { :class => 'hole' }.merge(border == 0 ? bonus : {}))
			end
                end 
        end
end

def stack_of_shelves(computers, arrays, bonus)
	y = []
	border = arrays.size
	(z = arrays.collect() { |a| border -= 1 ; def_shelf(a.first, a.last, computers, border > 0 ? bonus : {} ) }).first.size.times { |i| y[i] = z.inject([]) { |a, b| a << b[i] } }
	y	
end

def def_stack(computers, * arrays)
	content_tag(:table, stack_of_shelves(computers, arrays, {:style => 'border-right: 3px double #888;'}).collect() { |r| content_tag(:tr, r.join()) }.join(), :class => 'stack')
end

def def_nice_stack(computers, * names)
	def_stack(computers, *names.collect() { |n| [n, shelf_type_G()] })
end

def dev_to_spans(dev, spans)
	dev.split(/\s+/).collect { |s| (sp = spans.find { |ss| ss[:target] == s }) ? content_tag(:span, sp[:spans].collect { |r| content_tag(:span, r[:string], :class => "dev_span_#{ r[:good] ? r[:chunk] ? 'chunk' : 'good' : 'bad' }") }.join, :name => s) : content_tag(:span, s, :class => 'dev_span_unmatched') }.join(' ')
end

end
