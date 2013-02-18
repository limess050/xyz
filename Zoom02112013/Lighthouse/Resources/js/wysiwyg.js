///////////////////////////////////////////////////////////////
// File Name: 	wysiwig.js
// This file is dependent upon library.js
///////////////////////////////////////////////////////////////

/////////////////////////////////////
// Note that Lighthouse automatically sets the following javascript variables to make
// them available to functions:
// AppVirtualPath
// MCFResourcesPath
/////////////////////////////////////

///////////////////////////////////////////////////////////////
// Functions for HTML edit
// Author: 	David Hammond
///////////////////////////////////////////////////////////////

// set variables
var htmlToolbars = new Array();
var htmlFields = new Object();
var htmlFieldClasses = new Array();
var currentDiv = null;
var currentToolbar = null;
var currentField = null;
var popupWindow = null;
var fieldWindow = window;
var dialogParams = null;
var styleEditMode = "element";

///////////////////////////////////////////////////////////////
// Toolbar object
///////////////////////////////////////////////////////////////

// constructor
function htmlToolbar(windowObj,toolbarID) {
	this.id = toolbarID;
	this.htmlField = null;
	this.window = windowObj;
}
htmlToolbar.prototype.doEdit = function(command,value) {
	if (this.htmlField != null) {
		// Hide context menu
		this.htmlField.hideContextMenu();
		xSetFieldActive(this.htmlField);
		switch (command) {
			case "RemoveFormatting" :
				removeFormatting(this.htmlField);
				break;
			default :
				try {
					//when using gecko, replace some semantic tags that are used by IE
					if (isGecko()) {
						switch (command) {
							case "Bold" :
								if (getCurrent(this.htmlField,"STRONG") != null) {
									var newEl = xReplaceElement(getCurrent(this.htmlField,"STRONG"),"B");
									xSelectElement(this.htmlField.contentWindow,newEl);
								}
								break;
							case "Italic" :
								if (getCurrent(this.htmlField,"EM") != null) {
									var newEl = xReplaceElement(getCurrent(this.htmlField,"EM"),"I");
									xSelectElement(this.htmlField.contentWindow,newEl);
								}
								break;
						}
					}
					this.htmlField.contentWindow.document.execCommand(command,false,value);
				} catch(ex) {
					var msg = "";
					if (ex.message == "Access to XPConnect service denied") {
						msg += "<p>The " + command + " command will not work without setting preferences for your browser.</p>";
						if (command == "cut") msg += "<p>Press Ctrl-x on your keyboard instead.</p>";
						else if (command == "copy") msg += "<p>Press Ctrl-c on your keyboard instead.</p>";
						else if (command == "paste") msg += "<p>Press Ctrl-v on your keyboard instead.</p>";
						msg += "<p>See the following url for more information:</p>";
						msg += "<p><a href=\"http://www.mozilla.org/editor/midasdemo/securityprefs.html\" target=\"_blank\">http://www.mozilla.org/editor/midasdemo/securityprefs.html</a></p>";
					} else {
						msg = "Error message:<br>" + ex.message;
					}
					this.alert("Command Not Supported",msg);
				}
		}
	} else {
		alert("No html edit field has been selected.");
	}
}
checkAll = false;
htmlToolbar.prototype.dialog = function(dialogName,siteEditor,fileDir,dialogWin) {
	if (this.htmlField != null) {
		// Set default for undefined parameters
		if (siteEditor == null) siteEditor = false;
		if (fileDir == null) fileDir = "";

		// Set default dialog options
		var dialogWidth = 500;
		var dialogHeight = 400;
		var options = "scrollbars=no,resizable=yes,status=no,toolbar=no,menubar=no,location=no";
		var dialogScript = "/dialogs/element.html";

		// Hide context menu
		currentField = this.htmlField;
		this.htmlField.hideContextMenu();
		this.htmlField.controlToText();
		xSetFieldActive(this.htmlField);

		dialogParams = new Array();
		dialogParams["htmlToolbar"] = this;
		dialogParams["htmlField"] = this.htmlField;
		dialogParams["dialogName"] = dialogName;
		dialogParams["elementName"] = dialogName.toUpperCase();
		dialogParams["siteEditor"] = siteEditor;
		dialogParams["fileDir"] = fileDir;

		switch (dialogName) {
			case "link" : dialogParams["elementName"] = "A"; break;
			case "anchor" : dialogParams["elementName"] = "A"; break;
			case "tableCreate" : dialogScript = "/dialogs/tableCreate.html"; break;
			case "img" :
				element = getCurrent(this.htmlField,"IMG");
				if (element == null) {
					dialogScript = "/dialogs/filebrowser.cfm?uploadDir=" + escape(fileDir);
					dialogWidth = "700";
					dialogHeight = "450";
					dialogName = "imgInsert";
					options = "resizable=1,scrollbars=1";
				}
				break;
			case "editHtml" :
				dialogScript = "/dialogs/code.html";
				dialogWidth = "760";
				dialogHeight = "560";
				options = "resizable=1";
				break;
			case "spellCheck" :
				dialogScript = "/spellchecker/window.cfm?jsvar=currentField.editArea.innerHTML&fieldName=" + this.htmlField.fieldName;
				dialogWidth = "450";
				dialogHeight = "242";
				options = "status=no,toolbar=no,menubar=no,location=no";
				break;
		}
		if (dialogWin==null){
			popupDialog(dialogName + "PropertiesWin",dialogWidth,dialogHeight,options,MCFResourcesPath + dialogScript);
		} else {
			dialogWin.location = MCFResourcesPath + dialogScript;
			dialogWin.focus();
		}

	} else {
		alert("No html edit field has been selected.");
	}
}
htmlToolbar.prototype.alert = function(title,message) {
	var dialogWidth = 400;
	var dialogHeight = 380;
	var options = "scrollbars=no,resizable=yes,status=no,toolbar=no,menubar=no,location=no";
	dialogParams = new Array();
	dialogParams["title"] = title;
	dialogParams["message"] = message;
	var dialogWin = popupDialog("alert",dialogWidth,dialogHeight,options,MCFResourcesPath + "/dialogs/alert.html");
}
htmlToolbar.prototype.showStylesMenu = function() {
	if (this.htmlField != null) {
		var dm = new this.htmlField.window.dhtmlMenu("mcfWysiwygStylesMenu");

		if (!dm.isVisible()) {
			xSetFieldActive(this.htmlField);
			currentField = this.htmlField;
			this.htmlField.window.currentField = this.htmlField;

			var items = new Array();
			var label, href, token, re;

			var currentElement = getCurrent(this.htmlField);
			var currentRange = xGetSelectionRange(this.htmlField.contentWindow);
			var els = new Array();
			var rules = getStylesheetRules(this.htmlField);
			var tagName, i, checked, elementRangeSelected, getMoreElements;

			getMoreElements = true;
			getParentElements = false;
			// edit mode is "element", "spans", or "siblings"
			styleEditMode = "element";

			// determine if we want to create a span
			if (xGetSelection(this.htmlField.contentWindow).type == "Control" || xGetRangeText(currentRange) == "") {
				if (currentElement.tagName == "IMG") {
					els[els.length] = currentElement;
					getMoreElements = false;
				} else {
					getParentElements = true;
				}
			} else {
				var elementRange = xCloneRange(currentRange);
				xMoveToElementText(elementRange,currentElement);

				// if ranges are the same, do not create new span.
				if (xRangesAreIdentical(currentRange,elementRange)) {
					if (currentElement.tagName != "SPAN") {
						styleEditMode = "spans";
						elementRangeSelected = currentElement.tagName;
						els[els.length] = this.htmlField.contentWindow.document.createElement("SPAN");
					}
					getParentElements = true;
				} else {
					styleEditMode = "spans";
					els[els.length] = this.htmlField.contentWindow.document.createElement("SPAN");
					if (xElementIsInRange(currentElement,currentRange)) {
						els[els.length] = currentElement;
					}
				}
			}
			//alert("Element: " + currentElement.tagName + " Range: " + elementRangeSelected);

			// get array of elements
			if (getMoreElements) {
				var element = currentElement;
				while ((getParentElements || xElementIsInRange(element,currentRange)) && element && element.id != null && element.id.indexOf("_editArea") == -1 && stripHTML(element.innerHTML) == stripHTML(currentElement.innerHTML)) {
					els[els.length] = element;
					element = element.parentNode;
				}
			}

			// display styles appropriate to tree of elements
			for (var r = 0; r < rules.length; r ++) {
				tagName = null;
				if (arrayContains(rules[r][2],"")) {
					tagName = "";
				} else {
					for (var e = 0; e < els.length; e ++) {
						if (arrayContains(rules[r][2],els[e].tagName)) {
							tagName = els[e].tagName;
							// If element other than span fully-selected, keep looking for element in list.
							// This is to avoid creating unnecessary span tags.
							if (elementRangeSelected == null || elementRangeSelected == tagName) {
								break;
							}
						}
					}
				}

				if (tagName != null) {
					for (var e = 0; e < els.length; e ++) {
						if (listFind(els[e].className,rules[r][0]," ")) {
							checked = true;
							break;
						} else {
							checked = false;
						}
					}
					items[items.length] = new dhtmlMenuItem("checkbox",rules[r][3],rules[r][0] + "|" + tagName,checked,setStyles);
				}
			}

			if (items.length == 0) {
				items[items.length] = new dhtmlMenuItem("link","No Styles Available for Selection","","");
			}

			dm.create(items);
			if (this.window != this.htmlField.window) {
				dm.toggleShow("at",0,getScrollHeight(this.htmlField.window));
			} else {
				dm.toggleShow("underElement",document.getElementById(this.htmlField.fieldName + "_showStylesMenuButton"));
			}
		} else {
			dm.toggleShow();
		}
	} else {
		alert("No html edit field has been selected.");
	}
}
htmlToolbar.prototype.hideStylesMenu = function() {
	var dm = new this.window.dhtmlMenu("mcfWysiwygStylesMenu");
	if (dm.isVisible()) dm.toggleShow();
	if (this.htmlField != null) {
		this.htmlField.saveContents();
	}
}
htmlToolbar.prototype.setCurrentStyle = function() {
	if (this.htmlField != null) {
		// Hide context menu
		this.htmlField.hideContextMenu();
	}
}


