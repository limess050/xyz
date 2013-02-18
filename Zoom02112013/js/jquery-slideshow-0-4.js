/* JQuery Slideshow 0.4
	by Aaron Lozier 2008 (lozieraj-[at]-gmail.com) (twitter: @ajlozier)
	version 0.2
		* made adjustments that allow you to activate multiple slide shows on one page
	version 0.3
		* added "CrossWipe" transition effect.  looks kind of like windshield wiper or a book page turning
		* integrated with jquery.dimensions.js which is necessary for CrossWipe and probably other effects as well
	version 0.4
		* there was confusion (with myself) about whether the slideClass and the slideButton classes refers to the list <ul>
		element or the div "containing" the <ul>.  it refers now to the <ul> element itself.  (see example below).
		* you may now include the prevClass and the nextClass in the same list (see example again)
		* fixed bug - clicking Prev or Next did not pause animation as it should have.
		* Note: Buttons must be <a> tags.  See below.

	To Do:
		* Add documentation and examples!!  Coming soon, I promise.
		
	Dependencies:
		* jQuery 1.2.x
		* jquery.timers.js (http://jquery.offput.ca/every/)
		* jquery.dimensions.js (http://plugins.jquery.com/project/dimensions)
 
	Usage:
	
	$('#slideshow').slideshow();
	
	Note: At this time it is required that all CSS/XHTML be handled outside the plugin.  Here is a code example:
	
	<div id="slideshow">
		<ul class="slideClass">
			<li><img src="image-1.jpg" alt="Slide 1" /></li>
			<li><img src="image-2.jpg" alt="Slide 2" /></li>
			<li><img src="image-3.jpg" alt="Slide 3" /></li>
		</ul>
		<ul class="slideButton">
			<li><a class="prevClass">Prev</a></li>
			<li><a class="selected">1</a></li>
			<li><a>2</a></li>
			<li><a>3</a></li>
			<li><a class="nextClass">Next</a></li>
		</ul>
	</div>
	
	<style type="text/css">
		*{
			margin:0;
			padding:0;
		}
		#slideshow{
			position:relative;
			top:0px;
			left:0px;
		}
		.slideClass,.slideButton{
			list-style:none;
		}
		.slideClass li{
			position:absolute;
			top:0px;
			left:0px;
		}
		.slideButton{
			clear: both;
		}
		.slideButton li
		{
			float:left;
			margin: 0 5px 0 0;
		}	
	</style>
*/

