function add_new_color(e){
  $(this).html("<input type='text' placeholder='New color...' class='new_color_input'></input>")
  $('.new_color_input').on('click', function(e){
    e.stopPropagation()
  });
  $('.new_color_input').on('keypress', function(e){
    if (e.which == 13){
      var form = $('#color-form').find('form');
      form.find("input[name='color']").val($(this).val());
      $.ajax({
        type: "POST",
        url: form.attr('action'),
        data: form.serialize()
      });
    }
  }); 
};