///////////////////////////////////////////////////////////////
// Field object
///////////////////////////////////////////////////////////////

function htmlField(type,windowObj,fieldName,htmlToolbar) {
	this.type = type;
	this.fieldName = fieldName;
	this.field = windowObj.document.getElementById(fieldName);
	this.window = windowObj;
	fieldWindow = this.window;
	if (type == "frame") {
		this.frame = windowObj.document.getElementById(fieldName + "_editArea");
		this.contentWindow = this.frame.contentWindow;
		this.editArea = this.contentWindow.document.body;
		this.editArea.id = fieldName;
	} else {
		this.contentWindow = fieldWindow;
		this.editArea = windowObj.document.getElementById(fieldName + "_editArea");
	}
	this.workArea = windowObj.document.getElementById(fieldName + "_workArea");
	if (htmlToolbar != null) {
		this.htmlToolbar = htmlToolbar;
		if (htmlToolbar.htmlField == null) htmlToolbar.htmlField = this;
	}
	this.field.value = cleanUp(this.workArea.innerHTML,this.window);
	this.editArea.innerHTML = this.workArea.innerHTML;
	tableSetGuidelines(this.editArea);
	this.setObjectEvents();
	//load stylesheet xml
	getStyleXml();
}

htmlField.prototype.getContents = function() {
	this.saveContents();
	return this.field.value;
}

htmlField.prototype.getRawContents = function(){
	return this.editArea.innerHTML;
}

htmlField.prototype.setContents = function(html) {
	this.editArea.innerHTML = html;
	this.saveContents();
}

