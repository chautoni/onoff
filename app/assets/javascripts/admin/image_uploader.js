$(function() {
	$(document).on('click', '#upload_button', function() { 
		$('#image_attachment').click();
	});

	$('#new_image').fileupload({
	    dropZone: $('#wrapper'),
	    url: '/admin/products/' + $('#uploader').data('product-permalink') + '/images'
	});
});
