$(function() {
	$(document).on('click', '#upload_button', function(e) {
		$('#image_attachment').click();
	});

	$(document).on('click', '#save_edit_images_link', function(e) {
		e.preventDefault();
		$('#submit-product-form').click();
	});

	$(document).on('change', 'select', function(e) {
		if (this.selectedIndex != this.options.length -1) return;

    var new_name = prompt('');
    if(!new_name.length) return;
    var textbox = document.createElement('input');
    textbox.value = new_name;
    this.parentNode.appendChild(textbox);
	})

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
