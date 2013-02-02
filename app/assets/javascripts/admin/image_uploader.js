$(function() {
  $(".chosen_field").chosen();
  $('.new_color_link').on('click',add_new_color);

  $(document).on('click', '#upload_button', function(e) {
		$('#image_attachment').click();
	});

	$(document).on('click', '#save_edit_images_link', function(e) {
		e.preventDefault();
		$('#submit-product-form').click();
	});

	$('#new_image').fileupload({
	    dropZone: $('#wrapper'),
	    url: '/admin/products/' + $('#uploader').data('product-permalink') + '/create_image'
	});

	$('#new_slide').fileupload({
	    dropZone: $('#wrapper'),
	    url: '/admin/general_settings/create_slide'
	});

	$(document).on('click', '#slide_upload_button', function(e) {
		$('#slide_attachment').click();
	});

	$(document).on('click', '#save_slideshow_link', function(e) {
		e.preventDefault();
		$('#submit-slideshow-form').click();
	});
});
