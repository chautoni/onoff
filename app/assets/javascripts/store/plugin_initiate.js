$(function() {
	// ----------- Initiate jqzoom -----------
	var jqzoom_options = {
  	title: false
  };
	$('.jqzoom').jqzoom(jqzoom_options);

	// ----------- Initiate jQuery carousel -----------
	$('#product-thumbnails-slide').tinycarousel({ display: 2 });

	// ----------- Initiate jCarousel ------------
	$('#slideshow ul').carouFredSel({
		auto: true,
		items: {
			visible: 1
		},
		width: "auto",
		heigth: "auto",
		prev: '#slide-prev',
		next: '#slide-next',
		pagination: {
			container: "#slide-pager",
			anchorBuilder: function(nr, item) {
			    return '<a href="#'+nr+'" class="slide-pagination"><span">&bull;</span></a>';
			}
		},
	});

	if ($('#slideshow ul')) {
		var width = screen.width;
		$('#slideshow ul li img').css('width', width);
	}

	// ----------- Initiate Homepage Collection Carousel ------------
	var carousel = $('ul.collection-carousel').waterwheelCarousel();

	$(document).on('click', '#collection .collection-carousel-container a.collection-carousel-prev', function(e) {
		e.preventDefault();
		carousel.prev();
	});

	$(document).on('click', '#collection .collection-carousel-container a.collection-carousel-next', function(e) {
		e.preventDefault();
		carousel.next();
	});

	// ----------- Initiate Homepage Collection Carousel ------------
	$('.img-nav').adipoli({
		'startEffect' : 'grayscale',
    'hoverEffect' : 'popout'
	});
});

window.onload = function() {
	if ($('#slideshow ul')) {
		var height = $($('#slideshow ul li img')[0]).css('height');

		$('.caroufredsel_wrapper').css('height', height);
		$('#slideshow ul').css('height', height);
		$('#slideshow ul li').css('height', height);

		$('#slide-prev').css('top', (parseInt(parseInt(height)/2)+"px"));
		$('#slide-next').css('top', (parseInt(parseInt(height)/2)+"px"));
	}
};

