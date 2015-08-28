var DATA={};

$(document).ready(function(){
	$.ajax({
		url: "http://urinx.sinaapp.com/vu.json?tag=&page=1",
		success: function(data){
			DATA=JSON.parse(data);
			for (var col of ['new','hot','event','recommen']) {
				setItem(col);
			}
		},
	});
});

function setItem(col){
	$('.'+col+' .card').each(function(i){
		var a=$(this).parent();
		var img=$(this).find('.card-image img');
		var title=$(this).find('.card-content p');
		var comment=$(this).find('.card-action span')[0];
		var view=$(this).find('.card-action span')[1];
        
        var d=DATA[col][i];
        var query='src='+d['src']+'&thumbnail='+d['thumbnail'];

		a.attr('href','vu://openVideoView?'+query);
		img.attr('src', DATA[col][i]['thumbnail']);
		title.text(htmlDecode(DATA[col][i]['title']));
		comment.textContent=DATA[col][i]['comments'];
		view.textContent=DATA[col][i]['views'];
	})
}

function htmlDecode(str) {
    return $('<span/>').html(str).text();
}