htmlField.prototype.saveContents = function() {
	this.workArea.innerHTML = this.editArea.innerHTML;
	tableRemoveGuidelines(this.workArea);
	html = this.workArea.innerHTML;
	html = cleanUp(html,this.window);
	html = replaceSpecialChars(html);
	this.field.value = html;
}
htmlField.prototype.setObjectEvents = function() {
	var images = this.editArea.getElementsByTagName("IMG");
	for (var i = 0; i < images.length; i ++) {
		images[i].onresizeend = imageSetSize;
	}
}
htmlField.prototype.showContextMenu = function(e) {
	var dm = new this.window.dhtmlMenu("mcfWysiwygContextMenu");
	if (!dm.isVisible()) {
		var items = new Array();
		var label, href, dialogName, image, clientX, clientY;
		this.controlToText();

		var element = xGetEventSrcElementForWindow(this.contentWindow,e);
		while (element != this.editArea) {
			if (getFriendlyTagName(element.tagName) != element.tagName) {
				label = getFriendlyTagName(element.tagName) + " Properties";
				dialogName = element.tagName.toLowerCase();
				image = "";
				switch (element.tagName) {
					case "TABLE" : image = "tableProperties.gif"; break;
					case "TR" : image = "rowProperties.gif"; break;
					case "TD" : image = "cellProperties.gif"; break;
					case "IMG" : image = "insertImage.gif"; break;
					case "STRONG" : image = "bold.gif"; break;
					case "EM" : image = "italic.gif"; break;
					case "U" : image = "underline.gif"; break;
					case "UL" : image = "insertUnorderedList.gif"; break;
					case "P" : image = "justifyleft.gif"; break;
					case "SUP" : image = "superscript.gif"; break;
					case "SUB" : image = "subscript.gif"; break;
					case "A" :
						if (element.name != "") {
							dialogName = "anchor";
							image = "createBookmark.gif";
						} else {
							dialogName = "link";
							image = "createLink.gif";
						}
						break;
				}
				href = "javascript:fieldWindow.htmlFields[\"" + this.fieldName + "\"].htmlToolbar.dialog(\"" + dialogName + "\")";
				if (image != "") image = MCFResourcesPath + "/images/toolbar/" + image;
				items[items.length] = new dhtmlMenuItem("link",label,href,image);
			}
			element = element.parentNode;
		}
		if (items.length > 0) {
			dm.create(items);
			clientX = xGetEvent(this.window,e).clientX;
			clientY = xGetEvent(this.window,e).clientY;
			if (this.type == "frame") {
				clientX = clientX + _totalOffsetLeft(this.frame);
				clientY = clientY + _totalOffsetTop(this.frame);
			} else {
				clientX = clientX + getScrollWidth(this.window);
				clientY = clientY + getScrollHeight(this.window);
			}
			dm.toggleShow("at",clientX,clientY);
		}
	} else {
		dm.toggleShow();
	}
	return false;
}
htmlField.prototype.hideContextMenu = function() {
	var dm = new this.window.dhtmlMenu("mcfWysiwygContextMenu");
	if (dm.isVisible()) dm.toggleShow();
}
htmlField.prototype.setActive = function() {
	var range = xGetSelectionRange(this.contentWindow);
	xMoveToElementText(range,this.editArea);
	range.collapse();
	xSelectRange(this.contentWindow,range);
}
htmlField.prototype.controlToText = function() {
	// If selection is control, change to text
	if (xGetSelection(this.contentWindow).type == "Control"){
		var oControlRange = xGetSelectionRange(this.contentWindow);
		var e = oControlRange(0);
		xGetSelection(this.contentWindow).empty();
		var s = xGetSelectionRange(this.contentWindow);
		xMoveToElementText(s,e);
		xSelectRange(this.contentWindow,s);
	}
}
htmlField.prototype.getTrimmedSelection = function() {
	var rng = xGetSelectionRange(this.contentWindow);
	// Need Firefox equivalent here
	if (rng.text) {
		while (rng.text.substr(0,1) == " ") {
			rng.moveStart("character",1);
		}
		while (rng.text.substr(rng.text.length-1,1) == " ") {
			rng.moveEnd("character",-1);
		}
		xSelectRange(this.contentWindow,rng);
	}
	return rng;
}


///////////////////////////////////////////////////////////////
// Custom Editing Command Functions
///////////////////////////////////////////////////////////////

function imageSetSize(e) {
	imageObj = xGetEventSrcElement(e);
	// If width and height set in style, transfer to width and height parameters.
	if (imageObj) {

		if (imageObj.style.width != "") {
			imageObj.setAttribute("width",imageObj.offsetWidth);
			imageObj.setAttribute("height",imageObj.offsetHeight);
			imageObj.style.width = "";
			imageObj.style.height = "";
		} else {
			imageObj.setAttribute("width",imageObj.width);
			imageObj.setAttribute("height",imageObj.height);
		}
	}
}

