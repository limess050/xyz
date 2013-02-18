///////////////////////////////////////////////////////////////
// File Name: 	library.js
///////////////////////////////////////////////////////////////

/////////////////////////////////////
// Note that Lighthouse automatically sets the following javascript variables to make
// them available to functions:
// MCFResourcesPath
/////////////////////////////////////

/////////////////////////////////////
// popupWindow: To provide consistency in the way popup select windows appear.
/////////////////////////////////////

function popupWindow(windowName,width,height) {
	eval("var " + windowName + " = window.open('','" + windowName + "','width=" + width + ",height=" + height + ",resizable=1,scrollbars=1')");
	eval(windowName + ".focus()");
	return eval(windowName);
}
function popupWindow2(windowName,options) {
	eval("var " + windowName + " = window.open('','" + windowName + "','" + options + "')");
	eval(windowName + ".focus()");
	return eval(windowName);
}
function popupDialog(windowName,width,height,options,url) {
	//Set url
	if (url == null) url = "";

	//Set options
	if (options == null) options = "status=no,toolbar=no,menubar=no,location=no";
	var top = (screen.availHeight - height) / 2;
	var left = (screen.availWidth - width) / 2;
	options = "height=" + height + ",width=" + width + ",top=" + top + ",left=" + left + "," + options;

	//Create window
	eval("var " + windowName + " = window.open('" + url + "','" + windowName + "','" + options + "')");
	eval(windowName + ".focus()");
	return eval(windowName);
}

/////////////////////////////////////
// String functions
/////////////////////////////////////
function upperCase(fieldObj) {
	fieldObj.value = fieldObj.value.toUpperCase();
}

function lowerCase(fieldObj) {
	fieldObj.value = fieldObj.value.toLowerCase();
}
// titleCase
function titleCase(fieldObj) {
	words = fieldObj.value.split(" ");
	// List of words that remain lower case in titles
	exceptions = ",a,an,the,and,but,or,nor,so,to,as,at,by,for,from,in,into,of,on,onto,to,with,";
	for (var i = 0; i < words.length; i ++) {
		if (i == 0 || exceptions.indexOf("," + words[i].toLowerCase() + ",") == -1) {
			// Get index of first letter
			firstLetterIndex = words[i].search(/\w/);
			words[i] = words[i].substring(0,firstLetterIndex+1).toUpperCase() + words[i].substring(firstLetterIndex+1,words[i].length).toLowerCase()
		} else {
			words[i] = words[i].toLowerCase();
		}
	}
	fieldObj.value = words.join(" ");
}


/////////////////////////////////////
// stripHTML: remove all html tags from a string.
/////////////////////////////////////
function stripHTML(s) {
	s = s.replace(/<[^>]*>/g," ");
	s = s.replace(/&nbsp;/g," ");
	s = trim(s);
	return s;
}

/////////////////////////////////////
// trim: remove leading and trailing white space.
/////////////////////////////////////
function trim(s) {
	s = s.replace(/(^\s+|\s+$)/g,"");
	return s;
}

//Add nbsp to empty cells so that their borders show
function fillEmptyCells() {
    var tds = document.getElementsByTagName("TD");
    for (var i=0; i < tds.length; i++) {
        if (tds[i].innerHTML.search(/[^\s]/) == -1) {
            tds[i].innerHTML = "&nbsp;";
        }
    }
}

/////////////////////////////////////
// setChecked: set multiple checkboxes to checked or unchecked
//   checked = true or false
//   pattern = all checkboxes with ids that match this regular expression will be affected.
//             if omitted all checkboxes will be affected
/////////////////////////////////////
function setChecked(formObj,checked,pattern) {
	if (pattern != null) re = new RegExp("^" + pattern + "$","i");
	var e = formObj.elements;
	for (var i = 0; i < e.length; i ++) {
		if (e[i].type == "checkbox") {
			if (pattern == null || e[i].id.search(re) != -1) {
				e[i].checked = checked;
			}
		}
	}
}
// Check or uncheck all checkboxes under a particular parent node and/or with an id of a particular pattern
// TODO: replace setChecked function?
function checkAll(checked, parentNodeId, pattern) {
	var parentNode = document;
	if (parentNodeId != null) parentNode = document.getElementById(parentNodeId);
	var checkboxes = parentNode.getElementsByTagName("INPUT");
	for (var i = 0; i < checkboxes.length; i ++) {
		if (checkboxes[i].type == "checkbox" && (pattern == null || (checkboxes[i].id && checkboxes[i].id.search(pattern) > -1))) {
			checkboxes[i].checked = checked;
		}
	}
}




