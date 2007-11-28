# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def shadow(klass = 'shadow')
#        content_tag('div', '', :class => klass, :id => 'bottom') +
#        content_tag('div', '', :class => klass, :id => 'right') +
#        content_tag('div', '', :class => klass, :id => 'bottom_right')
end

def place_hint(klass = 'hint', &block)
	concat("<div class='#{ klass }'><div class='#{ klass }_border'>" + capture(&block) + "</div></div>", block.binding);
end

end