// Get the current selection by tagName
function getCurrent(htmlField,tagName) {
	var element = null;

	if (tagName == "" || tagName == null) {
		if (xGetSelection(htmlField.contentWindow).type == "Control"){
			var oControlRange = xGetSelectionRange(htmlField.contentWindow);
			for (var i = 0; i < oControlRange.length; i++) {
				if (oControlRange(i).nodeType == 1) {
					element = oControlRange(i);
				}
			}
		} else {
			var selectedTextRange = xGetSelectionRange(htmlField.contentWindow);
			element = xRangeParentElement(selectedTextRange);

			//Do not select the container of the editable area.
			if (element.id && element.id.indexOf("_editArea") > -1) {
				// save selected text
				var selectedText = selectedTextRange.text;

				// collapse selection and try getting parent element again.
				var newTextRange = xCloneRange(selectedTextRange);
				newTextRange.collapse();
				element = xRangeParentElement(newTextRange);

				// if still no element, paste p tags around content of edit area
				if (element.id.indexOf("_editArea") > -1) {
					if (htmlField.editArea.innerHTML == "") editArea.innerHTML = "&nbsp;";
					if (htmlField.editArea.childNodes[0].nodeType == 1) {
						element = htmlField.editArea.firstChild;
					} else {
						element = htmlField.editArea.ownerDocument.createElement("P");
						element.innerHTML = htmlField.editArea.innerHTML;
						htmlField.editArea.innerHTML = "";
						htmlField.editArea.appendChild(element);
						xMoveToElementText(newTextRange,element);
						newTextRange.collapse();
						xSelectRange(htmlField.contentWindow,newTextRange);
					}
				}

				// Reselect text
				if (selectedText != "") {
					newTextRange.findText(selectedText);
					xSelectRange(htmlField.contentWindow,newTextRange);
				}
			}

			//If parent node is contained in selection, then set parent as element.
			//This is a workaround for an apparent IE bug with the range.parentElement() method.
			//Is Firefox equivalent needed?
			if (selectedTextRange.duplicate) {
				var newElement = element;
				var elementRange = selectedTextRange.duplicate();
				xMoveToElementText(elementRange,newElement);
				var newElementRange = elementRange.duplicate();
				newElementRange.moveStart("character");
				while (selectedTextRange.inRange(newElementRange) && newElement.parentNode && newElement.parentNode.id != null && newElement.parentNode.id.indexOf("_editArea") == -1) {
					xMoveToElementText(newElementRange,newElement.parentNode);
					newElementRange.moveStart("character");
					if (selectedTextRange.inRange(newElementRange)) {
						newElement = newElement.parentNode;
					}
				}
				xMoveToElementText(newElementRange,newElement);
				if (newElementRange.text != elementRange.text) {
					element = newElement;
				}
			}
		}

	} else {
		// If Control select, try to find the tag within.
		if (xGetSelection(htmlField.contentWindow).type == "Control"){
			var oControlRange = xGetSelectionRange(htmlField.contentWindow);
			for (var i = 0; i < oControlRange.length; i++) {
				if (oControlRange(i).tagName == tagName) {
					return oControlRange(i);
				}
			}
			element = oControlRange(0);
		} else {
			if (tagName == "IMG") {
				//Look for an image contained by selection
				//If IE, or Firefox and selection is not collapsed, look for IMG in selection
				if (htmlField.contentWindow.document["selection"] || !htmlField.contentWindow.getSelection().isCollapsed) {
					element = getElementInSelection(htmlField,"IMG");
				}
			} else {
				var rng = xGetSelectionRange(htmlField.contentWindow);
				element = xRangeParentElement(rng);
			}
		}

		// Else, look for tag containing the selection
		while (element != null && element.tagName != tagName && element != htmlField.editArea) {
			element = element.parentNode;
		}
		if (element == htmlField.editArea) element = null;
	}
	return element;
}

// Select whole current tag
function selectCurrent(htmlField,tagName) {
	var element = getCurrent(htmlField,tagName);
	var currentRange = xGetSelectionRange(htmlField.contentWindow);
	if (element != null) {
		xMoveToElementText(currentRange,element);
		xSelectRange(htmlField.contentWindow,currentRange);
	} else if (xGetSelection(htmlField.contentWindow).type != "Control") {
		// Need Firefox equivalent here
		if (currentRange.htmlText) {
			// Try to move to tag within selection
			if (currentRange.htmlText.indexOf("<" + tagName + " ") > -1) {
				currentRange.collapse();
				xSelectRange(htmlField.contentWindow,currentRange);
				element = getCurrent(htmlField,tagName);
				while (element != null && element.tagName != tagName) {
					currentRange.move("character",1);
					xSelectRange(htmlField.contentWindow,currentRange);
					element = getCurrent(htmlField,tagName);
				}
				if (element != null) {
					xMoveToElementText(currentRange,element);
					xSelectRange(htmlField.contentWindow,currentRange);
				}
			// Try moving back a character
			} else if (currentRange.htmlText.length == 0) {
				currentRange.move("character",-1);
				xSelectRange(htmlField.contentWindow,currentRange);
				element = getCurrent(htmlField,tagName);
				if (element != null) {
					xMoveToElementText(currentRange,element);
					xSelectRange(htmlField.contentWindow,currentRange);
				} else {
					currentRange.move("character",1);
					xSelectRange(htmlField.contentWindow,currentRange);
				}
			}
		}
	}
	return element;
}

// Get the first element within the selection
function getElementInSelection(htmlField,tagName) {
	var els = htmlField.contentWindow.document.getElementsByTagName(tagName);
	var currentRange = xGetSelectionRange(htmlField.contentWindow);
	for (var i = 0; i < els.length; i ++) {
		if (xElementIsInRange(els[i],currentRange)) {
			return els[i];
		}
	}
	return null;
}

///////////////////////////////////////////////////////////////
// Table Functions
///////////////////////////////////////////////////////////////

// Inserting and deleting rows and columns.
function tableInsertRow(htmlToolbar,offset) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var newTR = tbody.insertRow(tr.rowIndex + offset);
		tableCleanCells(htmlToolbar.htmlField)
	}
}
function tableDeleteRow(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		tbody.deleteRow(tr.rowIndex);
		tableCleanCells(htmlToolbar.htmlField)
	}
}
function tableInsertColumn(htmlToolbar,offset) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var rows = tbody.rows;
		// get grid position for cell
		if (offset == 0) {
			var gridIndex = 1;
			for (var c = 0; c < td.cellIndex; c ++) gridIndex = gridIndex + tr.cells[c].colSpan;
		} else {
			var gridIndex = 0;
			for (var c = 0; c <= td.cellIndex; c ++) gridIndex = gridIndex + tr.cells[c].colSpan;
		}
		// loop through rows and add cell or increase span at grid position
		for (var r = 0; r < rows.length; r ++) {
			var i = 0;
			for (var c = 0; c < rows[r].cells.length; c ++) {
				if (i + 1 == gridIndex && offset == 0) {
					rows[r].insertCell(rows[r].cells[c].cellIndex);
					break;
				}
				i = i + rows[r].cells[c].colSpan;
				if (i > gridIndex) {
					rows[r].cells[c].setAttribute("colSpan",rows[r].cells[c].getAttribute("colSpan") + 1);
					break;
				} else if (i == gridIndex) {
					rows[r].insertCell(rows[r].cells[c].cellIndex + offset);
					break;
				}
			}
		}
		tableCleanCells(htmlToolbar.htmlField)
	}
}
function tableDeleteColumn(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var cellIndex = td.cellIndex;
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var rows = tbody.rows;
		// get grid position for cell
		var gridIndex = 1;
		for (var c = 0; c < td.cellIndex; c ++) gridIndex = gridIndex + tr.cells[c].colSpan;
		// loop through rows and delete cell or decrease span at grid position
		for (var r = 0; r < rows.length; r ++) {
			var i = 0;
			for (var c = 0; c < rows[r].cells.length; c ++) {
				i = i + rows[r].cells[c].colSpan;
				if (i > gridIndex || (i == gridIndex && rows[r].cells[c].colSpan > 1)) {
					rows[r].cells[c].setAttribute("colSpan",rows[r].cells[c].getAttribute("colSpan") - 1);
					break;
				} else if (i == gridIndex) {
					rows[r].deleteCell(rows[r].cells[c].cellIndex);
					break;
				}
			}
		}
		tableCleanCells(htmlToolbar.htmlField)
	}
}