/////////////////////////////////////
// showHide: toggle visibility for an object
/////////////////////////////////////
var zIndex = 100;
function showHide(obj,sh,position,el) {
	if (obj) {
		if (sh == null) {
			if (obj.style.visibility == "hidden") {
				sh = "show";
			} else {
				sh = "hide";
			}
		}
		if (position != null) {
			if (position == "rightOfElement") {
				obj.style.left = (_totalOffsetLeft(el) + el.offsetWidth) + "px";
				obj.style.top = _totalOffsetTop(el) + "px";
			} else if (position == "underElement") {
				obj.style.left = _totalOffsetLeft(el) + "px";
				obj.style.top = (_totalOffsetTop(el) + el.offsetHeight) + "px";
			}
		}
		if (sh == "show") {
			_setSelectVisibility("hidden",obj);
			zIndex ++;
			obj.style.zIndex = zIndex;
			obj.style.visibility = "visible";
		} else {
			_setSelectVisibility("visible",obj);
			obj.style.visibility = "hidden";
		}
	}
}

/////////////////////////////////////
// toggleDisplay: toggle display for an object
/////////////////////////////////////
function toggleDisplay(obj,sh,type) {
	if (sh == null) {
		if (obj.style.display != "none") {
			sh = "hide";
		} else {
			sh = "show";
		}
	}
	if (type == null) {
		type = "inline";
	}
	if (sh == "show") {
		obj.style.display = "inline";
	} else {
		obj.style.display = "none";
	}
}



/////////////////////////////////////
// functions to create context menus
/////////////////////////////////////
var dmTimeout = new Array();
var dmTimeoutLength = 500;

// dhtmlMenu object
function dhtmlMenu(id) {
	this.id = id;
}
dhtmlMenu.prototype.exists = function() {
	if (document.getElementById(this.id)) {
		return true;
	} else {
		return false;
	}
}
dhtmlMenu.prototype.create = function(items) {
	// create menu

	if (this.exists()) {
		document.body.removeChild(document.getElementById(this.id));
	}

	var ul = document.createElement("UL");
	ul.id = this.id;
	ul.className = "DHTMLMENU";
	ul.style.visibility = "hidden";
	ul.style.position = "absolute";
	ul.style.left="0px";
	ul.style.top="0px";

	// create items
	for (var i = 0; i < items.length; i ++) {
		var item = items[i];
		var li,a,label,img,input;

		li = document.createElement("LI");
		li.setAttribute("unselectable","on");
		li.setAttribute("menuID",this.id);
		li.onmouseover = dhtmlMenuItemMouseover;
		li.onmouseout = dhtmlMenuItemMouseout;
		ul.appendChild(li);

		switch (item.type) {
			case "link":
				a = document.createElement("A");
				a.setAttribute("unselectable","on");
				li.appendChild(a);

				if (item.image != null && item.image != "") {
					img = document.createElement("IMG");
					img.setAttribute("unselectable","on");
					img.src = item.image;
					a.appendChild(img);
				}

				a.href = item.href
				a.innerHTML = a.innerHTML + item.label;

				//Cancel onBeforeUnload for javascript links (otherwise IE assumes unload)
				if (a.href.indexOf("javascript:")==0){
					xAddEvent(a,"mouseover",top.cancelOnBeforeUnload);
					xAddEvent(a,"mouseout",top.setOnBeforeUnload);
				}				
				
				break;

			case "checkbox":
				input = document.createElement("INPUT");
				input.setAttribute("unselectable","on");
				input.type = "checkbox";
				input.id = item.id;
				input.onclick = item.onclick;
				li.appendChild(input);

				label = document.createElement("LABEL");
				label.setAttribute("unselectable","on");
				label.htmlFor = item.id;
				label.innerHTML = item.label;
				li.appendChild(label);
				break;

		}

	}

	document.body.appendChild(ul);

	//check checkboxes.
	//Seems to be a bug in IE where checkbox can't be set as checked before being appended to the document.
	for (var i = 0; i < items.length; i ++) {
		if (items[i].type == "checkbox" && items[i].checked) {
			document.getElementById(items[i].id).checked = true;
		}
	}
}
dhtmlMenu.prototype.positionUnderElement = function(el) {
	var ul = document.getElementById(this.id);
	ul.style.left = _totalOffsetLeft(el) + "px";
	ul.style.top = _totalOffsetTop(el) + el.offsetHeight + "px";
}
dhtmlMenu.prototype.positionAt = function(left,top) {
	var ul = document.getElementById(this.id);
	ul.style.left = left + "px";
	ul.style.top = top  + "px";
}
dhtmlMenu.prototype.toggleShow = function(location,params) {
	switch (location) {
		case "underElement":
			this.positionUnderElement(arguments[1]);
			break;
		case "at":
			this.positionAt(arguments[1],arguments[2]);
			break;
	}
	if (dmTimeout[this.id] != null) clearTimeout(dmTimeout[this.id])
	//dmTimeout[this.id] = setTimeout("showHide(document.getElementById('" + this.id + "'),'show')",dmTimeoutLength);
	showHide(document.getElementById(this.id));
}
dhtmlMenu.prototype.show = function(location,el) {
	if (location == "underElement") {
		this.positionUnderElement(el)
	}
	if (dmTimeout[this.id] != null) clearTimeout(dmTimeout[this.id])
	//dmTimeout[this.id] = setTimeout("showHide(document.getElementById('" + this.id + "'),'show')",dmTimeoutLength);
	showHide(document.getElementById(this.id),'show');
}
dhtmlMenu.prototype.hide = function() {
	if (dmTimeout[this.id] != null) clearTimeout(dmTimeout[this.id])
	dmTimeout[this.id] = setTimeout("showHide(document.getElementById('" + this.id + "'),'hide')",dmTimeoutLength);
}
dhtmlMenu.prototype.isVisible = function() {
	if (this.exists()) {
		if (document.getElementById(this.id).style.visibility == "visible") {
			return true;
		} else {
			return false;
		}
	} else {
		return false;
	}
}

