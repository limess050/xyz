
<!-- Paste this code into an external JavaScript file named: bookMark.js  -->

/* This script and many more are available free online at
The JavaScript Source :: http://javascript.internet.com
Created by: Philip Myers :: http://virtualipod.tripod.com/bookmark.html */

function bookmark(url,title){
  if ((navigator.appName == "Microsoft Internet Explorer") && (parseInt(navigator.appVersion) >= 4)) {
  window.external.AddFavorite(url,title);
  } else if (navigator.appName == "Netscape") {
    window.sidebar.addPanel(title,url,"");
  } else {
    alert("Press CTRL-D (Netscape) or CTRL-T (Opera) to bookmark");
  }
}


