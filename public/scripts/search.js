$(document).ready(function(){
	$('#more-link').click(function(){
		$(this).html('<img src="/images/search-loader.gif"/>');
		$.get($(this).attr('href'), function(html) {
			var res = $(html).find('.result');
    	$("#results").append(res);
    });
		$(this).ajaxComplete(function(){
			$(this).html('View more results');
		});
		$(this).attr('href', function(){
			var nxt = $(this).attr('href').split(/s=(\d+)/);
			if(parseInt(nxt[1]) < parseInt($('#hits').text())) {
				nxt[1] = 's=' + (parseInt(nxt[1]) + 5);					
			} else {
				$(this).hide();
			}				
			return nxt.join('');
		});
		return false;
	});
});