// dhtmlMenuItem object
function dhtmlMenuItem(type,label) {
	this.type = type;
	this.label = label;
	switch (type) {
		case "link":
			this.href = arguments[2];
			this.image = arguments[3];
			break;
		case "checkbox":
			this.id = arguments[2];
			this.checked = arguments[3];
			this.onclick = arguments[4];
			break;
	}
}

function dhtmlMenuItemMouseover(e) {
	var srcEl = xGetEventSrcElement(e);
	if (srcEl.tagName != "LI") srcEl = getParentByTagName(srcEl,"LI");
	srcEl.className = "DHTMLMENU ITEMHOVER";
	for (var i = 0; i < srcEl.childNodes; i ++) srcEl.childNotes[i].className = "DHTMLMENU ITEMHOVER";
	var ul = getParentByTagName(srcEl,"UL");
	if (dmTimeout[ul.id] != null) clearTimeout(dmTimeout[ul.id])
}
function dhtmlMenuItemMouseout(e) {
	var srcEl = xGetEventSrcElement(e);
	if (srcEl.tagName != "LI") srcEl = getParentByTagName(srcEl,"LI");
	srcEl.className = "";
	for (var i = 0; i < srcEl.childNodes; i ++) srcEl.childNotes[i].className = "";
	var ul = getParentByTagName(srcEl,"UL");
	dmTimeout[ul.id] = setTimeout("showHide(document.getElementById('" + ul.id + "'),'hide')",dmTimeoutLength);
}
/////////////////////////////////////

function setOnBeforeUnload(){
	if (window.onBeforeUnload){
		window.onbeforeunload = window.onBeforeUnload;
	}
}
function cancelOnBeforeUnload(){
	if (window.onBeforeUnload){
		window.onbeforeunload = null;
	}
}


/////////////////////////////////////
//// Some objects are windowed and therefore don't obey the zIndex in IE (at least at the time of this writing)
//// Therefore, they need to be hidden if they are in the way of an object.
/////////////////////////////////////
var _setSelectVisibilityWindowedElements;
function _setSelectVisibility(visibility,obj) {
	// get object position
	if (obj != null) {
		var oTop = _totalOffsetTop(obj);
		var oLeft = _totalOffsetLeft(obj);
		var oBottom = oTop + obj.offsetHeight;
		var oRight = oLeft + obj.offsetWidth;
	}

	if (_setSelectVisibilityWindowedElements == null) {
		// get all windowed objects
		var selectObjs = document.getElementsByTagName("SELECT");
		var specialObjs = document.getElementsByTagName("OBJECT");

		// get array of elements
		_setSelectVisibilityWindowedElements = new Array();
		for (var i = 0; i < selectObjs.length; i ++) _setSelectVisibilityWindowedElements[_setSelectVisibilityWindowedElements.length] = selectObjs[i];
		for (var i = 0; i < specialObjs.length; i ++) _setSelectVisibilityWindowedElements[_setSelectVisibilityWindowedElements.length] = specialObjs[i];
	}

	for (var i = 0; i < _setSelectVisibilityWindowedElements.length; i ++) {
		element = _setSelectVisibilityWindowedElements[i];
		if (visibility == "hidden") {
			// get select object position
			var sTop = _totalOffsetTop(element);
			var sLeft = _totalOffsetLeft(element);
			var sBottom = sTop + element.offsetHeight;
			var sRight = sLeft + element.offsetWidth;

			// If select object overlaps menu, hide it.
			if (((oTop <= sTop && sTop <= oBottom) || (oTop <= sBottom && sBottom <= oBottom) || (sTop <= oTop && sBottom >= oBottom) || (sTop >= oTop && sBottom <= oBottom))
				&& ((oLeft <= sLeft && sLeft <= oRight) || (oLeft <= sRight && sRight <= oRight) || (sLeft <= oLeft && sRight >= oRight) || (sLeft >= oLeft && sRight <= oRight))) {
				element.style.visibility = "hidden";
			}
		} else {
			// Make sure all select objects are visible again.
			element.style.visibility = "visible";
		}
	}
}
function _totalOffsetLeft(el) {
	// Return the true x coordinate of an element relative to the page.
	return el.offsetLeft + (el.offsetParent ? _totalOffsetLeft(el.offsetParent) : 0);
}
function _totalOffsetTop(el) {
	// Return the true y coordinate of an element relative to the page.
	return el.offsetTop + (el.offsetParent ? _totalOffsetTop(el.offsetParent) : 0);
}
/////////////////////////////////////



