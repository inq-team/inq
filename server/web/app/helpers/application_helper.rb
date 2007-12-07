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
	now = Time.new()
	if date.strftime("%W") == now.strftime("%W") and now.day != date.day
		fmt = "%A %H:%M"
	elsif now.year == date.year 
		if now.month == date.month 
			if now.mday == date.mday
				fmt = "Today %H:%M"
			else
				fmt = "%B %d"
			end
		else
			fmt = "%B %d %Y"
		end
	end
	date.strftime(fmt)
end

def format_delta(after, before)
	delta = (after - before).to_i()
	"#{ delta / 3600 }:#{ delta % 3600 / 60 }:#{ delta % 3600 % 60 }"
end

end