// Increasing and decreasing cell spans
function tableIncreaseColSpan(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		if (tr.cells.length > td.cellIndex + 1) {
			if (trim(tr.cells[td.cellIndex + 1].innerHTML) != "<br>") {
				td.innerHTML = td.innerHTML + " " + tr.cells[td.cellIndex + 1].innerHTML;
			}
			tr.deleteCell(td.cellIndex + 1);
			td.setAttribute("colSpan",td.colSpan + 1);
		}
		tableCleanCells(htmlToolbar.htmlField);
	}
}
function tableDecreaseColSpan(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		if (td.getAttribute("colSpan") > 1) {
			tr.insertCell(td.cellIndex + 1);
			td.setAttribute("colSpan",td.colSpan - 1);
		}
		tableCleanCells(htmlToolbar.htmlField);
	}
}
function tableIncreaseRowSpan(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var currRowSpan = td.getAttribute("rowSpan");
		if (tbody.rows.length > tr.rowIndex + currRowSpan) {
			td.setAttribute("rowSpan",td.getAttribute("rowSpan") + 1);
		}
		tableCleanCells(htmlToolbar.htmlField);
	}
}
function tableDecreaseRowSpan(htmlToolbar) {
	var td = getCurrent(htmlToolbar.htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var currRowSpan = td.getAttribute("rowSpan");
		if (td.getAttribute("rowSpan") > 1) {
			td.setAttribute("rowSpan",td.getAttribute("rowSpan") - 1);
		}
		tableCleanCells(htmlToolbar.htmlField);
	}
}

// Clean up missing or extra cells
function tableCleanCells(htmlField) {
	// Make sure rows have the same number of columns
	var td = getCurrent(htmlField,"TD");
	if (td != null && td.tagName == "TD") {
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var rows = tbody.rows;
		var rowCells = new Array();
		var maxCells = 0;
		for (var r = 0; r < rows.length; r ++) { rowCells[r] = 0; }
		for (var r = 0; r < rows.length; r ++) {
			// Count columns for each row
			for (var c = 0; c < rows[r].cells.length; c ++) {
				rowCells[r] = rowCells[r] + rows[r].cells[c].colSpan;
				// While we're at at, make sure all cells contain a child node in Gecko
				if (isGecko() && rows[r].cells[c].childNodes.length == 0) {
					rows[r].cells[c].appendChild(htmlField.contentWindow.document.createElement("BR"));
				}
				if (rows[r].cells[c].rowSpan > 1) {
					for (var s = r + 1; s < r + rows[r].cells[c].rowSpan; s ++) {
						rowCells[s] = rowCells[s] + rows[r].cells[c].colSpan;
					}
				}
			}
			if (rowCells[r] > maxCells) maxCells = rowCells[r];
		}
		for (var r = 0; r < rows.length; r ++) {
			// Adjust columns for each row.
			if (rowCells[r] != maxCells) {
				var diff = maxCells - rowCells[r];
				if (diff > 0) {
					for (var d = 0; d < diff; d ++) {
						td = rows[r].insertCell(rowCells[r] + d);
						if (isGecko()) td.appendChild(htmlField.contentWindow.document.createElement("BR"));
					}
				} else {
					for (var d = 0; d > diff; d --) { rows[r].deleteCell(rowCells[r] + d); }
				}
			}
		}
	}
	tableSetGuidelines(htmlField.editArea);
}

// Set dotted quidelines for tables without borders.
function tableSetGuidelines(id) {
	var tables = id.getElementsByTagName("TABLE");
	for (var t = 0; t < tables.length; t ++) {
		if (tables[t].border == 0) {
			tables[t].border = 1;
			tables[t].className = listAppend(tables[t].className,"showborders"," ");
		}
	}
}
function tableRemoveGuidelines(id) {
	var tables = id.getElementsByTagName("TABLE");
	for (var t = 0; t < tables.length; t ++) {
		if (listFind(tables[t].className,"showborders"," ")) {
			tables[t].border = 0;
			tables[t].className = listRemove(tables[t].className,"showborders"," ");
		}
	}
}


///////////////////////////////////////////////////////////////
// Class and style functions
///////////////////////////////////////////////////////////////