///////////////////////////////////////////////////////////////
// Functions to swap sibling objects
///////////////////////////////////////////////////////////////
function moveObjUp(o) {
	if (o.previousSibling != null) {
		var vals = getInputsToCheck(o);
		var p = o.parentNode;
		var s = o.previousSibling;
		var c = p.removeChild(o);
		var n = p.insertBefore(c,s);
		setCheckedInputs(n,vals);
	}
}
function moveObjDown(o) {
	if (o.nextSibling != null) {
		var vals = getInputsToCheck(o.nextSibling);
		var p = o.parentNode;
		var s = p.removeChild(o.nextSibling);
		var n = p.insertBefore(s,o);
		setCheckedInputs(n,vals);
	}
}
//IE does not preserve the checked state when moving nodes.  
//Save array of checkboxes where the checked state is different from the default checked state.
function getInputsToCheck(o) {
	var cb = o.getElementsByTagName("INPUT");
	var vals = new Array();
	for (var i=0; i<cb.length; i++){
		if (cb[i].type == "checkbox") {
			if (cb[i].checked != cb[i].defaultChecked) {
				vals.push([i,cb[i].checked]);
			}
		}
	}
	return vals;
}
function setCheckedInputs(o,vals){
	var cb = o.getElementsByTagName("INPUT");
	for (var i=0; i<vals.length; i++){
		cb[vals[i][0]].checked = vals[i][1];
	}
}


///////////////////////////////////////////////////////////////
// Functions for select objects
///////////////////////////////////////////////////////////////

// Move selected options up, if there is room
function moveUp(obj) {
	// For Netscape 6, keep array of selected options to select afterwards
	selectedArray = new Array();
	for (i = 1; i < obj.length; i++) {
		if (obj[i].selected && !obj[i-1].selected) {
			scrollTop = obj[i].scrollTop;
			moveObjUp(obj[i]);
			obj[i].scrollTop = scrollTop - obj[i].offsetHeight;
			selectedArray.push(i-1);
		}
	}
	for (n = 0; n < selectedArray.length; n ++) {
		obj[selectedArray[n]].selected = true;
	}
}
// Move selected options down, if there is room
function moveDown(obj) {
	// For Netscape 6, keep array of selected options to select afterwards
	selectedArray = new Array();
	for (i = obj.length - 2; i > -1; i --) {
		if (obj[i].selected && !obj[i+1].selected) {
			scrollTop = obj[i].scrollTop;
			moveObjDown(obj[i]);
			obj[i].scrollTop = scrollTop + obj[i].offsetHeight;
			selectedArray.push(i+1);
		}
	}
	for (n = 0; n < selectedArray.length; n ++) {
		obj[selectedArray[n]].selected = true;
	}
}
function selectAll (selectObj) {
	for (var i=0; i < selectObj.length; i++) {
		selectObj.options[i].selected = true;
	}
}
function getSelectedValues(selectObj) {
	var selectedValues = new Array();
	for (var i=0; i < selectObj.length; i++) {
		if (selectObj.options[i].selected && selectObj.options[i].value != "") {
			selectedValues[selectedValues.length] = selectObj.options[i].value;
		}
	}
	return selectedValues;
}
function getSelectedText(selectObj) {
	var selectedText = new Array();
	for (var i=0; i < selectObj.length; i++) {
		if (selectObj.options[i].selected && selectObj.options[i].value != "") {
			selectedText[selectedText.length] = selectObj.options[i].text;
		}
	}
	return selectedText;
}
// Populate select box from an array
function populateSelectList(selectObj,values,selectedValues,synchValues) {
	var n = 1;
	if (selectObj.type == "select-multiple") n = 0;
	if (selectedValues == null) selectedValues = [];
	if (synchValues == null) synchValues = [];
	selectObj.options.length = n;

	for (var i = 0; i < values.length; i ++) {
		if (synchValues.length == 0 || arrayContains(synchValues,values[i][2])) {
			selectObj.options[n] = new Option(values[i][1],values[i][0]);
			if (arrayContains(selectedValues,values[i][0])) {
				selectObj.options[n].selected = true;
			}
			n ++ ;
		}
	}

}
function selectValues(selectObj,values,setAsDefault,deselectCurrent) {
	for (var i=0; i < selectObj.length; i++) {
		if (arrayContains(values,selectObj.options[i].value)) {
			selectObj.options[i].selected = true;
			if (setAsDefault !== null && setAsDefault) {
				selectObj.options[i].defaultSelected = true;
			}
		} else if (deselectCurrent){
			selectObj.options[i].selected = false;
		}
	}
}

