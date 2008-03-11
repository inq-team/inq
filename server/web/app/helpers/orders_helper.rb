module OrdersHelper

def trident_bar(by_stage, total, stages)
	table = content_tag(:tr, stages.collect { |s| content_tag(:th, '&nbsp;' + content_tag(:span, s.capitalize + '&nbsp;'), :title => s.capitalize, :style => "background-image: url('/images/stages/#{ s }_small.png')" ) }) + content_tag(:tr, content_tag(:td, '&nbsp;', :colspan => stages.size), :class => 'dummy')
	table += (0 .. stages.size - 1).collect do |i|
		stage = stages[i]
		count = by_stage[stage]
		if count > 0		
			content = (0..i - 1).collect { |j| content_tag(:td, content_tag(:div, '&nbsp;'), :class => 'computer_stage_finished', :title => stages[j].capitalize) }.join 
			content += content_tag(:td, content_tag(:div, "#{ count }/#{ total }"), :class => 'computer_stage_running', :title => stage.to_s.capitalize)
			content += (i + 1 .. stages.size - 1).collect { |j| content_tag(:td, content_tag(:div, '&nbsp;'), :class => 'computer_stage_planned', :title => stages[j].capitalize) }.join
			content_tag(:tr, content, :class => 'computer_stage_row')
		else 
			""
		end
	end.join
	content_tag(:div, content_tag(:table, table), :id => 'trident_bar')
end

end
