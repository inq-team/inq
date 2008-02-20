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
	delta % 3600 / 60 > 0 ? sprintf("%02d:%02d", delta / 3600, delta % 3600 / 60) : "#{ delta % 3600 % 60 } sec"
end

def datetime_tag(date)
	content_tag('span', format_date(date), :class => 'datetime')
end

def person_tag(person)
	content_tag('span', person && person.name || 'John Doe', :class => person && person.name ? 'person' : 'bad_username')
end



end