// Function to sort select box options alphabetically
function sortOptions(selectObj) {
	var optionArray = new Array;
	//put options in array
	for (var i = 0; i < selectObj.options.length; i ++) {
		optionArray[i] = new Array(selectObj.options[i].value,selectObj.options[i].text,selectObj.options[i].selected);
	}
	//sort using custom function
	optionArray.sort(sortOptions_alpha);
	//set values and text of original options
	for (var i = 0; i < selectObj.options.length; i ++) {
		selectObj.options[i].value = optionArray[i][0];
		selectObj.options[i].text = optionArray[i][1];
		selectObj.options[i].selected = optionArray[i][2];
	}
}
//custom sort function
function sortOptions_alpha(opt1, opt2) {
	if (opt1[1] > opt2[1]) {
		return 1;
	} else {
		return -1;
	}
}


///////////////////////////////////////////////////////////////
// Form Validation
// Author: 	David Hammond, based on Netscape library
// Description: General form validation functions
///////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////
// VARIABLE DECLARATIONS
///////////////////////////////////////////////////////////////

// regualar expression definitions
var reWhitespace = /^\s+$/;
var reEmail = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/i;
var reFloat = /^-?((\d+(\.\d*)?)|((\d*\.)?\d+))$/;

// prompts for "missing" information
var mPrefix = "You did not enter a value into the \""
var mSuffix = "\" field. This is a required field. Please enter it now."
var mPrefix2 = "You did not select a value for \""
var mSuffix2 = "\". This information is required. Please select a value now."

// prompts for "invalid" information
var iEmail = "We have detected an invalid e-mail address. Please review the e-mail address you've entered and try again.";


///////////////////////////////////////////////////////////////
// BASIC DATA VALIDATION FUNCTIONS
///////////////////////////////////////////////////////////////

// Check whether string s is empty.
function isEmpty(s) {
	return ((s == null) || (s.length == 0))
}

// Returns true if string s is empty or
// whitespace characters only.
function isWhitespace (s) {
	return (isEmpty(s) || reWhitespace.test(s));
}

// isEmail (STRING s)
function isEmail (s) {
	return reEmail.test(s)
}

// general purpose function to see if a suspected numeric input
// is not empty and is a positive integer
function isNumber(s) {
	return reFloat.test(s)
}


///////////////////////////////////////////////////////////////
// FUNCTIONS TO PROMPT USER
///////////////////////////////////////////////////////////////

// Notify user that required field fieldObj is empty.
// String s describes expected contents of fieldObj.value.
// Put focus in fieldObj and return false.
function warnEmpty (fieldObj, s) {
	if (fieldObj.type != "hidden") {
		fieldObj.focus();
	}
	alert(mPrefix + s + mSuffix);
	return false
}

// Notify user that contents of field fieldObj are invalid.
// String s describes expected contents of fieldObj.value.
// Put select fieldObj, pu focus in it, and return false.
function warnInvalid (fieldObj, s) {
	if (fieldObj.type != "hidden") {
		fieldObj.focus();
		if (fieldObj.select) fieldObj.select()
	}
	alert(s)
	return false
}


///////////////////////////////////////////////////////////////
// FUNCTIONS TO INTERACTIVELY CHECK FIELD CONTENTS
///////////////////////////////////////////////////////////////

// checkText (TEXTFIELD fieldObj, STRING s)
//
// Check that string fieldObj.value is not all whitespace.
function checkText (fieldObj, s) {
	if (isWhitespace(fieldObj.value)) return warnEmpty (fieldObj, s);
	else return true;
}


// checkLength (TEXTAREA fieldObj, INT maxlength, STRING s)
//
// Check length of string fieldObj.value
function checkLength(fieldObj,maxLength,s) {
	if (fieldObj.value.length > maxLength) {
		return warnInvalid (fieldObj, "The value in the \"" + s + "\" field cannot have more than " + maxLength + " characters.\nIt currently has " + fieldObj.value.length + " characters");
	} else {
		return true;
	}
}


// checkChecked (RADIO|CHECKBOX fieldObj, STRING s)
//
// Check that at least one radio or checkbox is checked
function checkChecked (fieldObj, s) {
	if (fieldObj.length) {
		for (i=0; i < fieldObj.length; i++) {
			if (fieldObj[i].checked) return true;
		}
		fieldObj[0].focus();
	} else {
		if (fieldObj.checked) return true;
		fieldObj.focus();
	}
	alert(mPrefix2 + s + mSuffix2);
	return false;
}

