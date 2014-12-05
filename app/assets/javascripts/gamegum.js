var has_paginated = false;
var feat_indices = {};

function load_flash( tag ) {
	var params = $(tag).find("span");
	params = params.html().split('\\');

	$(tag).flash({
		src: params[0],
		width: params[1],
		height: params[2],
		quality: params[3]
	});
}

function before_comment() {
	// If they have moved to a different comments page and
	// want to comment, we move them to the first page before
	if (has_paginated) {
		$('.comment_area').load(location.href + "?page=1");
	}

	$('.comment_fail').remove();
	if ($("#comment_message").val() === '') {
		$('<h4 class="fail comment_fail">Please enter comment.</h4>').insertBefore('#comment_message');
		return false;
	}
	
	$("#comment_message").after("<span>Posting comment..</span>").slideDown();
}

function after_comment(responseText,statusText,xhr) {
	$(document).find("#new_comment h4,#new_comment span").remove();
	if (statusText === 'success') {
		$("#comment_message").before('<h4 class="obox hidden">Your comment has been added.</h4>');
		$(document).find("#new_comment h4.obox").fadeIn();
		$("#comment_message").val("");
		$("#comment_submit,#comment_message").attr("disabled", "disabled");
	}
}

function display_flash(slidedowns_open) {
  if (slidedowns_open > 0) {
    $('.twothirds.nopad').hide();
    $('#game').css('visibility','hidden');
  } else {
    $('.twothirds.nopad').show();
    $('#game').css('visibility','visible');
  }
}


// Startup

$(function() {

	// Generic AJAX (used in Adding Favorites)
	$(".toggle_ajax a").live('click', function() {
		$(this).fadeOut().parent().load(this.href);
		return false;
	});
	
	// Rate AJAX
	$(".rate a").live('click', function() {
		$(".rate ul").fadeOut().parent().load(this.href);
		return false;
	});
	
	// Modals
	$("a.modal").live('click', function(){
		$('#game').hide();
		var modal       = $('#'+$(this).attr('rel')+'_modal');
		var modal_width = 500;
		if ( modal.is('#game_modal') ) {
			var modal_width = parseInt(modal.find('span').html().split('\\')[1])+100;
			load_flash('#game_modal');
		}
		modal.dialog({
			modal:     true,
			width:     modal_width
		});
		return false;
	});
	$('.ui-dialog-titlebar-close').live('click',function(){
		$(document).find('#game').show();
	});
	$('.ui-widget-overlay').live('click', function(){
		$('.modal_window').dialog('close');
		$(document).find('#game').show();
	});
	
	// Tooltips
	$('#head .tip').tipsy({ offset: 8 });
	$('#content .tip').tipsy({ offset: 8, gravity: 's' });
	$('#content .rtip').tipsy({ offset: -100, gravity: 'w'});

	// Pagination AJAX on Games page
	$(".pagination.ajax a").live('click', function(){
		$(this).parent().after('<p class="inline">Loading...</p>');
		$("#comment_area").load(this.href);
		has_paginated = true;
		return false;
	});
	
  // Slidedown menus
  var start = '-240px';
  var end   = '40px';
  var open  = 0;

  $("#head .nav2 a[rel], #nav a").hover(
    function() { $('#slidedown_menus .'+$(this).attr('rel')).css('z-index','10000'); },
    function() { $('#slidedown_menus .'+$(this).attr('rel')).css('z-index','998'); });
  $("#head .nav2 a, #nav a,.slidedown").hover(
    function() { $(this).addClass('hovered'); },
    function() { $(this).removeClass('hovered'); });

	$("#head .nav2 a[rel], #nav a").hover(function() {
		var link = $(this);
		var target = $('#slidedown_menus .'+link.attr('rel'));
		if ( link.is('.hovered') ) {
		  open++;
			display_flash(open);
			target.animate({ top: end }, { duration: 300, queue: false });
		}
	}, function() {
		var link = $(this);
		var target = $('#slidedown_menus .'+link.attr('rel'));
		$("#nav").animate({ top: '0' }, 200, function() {
			if ( !target.is(".hovered") ) {
				target.stop().animate({ top: start }, { duration: 300, queue: false });
				open--;
				display_flash(open);
			}
		});
	});
	$(".slidedown").mouseleave(function() {
	  var slidedown = $(this);
	  $("#nav").animate({ top: '0' }, 300, function() {
		if ( !slidedown.is('.hovered') ) {
			slidedown.stop().animate({ top: start }, { duration: 300, queue: false });
			open--;
			display_flash(open);
		}
	  });
	});
	
	// Flash game load
	if ($('#game_object').length > 0) load_flash('#game');

	// Login username check
	$("#user_login").change(function(){
		$("label[for=user_login]").load("/users/new?login=" + this.value);
		return false;
	});

	// Description expand
	$('#short_description .continue a').live('click', function(){
		$('#short_description').hide();
		$('#long_description').show();
		return false;
	});
	$('#long_description .continue a').live('click', function(){
		$('#short_description').show();
		$('#long_description').hide();
		return false;
	});
	
	// Toggle delete checkboxes in form
	$("#toggledelete").click(function(){
		$("input[type=checkbox]:not(#toggledelete)").each(function(){
			this.checked = (this.checked) ? false : true;
		});
	});
	
	// Flash area
	$("#flash:has(h4)").hide().fadeIn(2000).animate({left:'50%'},2000,function() {
		$(this).fadeOut(1000);
	});
	
	// Prevent double-click
	$("input.submitbutton.auto-disable").click(function() {
      $(this).addClass('grey').attr('disabled',true);
      $(this).parent().submit();
	});
	
	// Add a new comment, slide down after
	$("#new_comment").ajaxForm({
		beforeSubmit: before_comment,
		success: after_comment,
		target: '#comment_area' 
	});
	
	// Search
	$('#query').focus(function(){
		if ($(this).val() === 'Search games and users') { $(this).val(''); }
	});
});

$.ajaxSetup({
	beforeSend: function(xhr) {
		xhr.setRequestHeader("Accept", "text/javascript");
	}
});
