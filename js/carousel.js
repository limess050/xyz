// JavaScript Documentfunction mycarousel_initCallback(carousel){    // Disable autoscrolling if the user clicks the prev or next button.    carousel.buttonNext.bind('click', function() {        carousel.startAuto(0);    });    carousel.buttonPrev.bind('click', function() {        carousel.startAuto(0);    });    // Pause autoscrolling if the user moves with the cursor over the clip.    carousel.clip.hover(function() {        carousel.stopAuto();    }, function() {        carousel.startAuto();    });};jQuery(document).ready(function() {    jQuery('#mycarousel').jcarousel({        auto: 5,        wrap: 'circular',        scroll: 1,        initCallback: mycarousel_initCallback    });    jQuery('#my-movies-carousel').jcarousel({        auto: 5,        scroll: 1,        wrap: 'circular',        initCallback: mycarousel_initCallback    });    jQuery('#sidebar1').jcarousel({        auto: 5,        scroll: 1,        wrap: 'circular',        initCallback: mycarousel_initCallback    });        jQuery('#sidebar2').jcarousel({        auto: 5,        scroll: 1,        wrap: 'circular',        initCallback: mycarousel_initCallback    });     });