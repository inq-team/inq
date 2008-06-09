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
	format_delta1((after - before).to_i)
end

def format_delta1(delta)
	if delta / 3600 / 24 > 0
		sprintf("%.1fd", delta.to_f / (3600 * 24))
	elsif delta > 3600
		sprintf("%dh %dm", delta % (3600 * 24) / 3600, delta % (3600 * 24) % 3600 / 60)
	elsif delta > 60
		sprintf("%dm %ds", delta / 60, delta % 60)
	else
		"#{delta}s"
	end
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

end