// Get all stylesheet rules.
var stylesheetRules = new Array();
var stylesheetXml;
function getStyleXml() {
	if (stylesheetXml == null) stylesheetXml = xGetXml(AppVirtualPath + "/style.xml")
}
function getStylesheetRules(htmlField) {
	if (stylesheetRules.length == 0) {
		var ss = htmlField.contentWindow.document.styleSheets;
		var ssArray = new Array();
		// re to match a class definition
		var re = /^\s*([^, ]*)\.([^,: ]+)$/i;
		var rules,rule,ruleInfo,selectors,classSelector;
		var styleNames = new Array();

		// get all style names from xml document.
		if (stylesheetXml != null) {
			var styles = stylesheetXml.getElementsByTagName("style");
			for (var i = 0; i < styles.length; i ++) {
				styleNames[styles[i].getElementsByTagName("class")[0].firstChild.nodeValue.toLowerCase()] = styles[i].getElementsByTagName("name")[0].firstChild.nodeValue;
			}
		}

		//add all stylesheets to array, including imported stylesheets
		for (var s = 0; s < ss.length; s ++) {
			ssArray[ssArray.length] = ss[s];
			//Add imported stylesheets (IE)
			if (ss[s].imports) {
				for (var i = 0; i < ss[s].imports.length; i ++) {
					ssArray[ssArray.length] = ss[s].imports[i];
				}
			}
		}

		//add all rules to array
		for (var s = 0; s < ssArray.length; s ++) {
			try {
				rules = xGetStyleSheetRules(ssArray[s]);
			} catch (e) {
				rules = [];
			}
			for (var r = 0; r < rules.length; r ++) {
				rule = rules[r];
				// Add imported stylesheets (Gecko)
				if (rule.cssText && rule.cssText.indexOf("@import") > -1) {
					ssArray[ssArray.length] = rule.styleSheet;
				}
				if (rule.selectorText != null) {
					// Split selectors by comma.
					// Note that IE creates separate rules for separate selectors while Firefox keeps them as one rule
					selectors = rule.selectorText.split(",");
					for (var s2 = 0; s2 < selectors.length; s2 ++) {
						classSelector = selectors[s2].match(re);
						if (classSelector != null && styleNames[classSelector[2].toLowerCase()]) {
							tag = classSelector[1];
							className = classSelector[2];

							// get existing rule info array
							ruleInfo = null;
							for (var i = 0; i < stylesheetRules.length; i ++) {
								if (stylesheetRules[i][0] == className) {
									ruleInfo = stylesheetRules[i];
									break;
								}
							}

							// create new rule info array
							if (ruleInfo == null) {
								ruleInfo = new Array();
								ruleInfo[0] = className;
								ruleInfo[1] = rule;
								ruleInfo[2] = new Array(); // tag array
								ruleInfo[3] = styleNames[classSelector[2].toLowerCase()];
								stylesheetRules.push(ruleInfo);
							}

							// add tag to tag array
							if (!arrayContains(ruleInfo[2],tag)) {
								ruleInfo[2].push(tag.toUpperCase());
							}
						}
					}
				}
			}
		}
		//sort rules
		stylesheetRules.sort(compareStylesheetRules);
	}
	return stylesheetRules;
}
function compareStylesheetRules(ruleInfo1, ruleInfo2) {
	if (ruleInfo1[3] > ruleInfo2[3]) {
		return 1;
	} else {
		return -1;
	}
}


function wysiwygAddClass(className,tagName,element) {
	if (styleEditMode == "spans") {
		if (tagName == "SPAN") {
			var currentRange = xGetSelectionRange(currentField.contentWindow);

			// run font command
			currentField.contentWindow.document.execCommand("FontSize",false,"1");

			// replace all fonts with span tags and apply class to new tags
			fontElements = currentField.editArea.getElementsByTagName("FONT");
			var firstSpan, lastSpan;
			for (var i = fontElements.length-1; i > -1; i--) {
				if (fontElements[i].parentNode.tagName == "SPAN" && stripHTML(fontElements[i].innerHTML) == stripHTML(fontElements[i].parentNode.innerHTML)) {
					spanElement = fontElements[i].parentNode;
					spanElement.innerHTML = fontElements[i].innerHTML;
				} else {
					var spanElement = currentField.contentWindow.document.createElement("SPAN");
					spanElement.innerHTML = fontElements[i].innerHTML;
					fontElements[i].parentNode.replaceChild(spanElement,fontElements[i]);
				}
				spanElement.className = className;
				if (lastSpan == null) lastSpan = spanElement;
			}
			firstSpan = spanElement;

			// set selected range to coincide with span elements.
			if (currentRange.duplicate) {
				var elementRange = xCloneRange(currentRange);
				xMoveToElementText(elementRange,firstSpan);
				currentRange.setEndPoint("StartToStart",elementRange);
				xMoveToElementText(elementRange,lastSpan);
				currentRange.setEndPoint("EndToEnd",elementRange);
				xSelectRange(currentField.contentWindow,currentRange);
			} else if (firstSpan != null && lastSpan != null) {
				currentRange.setStartBefore(firstSpan);
				currentRange.setEndAfter(lastSpan);
			}

		} else {
			var els = currentField.contentWindow.document.getElementsByTagName(tagName);
			var currentRange = xGetSelectionRange(currentField.contentWindow);
			for (var i = 0; i < els.length; i ++) {
				if (xElementIsInRange(els[i],currentRange)) {
					els[i].className = listAppend(els[i].className,className," ");
				}
			}
		}

	} else {
		if (element == null) element = getCurrent(currentField,tagName);
		if (element != null) {
			element.className = listAppend(element.className,className," ");
		}
	}
}

function wysiwygRemoveClass(className,tagName,element) {
	if (styleEditMode == "element") {
		if (element == null) element = getCurrent(currentField);
		var foundClass = false;
		while (!foundClass && element && element.id != null && element.id.indexOf("_editArea") == -1) {
			if (listFind(element.className,className," ")) {
				element.className = listRemove(element.className,className," ");
				foundClass = true;
			} else {
				element = element.parentNode;
			}
		}
	} else {
		var els = currentField.contentWindow.document.getElementsByTagName(tagName);
		var currentRange = xGetSelectionRange(currentField.contentWindow);
		for (var i = 0; i < els.length; i ++) {
			if (xElementIsInRange(els[i],currentRange)) {
				els[i].className = listRemove(els[i].className,className," ");
			}
		}
	}
}
function setStyles(e) {
	var srcEl = xGetEventSrcElementForWindow(currentField.window,e);
	if (srcEl.tagName == "LABEL") {
		srcEl = srcEl.ownerDocument.getElementById(srcEl.getAttribute("for"));
	}
	var info = srcEl.id.split("|");
	if (srcEl.checked) {
		wysiwygAddClass(info[0],info[1]);
	} else {
		wysiwygRemoveClass(info[0],info[1]);
	}
	if (currentField != null) {
		currentField.saveContents();
	}
}