// checkSelected (SELECT fieldObj, STRING s)
//
// Check that at least one option has been selected, and it has a value
function checkSelected (fieldObj, s) {
	for (i=0; i < fieldObj.length; i++) {
		if (fieldObj.options[i].selected && fieldObj.options[i].value.length > 0)	return true;
	}
	fieldObj.focus();
	alert(mPrefix2 + s + mSuffix2);
	return false;
}


// checkEmail (TEXTFIELD fieldObj)
//
// Check that string fieldObj.value is a valid Email.
// It is assumed that empty is okay. Run checkText first if this is required
function checkEmail (fieldObj) {
	if (fieldObj.value != "") {
		fieldObj.value = trim(fieldObj.value);
		if (!isEmail(fieldObj.value)) return warnInvalid (fieldObj, iEmail);
	}
	return true;
}


// checkNumber (TEXTFIELD fieldObj)
//
// Check that string fieldObj.value is a valid number.
// It is assumed that empty is okay. Run checkText first if this is required
function checkNumber(fieldObj, s) {
	// Strip legitimate characters that will cause SQL problems
	var value = fieldObj.value;
	value = value.replace(/[$,]/g,"");
	if (value == "") {
		fieldObj.value = value;
		return true;
	}
	if (!isNumber(value)) {
		return warnInvalid (fieldObj, "The value in field " + s + " must be a number.");
	} else {
		fieldObj.value = value;
		return true;
	}
}


// checkDate (TEXTFIELD fieldObj)
//
// This function accepts a string variable and verifies if it is a
// proper date or not. It validates format matching either
// mm-dd-yyyy or mm/dd/yyyy. Then it checks to make sure the month
// has the proper number of days, based on which month it is.
//
// It is assumed that empty is okay. Run checkText first if this is required
function checkDate(fieldObj, s) {
	dateStr = fieldObj.value;
	if (isEmpty(dateStr)) return true;

	var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)((\d{2}|\d{4}))$/;
	var matchArray = dateStr.match(datePat); // is the format ok?
	if (matchArray == null) {
		return warnInvalid (fieldObj,"Value in field " + s + " must be in the form of mm/dd/yyyy.");
	}
	month = matchArray[1]; // parse date into variables
	day = matchArray[3];
	year = matchArray[5];
	if (month < 1 || month > 12) { // check month range
		return warnInvalid (fieldObj,"Month must be between 1 and 12 for field " + s + ".");
	}
	if (day < 1 || day > 31) {
		return warnInvalid (fieldObj,"Day must be between 1 and 31 for field " + s + ".");
	}
	if (year < 1900 || year > 2078) {
		return warnInvalid (fieldObj,"Year must be between 1900 and 2078 for field " + s + ".");
	}
	if ((month==4 || month==6 || month==9 || month==11) && day==31) {
		return warnInvalid (fieldObj,"Month "+month+" doesn't have 31 days for field " + s + ".")
	}
	if (month == 2) { // check for february 29th
		var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
		if (day > 29 || (day==29 && !isleap)) {
			return warnInvalid (fieldObj,"February " + year + " doesn't have " + day + " days for field " + s + ".");
		}
	}
	return true; // date is valid
}

// checkPhone (TEXTFIELD fieldObj)
//
// Check that string fieldObj.value is a valid phone number.
// It is assumed that empty is okay. Run checkText first if this is required
function checkPhone(fieldObj, s) {
	// Strip legitimate characters that will cause SQL problems
	var value = fieldObj.value;
	if (value == "") {
		return true;
	}
	value = value.replace(/\(/g,"");
	value = value.replace(/\)/g,"");
	value = value.replace(/[\s.x-]/g,"");
	if (!isNumber(value)) {
		return warnInvalid (fieldObj, "The value in field " + s + " must be a valid phone number.");
	}
	if (value.length < 10) {
		return warnInvalid (fieldObj, "The value in field " + s + " must be a valid phone number.");
	}
	return true;
}


function checkFile (formObj,colName,s) {
	var uploadFieldObj = formObj.elements[colName];
	if (isWhitespace(uploadFieldObj.value)) {
		if (formObj.elements[colName + "_OldFile"]) {
			var oldfileFieldObj = formObj.elements[colName + "_OldFile"];
			var deleteCheckbox = formObj.elements[colName + "_Delete"];
			if (isWhitespace(oldfileFieldObj.value) || deleteCheckbox.checked) {
				return warnEmpty (uploadFieldObj, s);
			} else {
				return true;
			}
		}
		return warnEmpty (uploadFieldObj, s);
	}
	return true;
}


///////////////////////////////////////////////////////////////
// OTHER UTILITY FUNCTIONS
///////////////////////////////////////////////////////////////


// Escape regular expression special characters in string
function reEscape(s) {
	return s.replace(/[\\\^\$\*\+\?\.\(\)\|\[\]\{\}]/g,"\\$&");
}

// Html Encode
function htmlEncode(s) {
	return s.replace(/\&/g,"\&amp;");
}

