function tick()
{
	var els = $$('tr.testing_stage_running td.testing_stage_span');
	els.each(function(el, index) {
		var st = el.innerHTML;
		var h = parseInt(st.substring(0, 2), 10);
		var m = parseInt(st.substring(3, 5), 10);
		var s = parseInt(st.substring(6, 8), 10);
		s++;
		if (s >= 60) { s = 0; m++; };
		if (m >= 60) { m = 0; h++; };
		el.update(h.toPaddedString(2) + ':' + m.toPaddedString(2) + ':' + s.toPaddedString(2));
	});
	setTimeout("tick()", 1000);
}

function startTicker()
{
	setTimeout("tick()", 1000);
}