///////////////////////////////////////////////////////////////
// Formatting and String Manipulation Functions
///////////////////////////////////////////////////////////////


// Remove formatting -- this prevents funky formatting from pasting from Microsoft programs
// like Word.
function removeFormatting(htmlField) {
	editArea = htmlField.editArea;
	workArea = htmlField.workArea;
	var html;
	html = editArea.innerHTML;

	workArea.innerHTML = html;
	tableRemoveGuidelines(workArea);
	// Replace header tags, address tags, and pre with P tags.
	workArea.innerHTML = workArea.innerHTML.replace(/<(\/?)(h[1234567]|address|pre)/gi,"<$1p");
	// Remove some tags altogether
	workArea.innerHTML = workArea.innerHTML.replace(/<\/?(font|span)[^>]*>/gi,"");
	// Remove special xml namespace info
	if (workArea.innerHTML.indexOf("<?xml:namespace") > -1) {
		workArea.innerHTML = workArea.innerHTML.replace(/<(\?xml:namespace|\/?[a-z0-9]+:[a-z0-9]+)[^>]*>/gi,"");
	}
	// Remove all attributes from some tags
	workArea.innerHTML = workArea.innerHTML.replace(/(<ul|<li) [^>]+>/gi,"$1>");
	// Remove certain attributes
	workArea.innerHTML = workArea.innerHTML.replace(/(<[^>]+) style="[^"]+"/gi,"$1");
	workArea.innerHTML = workArea.innerHTML.replace(/(<[^>]+) class=("[^"]+"|[^ ">]+)/gi,"$1");
	// Clean up
	workArea.innerHTML = cleanUp(workArea.innerHTML);
	tableSetGuidelines(workArea);

	editArea.innerHTML = workArea.innerHTML;

	//htmlField.setActive();
}

function cleanUp(s,editWindow) {
	// IE automatically turns relative paths into absolute paths, which is not usually what we want.
	// Replace absolute local paths with virtual paths
	var re = new RegExp("(href|src)=\""+window.location.protocol+"//"+window.location.hostname+"(:"+window.location.port+")?/","gi");
	s = s.replace(re,"$1=\"/");

	if (editWindow != null) {
		// Fix internal anchor links
		re = new RegExp("href=\"" + reEscape(editWindow.location.pathname) + "(" + reEscape(htmlEncode(editWindow.location.search)) + ")?" + "[^#\"]*#([^\"]+)","gi");
		s = s.replace(re,"href=\"#$2");
	}

	//Remove lonely br tag or empty p tag
	s = s.replace(/^(<br>|<p>&nbsp;<\/p>)$|/i,"");

	// If paragraph tags are nested, change outer <p> to a <div>.
	s = s.replace(/<P( [^>]+)?>((\s*<P( [^>]+)?>[\s\S]+?<\/P>\s*)+)<\/P>/gi,"<DIV$1>$2</DIV>");

	s = cleanUpStyle(s);

	// Insert line breaks to make code readable
	// Insert break before
	s = s.replace(/([^\n\r])(<\/ul>|<li>)/gi,"$1\n$2");
	// Insert break after
	s = s.replace(/(<br>|<\/p>|<\/ul>|<\/table>|<\/div>)([^\n\r])/gi,"$1\n$2");

	/* Remove poorly formatted conditional comments.  These can be created by pasting from Word into
	Firefox.  They don't show up in Firefox, but do in IE.
	About conditional comments: http://msdn.microsoft.com/en-us/library/ms537512.aspx */
    s = s.replace(/<!--\[[^\]]*\]-->/g, "");
	
	return s;
}
function trimLocalUrl(/*string*/ s) {
	var re = new RegExp(window.location.protocol+"//"+window.location.hostname+"(:"+window.location.port+")?/","gi"); 
	return s.replace(re,"/")
}

function cleanUpStyle(s) {
	// Remove span tags with no style info
	s = s.replace(/<span( class="")?( style="")?>([^<]*(<br>[^<]*)*)<\/span>/gi,"$3");
	// Remove empty span tags
	s = s.replace(/<span( [^>]+)?><\/span>/gi,"");

	return s;
}

function toHex(dec){
	var result = parseInt(dec).toString(16);
	if(result.length == 1) result = ("0" + result);
	result = result.substring(4,6).toUpperCase() + result.substring(2,4).toUpperCase() + result.substring(0,2).toUpperCase();
	if (result.length == 2) result = result + "0000";
	if (result.length == 4) result = result + "00";
	return result;
}

function replaceSpecialChars (s) {
	// Replace email addresses with obfuscated email addresses
	var reEmail = /(mailto:)?([\w.-]+\@[\w.-]+\.[\w]{2,4})/i;
	var n = 1;
	while (s.search(reEmail) != -1) {
		found = s.match(reEmail);
		s = replaceAll(s,found[0],munge(found[0]));
		n ++;
		if (n > 1000) break;
	}

	return s;
}
function replaceSpecialChars_Text (s) {
	s = replaceAll(s,"?","--"); // m dash
	s = replaceAll(s,"?","-"); // n dash
	s = replaceAll(s,"?","(tm)"); // trademark
	s = replaceAll(s,"?","..."); // ellipses
	// Curly quotes ("Smart" quotes)
	s = replaceAll(s,"?","\"");
	s = replaceAll(s,"?","\"");
	s = replaceAll(s,"?","'");
	s = replaceAll(s,"?","'");
	return s;
}


// function to turn a string into a series of ISO-Latin-1 codes.
// Used to create an anti-spam email link
function munge(s) {
	txt = "";
	for (var j=0; j < s.length; j++) {
		txt += "&#" + s.charCodeAt(j) + ";";
	}
	return txt;
}