// Get value of checked radio button or checkbox if multiple are present
function getCheckedValue (fieldObj) {
	for (var i = 0; i < fieldObj.length; i++) {
		if (fieldObj[i].checked) { break }
	}
	return fieldObj[i].value
}

// Get value of selected option
function getSelectedValue (fieldObj) {
	for (var i = 0; i < fieldObj.length; i++) {
		if (fieldObj[i].selected) {
			return fieldObj[i].value
		}
	}
	return "";
}

function yesNoFormat(/*boolean*/ b){
	return b==1?"Yes":(b==0?"No":(b?"Yes":"No"));
}

// Simple non-re replace function
function replace(s,subexpr,replacestring) {
	var i = s.indexOf(subexpr);
	if (i > -1) {
		s = s.substring(0,i) + replacestring + s.substring(i + subexpr.length, s.length)
	}
	return s;
}
function replaceAll(s,subexpr,replacestring) {
	if (replacestring.indexOf(subexpr) > -1) {
		alert("replacestring contains subexpression.  aborting to avoid infinite loop.\nreplacestring: " + replacestring + "\nsubexpression: " + subexpr);
		return s;
	}
	var i = s.indexOf(subexpr);
	while (i > -1) {
		s = s.substring(0,i) + replacestring + s.substring(i + subexpr.length, s.length)
		i = s.indexOf(subexpr);
	}
	return s;
}

///////////////////////////////////////////////////////////////
// List Functions
///////////////////////////////////////////////////////////////
function listAppend(list,value,delimiter) {
	if (delimiter == null) delimiter = ",";
	if (list != null && list != "") list += delimiter + value;
	else list = value;
	return list;
}
function listRemove(list,value,delimiter) {
	if (delimiter == null) delimiter = ",";
	list = list.replace(new RegExp(reEscape(value),"gi"),"");
	list = list.replace(new RegExp(delimiter + delimiter,"g"),delimiter);
	list = list.replace(new RegExp("^" + delimiter + "|" + delimiter + "$","g"),"");
	return list;
}
function listShiftRight(list,value) {
	list = list.replace(new RegExp("(" + reEscape(value) + "),([^$,]+)","gi"),"$2,$1");
	return list;
}
function listShiftLeft(list,value) {
	list = list.replace(new RegExp("([^^,]+),(" + reEscape(value) + ")","gi"),"$2,$1");
	return list;
}
function listFind(list,value,delimiter) {
	if (delimiter == null) delimiter = ",";
	return list.match(new RegExp("[^" + delimiter + "]*(^|" + delimiter + ")" + reEscape(value) + "($|" + delimiter + ")[^" + delimiter + "]*"));
}


///////////////////////////////////////////////////////////////
// Array Functions
///////////////////////////////////////////////////////////////
function arrayContains(arr,val,ignoreCase) {
	if (ignoreCase){
		val = val.toLowerCase();
		for (var i=0;i<arr.length;i++){if (arr[i].toLowerCase()==val){return true;break;}}
	} else {
		for (var i=0;i<arr.length;i++){if (arr[i]==val) {return true;break;}}
	}
	return false;
}
function arrayRemoveDuplicates(arr,ignoreCase) {
	var newArr = [];
	for (var i=0;i<arr.length;i++) {
		if (!arrayContains(newArr,arr[i],ignoreCase)){
			newArr.push(arr[i]);
		}
	}
	return newArr;
}
// same as String.split function, except returns empty array if string has no length
function split(s,del) {
	var arr;
	if (s.length > 0) {
		arr = s.split(del);
	} else {
		arr = new Array();
	}
	return arr;
}


function getScrollWidth(win) {
	if (win == null) win = window;
	var w = win.pageXOffset || win.document.body.scrollLeft || win.document.documentElement.scrollLeft;
	return w ? w : 0;
}
function getScrollHeight(win) {
	if (win == null) win = window;
	var h = win.pageYOffset || win.document.body.scrollTop || win.document.documentElement.scrollTop;
	return h ? h : 0;
}

// Get parent element by tagname
function getParentByTagName(el,tagName) {
	return (el.parentNode.tagName == tagName ? el.parentNode : getParentByTagName(el.parentNode,tagName));
}

// Shortcut for very common function
function getEl(id) {
	return document.getElementById(id);
}


///////////////////////////////////////////////////////////////
// FUNCTIONS FOR CROSS-BROWSER DOM SUPPORT
///////////////////////////////////////////////////////////////

// Is a gecko-based browser
function isGecko() {
	return (window.navigator.product == "Gecko");
}

