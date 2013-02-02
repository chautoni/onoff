$(document).ready ->
  if $("#product_tag_list_field #product_tag_list").length > 0
    $("#product_tag_list_field #product_tag_list").chosen
      create_option_text: 'Add tag',
      create_option: true
