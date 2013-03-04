$(function() {
  $(document).on('click', '#listing_products td.product-detail', function(e) {
    href = $(this).data('href');
    if(href) {
      window.location = href;
    }
  });

  $(document).on('click', 'form.import-products-form a.button', function(e) {
    $('#file').click();
  });

  $(document).on('change', 'form.import-products-form #file', function(e) {
    if ($(this).val() == '') {
      $('form.import-products-form #import-btn').hide();
    } else {
      $('form.import-products-form #import-btn').show();
    }
  });
});