function getFriendlyTagName(tagName) {
	switch (tagName) {
		case "P":return "Paragraph"; break;
		case "A":return "Link"; break;
		case "UL":return "List"; break;
		case "OL":return "List"; break;
		case "LI":return "List Item"; break;
		case "STRONG":return "Bold Text"; break;
		case "B":return "Bold Text"; break;
		case "EM":return "Italic Text"; break;
		case "I":return "Italic Text"; break;
		case "U":return "Underlined Text"; break;
		case "SUP":return "SuperScript Text"; break;
		case "SUB":return "SubScript Text"; break;
		case "BLOCKQUOTE":return "Indented Text"; break;
		case "IMG":return "Image"; break;
		case "TABLE":return "Table"; break;
		case "TR":return "Table Row"; break;
		case "TH":return "Table Header"; break;
		case "TD":return "Table Cell"; break;
		case "FONT":return "Text"; break;
		case "SPAN":return "Text"; break;
		default:return tagName;
	}
}


///////////////////////////////////////////////////////////////
// Functions for initializing htmlFields
///////////////////////////////////////////////////////////////
function wysiwygInit() {
	var htmlToolbar = null;
	var frames = document.getElementsByTagName("IFRAME");
	for (var f = 0; f < frames.length; f ++) {
		if (listFind(frames[f].className,"editable"," ")) {
			var fieldId = replace(frames[f].id,"_editArea","");
			wysiwygInitField(fieldId);
		}
	}
}
function wysiwygInitField(fieldId) {
	var htmlToolbar = null;
	var frame = getEl(fieldId + "_editArea");
	if (htmlToolbars[fieldId]) htmlToolbar = htmlToolbars[fieldId];
	htmlFields[fieldId] = new top.htmlField('frame',window,fieldId,htmlToolbar);
	var doc = frame.contentWindow.document;
	xAddEvent(doc,"click",wysiwygClick);
	xAddEvent(doc,"focus",wysiwygFocus);
	xAddEvent(doc,"blur",wysiwygBlur);
	xAddEvent(doc,"contextmenu",wysiwygContextmenu);
	if (htmlFieldClasses[fieldId]) doc.body.className = listAppend(doc.body.className,htmlFieldClasses[fieldId]," ");
	wysiwygSetDesignMode(doc);
	if (!htmlToolbars[fieldId]) wysiwygResize();
}
function wysiwygSetDesignMode(doc) {
	//This will fail if the element is hidden
	try {
		doc.designMode = "on";
		//useCSS is deprecated, but styleWithCSS may not be supported yet
		try {
			doc.execCommand("styleWithCSS",false,false);
		} catch(ex) {
			doc.execCommand("useCSS",false,true);
		}
	} catch(ex) {}
	lh.LoadStylesheet(doc,AppVirtualPath + "/style.css");
}
function wysiwygResize() {
	var frames = document.getElementsByTagName("IFRAME");
	var doc, lineHeight, c, height;
	for (var f = 0; f < frames.length; f ++) {
		if (listFind(frames[f].className, "editable", " ")) {
			doc = frames[f].contentWindow.document;
			if (doc.body) {
				height = doc.body.offsetHeight;
				//Determine line-height to use if field is empty.
				if (frames[f].contentWindow.getComputedStyle(doc.body, null)) {
					lineHeight = frames[f].contentWindow.getComputedStyle(doc.body, null).getPropertyValue("line-height").replace("px", "");
				}
				if (isNaN(lineHeight)) {
					lineHeight = 15;
				}
				if (height < lineHeight) 
					height = lineHeight;
				c = doc.body.childNodes;
				//add offsetTop of first element
				if (c.length > 0) {
					if (c[0].offsetTop != undefined) 
						height = height + c[0].offsetTop;
				}
				//floating elements are not included in the body height.  Find lowest element.
				for (var i = 0; i < c.length; i++) {
					if (c[i].offsetTop != undefined && height < c[i].offsetTop + c[i].offsetHeight) {
						height = c[i].offsetTop + c[i].offsetHeight;
					}
				}
				frames[f].style.height = height + "px";
			}
		} else {
			frames[f].onerror = function(){return true;}
		}
	}
	setTimeout("wysiwygResize()",500);
}
function wysiwygClick(e) {
	var doc = xGetEventSrcElement(e);
	//Hide context menu
	if (htmlFields[doc.body.id]) {
		htmlFields[doc.body.id].hideContextMenu();
		//Hide Styles menu
		if (htmlFields[doc.body.id].htmlToolbar) {
			htmlFields[doc.body.id].htmlToolbar.hideStylesMenu();
		}
	}
}
function wysiwygFocus(e) {
	var doc = xGetEventSrcElement(e);
	if (doc.designMode == "off") {
		wysiwygSetDesignMode(doc);
	}
	wysiwygSetFieldToolbar(htmlFields[doc.body.id]);
}
function wysiwygBlur(e) {
	try {
		var doc = xGetEventSrcElement(e);
		htmlFields[doc.body.id].saveContents();
	} catch(er) {}
}
function wysiwygContextmenu(e) {
	e.preventDefault();
	var doc = xGetEventSrcElement(e);
	wysiwygSetFieldToolbar(htmlFields[doc.body.id]);
	htmlFields[doc.body.id].showContextMenu(e);
}
function wysiwygSetFieldToolbar(htmlField) {
	if (htmlField.toolbar == null && top.htmlToolbars) {
		var htmlToolbar = top.htmlToolbars["main"];
		if (htmlField && htmlToolbar) {
			htmlField.htmlToolbar = htmlToolbar;
			htmlToolbar.htmlField = htmlField;
		}
	}
}

function xSetFieldActive(htmlField) {
	if (htmlField.editArea.setActive) {
		htmlField.editArea.setActive();
	} else {
		htmlField.contentWindow.focus();
	}
}

//function to initialize a field dynamically
function xInitField(fieldId,value) {
	htmlToolbars[fieldId] = new top.htmlToolbar(window,fieldId);
	getEl(fieldId).value = value;
	getEl(fieldId + "_workArea").innerHTML = value;
	if (getEl(fieldId + "_editArea").tagName == "IFRAME") {
		wysiwygInitField(fieldId)
	} else {
		htmlFields[fieldId] = new htmlField("inline",window,fieldId,htmlToolbars[fieldId]);
	}
}