// Events
function xGetEventSrcElement(e) {
	if (window.event) {
		return window.event.srcElement;
	} else if (e && e.currentTarget) {
		return e.currentTarget;
	}
}
function xGetEvent(win,e) {
	if (win.event) {
		return win.event;
	} else {
		return e;
	}
}
function xGetEventSrcElementForWindow(win,e) {
	if (win.event) {
		return win.event.srcElement;
	} else  {
		return e.target;
	}
}
function xAddEvent(obj, name, handler) {
	if (obj.attachEvent) {
		obj.attachEvent("on" + name, handler);
	} else {
		obj.addEventListener(name, handler, false);
	}
}
// Selection and Range
function xGetSelection(win) {
	if (win.document.selection) {
		return win.document.selection;
	} else {
		return win.getSelection();
	}
}
function xGetSelectionRange(win) {
	if (win.document.selection) {
		return win.document.selection.createRange();
	} else {
		return win.getSelection().getRangeAt(0);
	}
}
function xGetRangeText(rng) {
	if (rng.text) {
		return rng.text;
	} else if (rng.toString) {
		return rng.toString();
	} else {
		return "";
	}
}
function xRangeParentElement(rng) {
	if (rng.parentElement) {
		return rng.parentElement();
	} else {
		var parentNode = rng.commonAncestorContainer;
		while (parentNode.nodeType != 1) parentNode = parentNode.parentNode;
		return parentNode;
	}
}
function xMoveToElementText(rng,element) {
    if (rng.moveToElementText) {
		rng.moveToElementText(element);
	} else if (rng.selectNode) {
		rng.selectNode(element);
	} else if (rng.selectNodeContents) {
		rng.selectNodeContents(element);
	}
}
function xSelectRange(win,rng) {
	if (rng.select) {
		rng.select();
	} else {
		var sel = xGetSelection(win);
		sel.removeAllRanges();
		sel.addRange(rng);
	}
}
function xSelectElement(win,el) {
	var rng = xGetSelectionRange(win);
	xMoveToElementText(rng,el);
	xSelectRange(win,rng);
}
function xCloneRange(rng) {
	if (rng.duplicate) {
		return rng.duplicate();
	} else {
		return rng.cloneRange();
	}
}
function xElementIsInRange(element,rng) {
	if (rng.duplicate) {
		var elementRange = rng.duplicate();
		elementRange.moveToElementText(element);
		elementRange.moveStart("character");
		elementRange.moveEnd("character",-1);
		return rng.inRange(elementRange);
	} else {
		var elementRange = document.createRange();
		elementRange.selectNode(element);
		return (rng.compareBoundaryPoints(rng.START_TO_START,elementRange) < 1 
			&& rng.compareBoundaryPoints(rng.END_TO_END,elementRange) > -1) 
			|| (element.tagName!="IMG" && xRangesAreIdentical(rng,elementRange));
	}
}
function xInsertTextInRange(doc,rng,text) {
	if (rng.insertNode) {
		var newNode = doc.createTextNode(text);
		rng.insertNode(newNode);
		rng.selectNode(newNode);
	} else {
		rng.pasteHTML(text);
		rng.findText(text,-text.length);
	}
}

function xRangesAreIdentical(range1,range2) {
	//TODO:This does not work with a non-text selection (like an image)
	if (xGetRangeText(range1) == xGetRangeText(range2)) {
		return true;
	} else {
		return false;
	}
}

function xReplaceElement(oldEl,newTagName) {
	var newEl;
	if (isGecko()) {
		newEl = oldEl.ownerDocument.createElement(newTagName);
		newEl.innerHTML = oldEl.innerHTML;
		oldEl.parentNode.replaceChild(newEl,oldEl);
	}
	return newEl;
}

function xCloneElement(oldEl) {
	var newEl;
	newEl = oldEl.ownerDocument.createElement(oldEl.tagName);
	newEl.innerHTML = oldEl.innerHTML;
	return newEl;
}

// Stylesheets
function xGetStyleSheetRules(ss) {
	if (ss.rules) {
		return ss.rules;
	} else {
		return ss.cssRules;
	}
}

function xGetXml(url) {
	if (document.implementation && document.implementation.createDocument) {
		xmlDoc = document.implementation.createDocument("", "", null);
	} else if (window.ActiveXObject) {
		xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
	}
	if (xmlDoc != null) xmlDoc.load(url);
	return xmlDoc;
}
//More help on getting,posting xml: http://webfx.eae.net/dhtml/xmlextras/xmlextras.html


/////////////////////////////////////
// Dojo: Functions temporarily borrowed from dojo.  
/////////////////////////////////////
isSelectionCollapsed = function(win){
	if (win == null) win = window;
	if(win.document["selection"]){ // IE
		return win.document.selection.createRange().text == "";
	}else if(win["getSelection"]){
		var selection = win.getSelection();
		return selection.isCollapsed;
	}
}

// Convert string to boolean by CF rules
function cfBoolean(s) {
	s = String(s).toLowerCase();
	return (s=="yes"||s=="true");
}

//Remove a parameter from a query string
function removeQueryParam(s,p) {
	p = reEscape(p);
	s = s.replace(new RegExp("&" + p + "=[^&]*|" + p + "=[^&]*&|" + p + "=[^&]*","gi"),"");
	return s;
}
