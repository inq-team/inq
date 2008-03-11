# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def shadow(klass = 'shadow')
#        content_tag('div', '', :class => klass, :id => 'bottom') +
#        content_tag('div', '', :class => klass, :id => 'right') +
#        content_tag('div', '', :class => klass, :id => 'bottom_right')
end

def place_hint(id = 'hint', &block)
	id ||= 'hint'
	concat("<div id='hint_type_#{ id }' class='hint'><div class='hint_border'>" + capture(&block) + "</div></div>", block.binding);
end

def format_date(date)
	date.strftime("%d %b %Y %H:%M")
end

def format_delta(after, before)
	delta = (after - before).to_i()
	delta / 3600 / 24 > 3 ? sprintf("%.1f days", delta.to_f / (3600 * 24)) : delta > 60 ? sprintf("%02d:%02d", delta % (3600 * 24) / 3600, delta % (3600 * 24) % 3600 / 60) : "#{ delta } sec"
end

def datetime_tag(date)
	content_tag('span', format_date(date), :class => 'datetime')
end

def delta_tag(after, before)
	content_tag('span', format_delta(after, before), :class => 'timedelta')
end

def person_tag(person)
	content_tag('span', person && person.name || ('John Doe' ; '&nbsp;'), :class => person && person.name ? 'person' : 'bad_username')
end

def stage_tag(stage, js = nil)
	content = '' #content_tag(:span, stage[:stage], :class => "computer_stage_name")
	if stage[:person].blank? or stage[:status] == :planned
		content += content_tag(:span, stage[:stage].capitalize, :class => 'person')
	else 
		content += person_tag(stage[:person])	
	end	
	content += stage[:status] == :planned ? 'planned' : delta_tag(stage[:end] || Time.new, stage[:start] || Time.new) 
	content_tag('td', content_tag('div', content, :style => "background-image: url('/images/stages/#{ stage[:stage] }.png') ; background-position: 2px 50% ; background-repeat: no-repeat"), :class => "computer_stage_#{ stage[:status] }", :title => stage[:stage].capitalize, :onmouseover => js)
end

def progress_bar(stages)
	comments = stages.collect { |stage| content_tag(:b, stage[:stage].capitalize + ': ') + (stage[:comment] ? "#{ stage[:comment].gsub('"', "'") }" : '') }
	js = javascript_tag(<<_EOF_
		var GLOBAL_STAGES_COMMENTS = new Array();
		#{ (0..comments.size - 1).inject('') do |s, i| s + "GLOBAL_STAGES_COMMENTS[" + i.to_s + "] = \"" + comments[i] + "\";\n" end }
		function update_comments_box(obj) {
			var index = obj.cellIndex; 
			$('computer_stages_comment').cells[0].innerHTML = GLOBAL_STAGES_COMMENTS[index]; 
			var z = $('computer_stages_pointers'); 
			var i = 0;
			for(i = 0 ; i < z.cells.length ; i ++) {
				z.cells[i].className = i == index ? 'pointer_active' : 'pointer_inactive';
			}
		}
_EOF_
)
	content = content_tag('tr', content_tag('td', comments.first || '&nbsp;', :colspan => stages.size) , :id => 'computer_stages_comment')
	active = 0
	content += content_tag('tr', stages.collect { |stage| content_tag('td', '&nbsp;', :class => active ? (active = nil ; 'pointer_active') : 'pointer_inactive' ) }, :id => 'computer_stages_pointers')
	content += content_tag('tr', stages.collect { |stage| stage_tag(stage, 'update_comments_box(this);') }, :id => 'computer_stages') 
	js + content_tag(:div, content_tag('table', content_tag('tr', content)), :id => "progress_bar")
end



end