(function(jQuery){
 jQuery.fn.slideshow = function(options) {
    
	var defaults = {
		slideDuration: 5000,					//in ms, time between slides
		fadeDuration: 'slow',					//in ms (or jQuery alias - e.g. slow, fast, etc) duration of fade 
		slidesClass: 'slideClass', 				//class of slides UL
		buttonsClass: 'slideButton',			//class of buttons UL
		nextClass: 'nextClass',					//class of "next" button
		prevClass: 'prevClass',					//class of "prev" button
		pauseClass: 'pauseClass',				//class of "pause" button
		startClass: 'startClass',				//class of "start" button
		reverseClass: 'reverseClass',			//class of "reverse" button
		topZIndex: 100,							//z-index of top slide
		stayOn: false,							//stay on a particular slide (e.g. 1,2,3) if false, slideshow automatically animates
		stopOnSelect: true,						//stop slideshow if user presses controls
		direction: 1,							//direction: 1 forward, -1 backward
		transitionType: 'crossFade',				//crossFade, crossWipe
		slideWidth:	'575px'					//it was either this or require the dimensions plugin
	};
  
	var options = jQuery.extend(defaults, options);
	var pass = 0;
    
  return this.each(function() {

		var curslide = 0;
		var prevslide = 0;	
		var num_slides = 0;
		var num_buttons = 0;
		var slide_width = '0px';

		pass++;

		obj = jQuery(this);
		obj.data('slideshowed',true);
		
		var objId = obj.attr('id');
		
		num_slides = obj.find('.'+ options.slidesClass).eq(0).children('li').length;
		slide_width = obj.find('.'+ options.slidesClass).eq(0).children('li').eq(0).outerWidth();
		
		var button_selector = '.'+options.buttonsClass+' li a:not(".prevClass.nextClass")';
		num_buttons = obj.find(button_selector).length;

		obj.find(button_selector).eq(0).addClass('selected');
		
		obj.find('.'+ options.slidesClass).each(function(){
			var i = 0;

			jQuery(this).children('li').each(function(){
				i++;
				jQuery(this).css('z-index',(options.topZIndex-i));
				if(i>1){
					jQuery(this).css('display','none');
				}
			});
		});
		
		if(options.stayOn){
			curslide = (options.stayOn-1);
			doSlide();
		} else {
			obj.everyTime(options.slideDuration, 'animateSlides'+pass, function(){
				moveSlide(options.direction,objId);
			});
		}		

		function moveSlide(direction,objId){
			jQuery('ul.debug').append('<li>moveSlide +  / ' + direction+'</li>');

			curslide = curslide + direction;
			prevslide = curslide - direction;
			switch(direction){
				case 1:
					if(curslide==num_slides){
						curslide = 0;
						prevslide = (num_slides - 1);
					}
					break;
				case -1:
					if(curslide<0){
						curslide = (num_slides - 1);
						prevslide = 0;
					}
					break;
			}
			
			doSlide(objId);
		}
			
		obj.find('.'+options.prevClass).click(function(){
			if(!$(this).hasClass('inactive')){
				obj.stopTime('animateSlides'+pass);
				moveSlide(-1,objId);	
			}
		 });		
		obj.find('.'+options.nextClass).click(function(){
			if(!$(this).hasClass('inactive')){
				obj.stopTime('animateSlides'+pass);
				moveSlide(1,objId);		
			}
		 });	
		obj.find('.'+options.pauseClass).click(function(){
				obj.stopTime('animateSlides'+pass);											 
		 });
		obj.find('.'+options.startClass).click(function(){
			obj.everyTime(options.slideDuration, 'animateSlides'+pass, function advanceSlide() {
				moveSlide(options.direction,objId);
			});											 
		 });		
		
		obj.find('.'+options.reverseClass).click(function(){
			options.direction = (options.direction * (-1));									 
		 });		
		
				
		obj.find(button_selector).click(function(){
			var thisObj = jQuery('#'+objId);
			if(options.stopOnSelect){
				obj.stopTime('animateSlides'+pass);
			}
			curslide = jQuery(thisObj.find(button_selector)).index(this);
			doSlide(objId);
		});
		
		function doSlide(objId){
			var thisObj = jQuery('#'+objId);
			thisObj.find(button_selector).removeClass('selected');
			thisObj.find(button_selector).eq(curslide).addClass('selected');
		
			thisObj.find('.'+ options.slidesClass).each(function(){
					switch(options.transitionType){
						case 'crossFade':
							jQuery(this).children('li').eq(curslide).animate({opacity:'show'},options.fadeDuration);
							jQuery(this).children('li').not(jQuery(this).children('li').eq(curslide)).animate({opacity:'hide'},options.fadeDuration);
							break;
						case 'crossWipe':
							if(curslide>prevslide){
								jQuery(this).children('li').eq(curslide).show();
								jQuery(this).children('li').eq(prevslide).animate({width:'0px'},options.fadeDuration,function(){
									$(this).css('display','none');
								});
							} else {
								
								jQuery(this).children('li').eq(curslide).animate({width:slide_width},options.fadeDuration,function(){
									//pass
								});
							}
							
							if(curslide==0){
								thisObj.find('.'+options.prevClass).addClass('inactive');
							} else {
								thisObj.find('.'+options.prevClass).removeClass('inactive');
							}
							
							if(curslide==(num_slides-1)){
								thisObj.find('.'+options.nextClass).addClass('inactive');
							} else {
								thisObj.find('.'+options.nextClass).removeClass('inactive');
							}							
							break;							
					}
			});
		}	
	
  });
 };
})(jQuery);
