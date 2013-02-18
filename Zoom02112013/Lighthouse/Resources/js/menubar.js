// Determine browser and version.
function Browser() {
	var ua, s, i;

	this.isIE    = false;  // Internet Explorer
	this.isNS    = false;  // Netscape
	this.isMac    = false;  // Macintosh
	this.version = null;

	ua = navigator.userAgent;

	s = "Mac";
	if ((i = ua.indexOf(s)) >= 0) {
		this.isMac = true;
	}

	s = "MSIE";
	if ((i = ua.indexOf(s)) >= 0) {
		this.isIE = true;
		this.version = parseFloat(ua.substr(i + s.length));
		return;
	}

	s = "Netscape6/";
	if ((i = ua.indexOf(s)) >= 0) {
		this.isNS = true;
		this.version = parseFloat(ua.substr(i + s.length));
		return;
	}

	// Treat any other "Gecko" browser as NS 6.1.
	s = "Gecko";
	if ((i = ua.indexOf(s)) >= 0) {
		this.isNS = true;
		this.version = 6.1;
		return;
	}
}

var browser = new Browser();

// Global variable for tracking the currently active button.
var activeButton = null;

// Capture mouse clicks on the page so any active button can be
// deactivated.
if (browser.isIE) document.onmousedown = pageMousedown;
if (browser.isNS) document.addEventListener("mousedown", pageMousedown, true);

function pageMousedown(event) {
	var el;

	// If there is no active menu, exit.
	if (!activeButton) return;

	// Find the element that was clicked on.
	if (browser.isIE) el = window.event.srcElement;
	if (browser.isNS) el = (event.target.className ? event.target : event.target.parentNode);

	// If the active button was clicked on, exit.
	if (el == activeButton) return;

	// If the element clicked on was not a menu button or item, close the
	// active menu.
	if (el.className != "menuButton"  && el.className != "menuItem" &&
		el.className != "menuItemSep" && el.className != "menu") resetButton(activeButton);
}

var vis = "visible";

function buttonClick(button, menuName) {
	// Blur focus from the link to remove that annoying outline.
	button.blur();

	// Associate the named menu to this button if not already done.
	if (!button.menu) button.menu = document.getElementById(menuName);

	// Reset the currently active button, if any.
	if (activeButton && activeButton != button) resetButton(activeButton);

	// Toggle the buttons state.
	if (button.isDepressed) resetButton(button);
	else depressButton(button);

	return false;
}

function buttonMouseover(button, menuName) {
	// If any other button menu is active, deactivate it and activate this one.
	// Note: if this button has no menu, leave the active menu alone.
	if (activeButton && activeButton != button) {
		resetButton(activeButton);
		if (menuName) buttonClick(button, menuName);
	}
}

function depressButton(button) {
	var w, dw, x, y;

	// Change the button's style class to make it look like it's depressed.
	button.className = "menuButtonActive";

	// For IE, set an explicit width on the first menu item. This will
	// cause link hovers to work on all the menu's items even when the
	// cursor is not over the link's text.
	if (browser.isIE && !browser.isMac) {
		if (!button.menu.firstChild.style.width) {
			w = button.menu.firstChild.offsetWidth;
			button.menu.firstChild.style.width = w + "px";
			dw = button.menu.firstChild.offsetWidth - w;
			w -= dw;
			button.menu.firstChild.style.width = w + "px";
		}
	}

	// Position the associated drop down menu under the button and
	// show it. Note that the position must be adjusted according to
	// browser, styling and positioning.

	x = getPageOffsetLeft(button);
	y = getPageOffsetTop(button) + button.offsetHeight;
	//if (browser.isIE) {
	//	x --;
	//	y --;
	//}
	if (browser.isNS && browser.version < 6.1) y--;

	// Position and show the menu.
	button.menu.style.left = x + "px";
	button.menu.style.top  = y + "px";
	button.menu.style.visibility = "visible";

	// Hide select objects that could get in the way of the menu
	_setSelectVisibility("hidden",button.menu);

	// Set button state and let the world know which button is
	// active.
	button.isDepressed = true;
	activeButton = button;
}

function resetButton(button) {
	// Show all select objects
	_setSelectVisibility("visible");

	// Restore the button's style class.
	button.className = "menuButton";

	// Hide the button's menu.
	if (button.menu) button.menu.style.visibility = "hidden";

	// Set button state and clear active menu global.
	button.isDepressed = false;
	activeButton = null;
}

function getPageOffsetLeft(el) {
	// Return the true x coordinate of an element relative to the page.
	return el.offsetLeft + (el.offsetParent ? getPageOffsetLeft(el.offsetParent) : 0);
}

function getPageOffsetTop(el) {
	// Return the true y coordinate of an element relative to the page.
	return el.offsetTop + (el.offsetParent ? getPageOffsetTop(el.offsetParent) : 0);
}

