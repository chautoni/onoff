add_image_handlers = function() {
  var thumbnails;
  thumbnails = $('#product-images ul.thumbnails');
  ($('#main-image')).data('selectedThumb', ($('#main-image img')).attr('src'));
  thumbnails.find('li').eq(0).addClass('selected');
  thumbnails.find('a').on('click', function(event) {
    ($('#main-image')).data('selectedThumb', ($(event.currentTarget)).attr('href'));
    ($('#main-image')).data('selectedThumbId', ($(event.currentTarget)).parent().attr('id'));
    // ($(this)).mouseout(function() {
    //   thumbnails.find('li').removeClass('selected');
    //   ($(event.currentTarget)).parent('li').addClass('selected');
    // });
    return false;
  });
  
  thumbnails.find('li').on('mouseenter', function(event) {
    $($('#main-image img')[0]).attr('src', ($(event.currentTarget)).find('a').attr('href'));
    $('.jqzoom').removeData('jqzoom');
    $('.jqzoom').attr('href', $($(event.currentTarget).find('a')).data('large-url'));
    $('.jqzoom').jqzoom();
  });
};

show_variant_images = function(variant_id) {
  var currentThumb, newImg, thumb;
  ($('li.vtmb')).hide();
  ($('li.vtmb-' + variant_id)).show();
  currentThumb = $('#' + ($('#main-image')).data('selectedThumbId'));
  if (!currentThumb.hasClass('vtmb-' + variant_id)) {
    thumb = $(($('ul.thumbnails li:visible.vtmb')).eq(0));
    if (!(thumb.length > 0)) {
      thumb = $(($('ul.thumbnails li:visible')).eq(0));
    }
    newImg = thumb.find('a').attr('href');
    ($('ul.thumbnails li')).removeClass('selected');
    thumb.addClass('selected');
    ($('#main-image img')).attr('src', newImg);
    ($('#main-image')).data('selectedThumb', newImg);
    ($('#main-image')).data('selectedThumbId', thumb.attr('id'));
  }
};

update_variant_price = function(variant) {
  var variant_price;
  variant_price = variant.data('price');
  if (variant_price) {
    ($('.price.selling')).text(variant_price);
  }
};

$(function() {
  add_image_handlers();
  if (($('#product-variants input[type="radio"]')).length > 0) {
    // show_variant_images(($('#product-variants input[type="radio"]')).eq(0).attr('value'));
  }
  ($('#product-variants input[type="radio"]')).click(function(event) {
    // show_variant_images(this.value);
    update_variant_price($(this));
  });
});
