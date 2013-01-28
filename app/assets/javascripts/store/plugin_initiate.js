$(function() {
	// ----------- Initiate jqzoom -----------
	var jqzoom_options = {  
  	title: false
  };
	$('.jqzoom').jqzoom(jqzoom_options);
	// ----------- Initiate jQuery carousel -----------
	 $('#product-thumbnails-slide').tinycarousel({ display: 2 });

});
