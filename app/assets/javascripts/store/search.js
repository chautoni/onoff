$(function() {
	initiate_filter();
});

function initiate_filter() {
	$('#search-filter li.filter').hover(
		function() {
			$(this).find('ul.filter-options').show();
		},
		function() {
			$(this).find('ul.filter-options').hide();
		}
	);
}