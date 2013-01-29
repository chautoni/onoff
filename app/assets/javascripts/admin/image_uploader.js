$(function() {
	$(document).on('click', '#upload_button', function() {
		$('#image_attachment').click();
	});

	$(document).on('click', '#save_edit_images_link', function(e) {
		e.preventDefault();
		$('#submit-product-form').click();
	});

	$('#new_image').fileupload({
	    dropZone: $('#wrapper'),
	    url: '/admin/products/' + $('#uploader').data('product-permalink') + '/images'
	});
});
