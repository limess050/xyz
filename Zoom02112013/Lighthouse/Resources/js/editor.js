/////////////////////////////////////
// Site Editor js
/////////////////////////////////////
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.AccordionContainer");
dojo.require("dojo.widget.ContentPane");
dojo.require("dojo.widget.Dialog");
dojo.require("dojo.widget.SplitContainer");
dojo.require("dojo.widget.Tooltip");
dojo.require("dojo.widget.TreeV3");
dojo.require("dojo.widget.TreeEmphasizeOnSelect");
dojo.require("dojo.widget.TreeLoadingControllerV3");
dojo.require("dojo.widget.TreeNodeV3");
dojo.require("dojo.widget.TreeSelectorV3");

//Variables
var split,main,pageInfoTab,pagePermsTab,myPagesTab,treeTab,selector,controller,p,node,topicsArray,monitor,switchPageID;
var doGo = true;
var edit = true;
var newTopicsPrompt = "Type a new topic here";
var selectedTopicsArray = [];
var autoRefreshTopics = true;
var autoRefreshMyPages = false;
lh.editor = {};

dojo.addOnLoad(function(){
	split = dojo.widget.byId("topContainer");
	main = dojo.widget.byId("mainContainer");
	pageInfoTab = dojo.widget.byId("pageInfoTab");
	pagePermsTab = dojo.widget.byId("pagePermsTab");
	myPagesTab = dojo.widget.byId("myPagesTab");
	treeTab = dojo.widget.byId("treeTab");
	tree = dojo.widget.byId('tree');
	selector = dojo.widget.byId('selector');
	controller = dojo.widget.byId('controller');

	//Hide frame when resizing the split container in order for resizing to work properly
	dojo.event.connect(split,"beginSizing",function(){
		dojo.byId("page").style.display = "none";
	});
	dojo.event.connect(split,"endSizing",function(){
		dojo.byId("page").style.display = "";
	});

	//Reset the height of the accordion when the page is resized.
	dojo.event.connect("before",main,"onResized",function(){
		dojo.byId("mainContainer").style.height=dojo.html.getViewport().height.toString()+"px";
	});

	//Show select box when tab show (IE6 workaround).
	getEl("selectTopics").style.display = pageInfoTab.isShowing()?"":"none";
	dojo.event.connect(pageInfoTab,"onShow",function(){getEl("selectTopics").style.display = "";});
	dojo.event.connect(pageInfoTab,"onHide",function(){getEl("selectTopics").style.display = "none";});
	getEl("userGroupIDs").style.display = pagePermsTab.isShowing()?"":"none";
	dojo.event.connect(pagePermsTab,"onShow",function(){getEl("userGroupIDs").style.display = "";});
	dojo.event.connect(pagePermsTab,"onHide",function(){getEl("userGroupIDs").style.display = "none";});

	//Refresh MyPages when the tab is shown
	dojo.event.connect(myPagesTab,"onShow",function(){
		refreshMyPages();
	});
	
	//Refresh tree when the tab is shown
	dojo.event.connect(treeTab,"onShow",function(){
		//Set timeout for refresh so that animation can start immediately
		setTimeout("refreshPageTree();selectPage();",500);
	});
	//Set the function to run when a node in the tree is selected
	dojo.event.topic.subscribe(selector.eventNames.select,new pageSelected(),'go');

	//Save selected tab on unload
	window.onunload = function(){
		var tabName;
		if (pageInfoTab.parent.selected){tabName = "pageInfo";
		} else if (pagePermsTab.parent.selected) {tabName = "pagePerms";
		} else if (myPagesTab.parent.selected) {tabName = "myPages";
		} else if (treeTab.parent.selected) {tabName = "tree";}
		lh.SaveSetting("EditorTab",tabName);
	}
	//Show the tab that has been saved
	lh.GetSetting("EditorTab",function(type,tabName){
		if (tabName.length > 0) {
			var tab = dojo.widget.byId(tabName + "Tab");
			if (tab){main.selectChild(tab.parent);}
		}
	});
	
	xAddEvent(window,"resize",setFrameSize);
	
	getEl("txtTitle").onkeyup = function(){
		if (getHtmlField("title")){
			getHtmlField("title").setContents(this.value);
		}
	};
	getEl("txtTitle").onfocus = function(){
		if (getHtmlField("title")){
			this.value = getHtmlField("title").getContents();
		}
	};
	getEl("txtNavTitle").onkeyup = function(){
		var el = getEl("page").contentWindow.getEl("currentNavTitle");
		if (el){
			el.innerHTML = this.value;
		}
	}

	//Topics
	getEl("newTopics").value = newTopicsPrompt;
	getEl("newTopics").onfocus = function(){
		this.style.color = "black";
		if (this.value == newTopicsPrompt){
			this.value = "";
		}
	}
	getEl("newTopics").onblur = function(){
		if (this.value == ""){
			this.style.color = "gray";
			this.value = newTopicsPrompt;
		}
	}
	getEl("selectTopics").onchange = function(){
		var opt = getEl("selectTopics").options[getEl("selectTopics").selectedIndex];
		addTopics(opt.text);
		getEl("selectTopics").selectedIndex = 0;
	}
	getEl("addTopics").onclick = function(){
		addNewTopic();
	}
	
	//members only
	getEl("rbMembersOnlyYes").onclick = getEl("rbMembersOnlyNo").onclick = checkMembersOnly;
	
	//Dialogs
	dojo.widget.byId("dlgSave").setCloseControl(dojo.byId("CancelSave"));
	xAddEvent(top.getEl("page"),"load",finalizePage);

	monitor = new lh.ChangeMonitor(function(){
		getEl("monitorStatus").style.display = monitor.isChanged()?"":"none";
	});
	setOnBeforeUnload();
	finalizePage();

	getEl("loadIndicator").style.display="none";
	main.onResized();
	setFrameSize();
});

function onBeforeUnload(e){
	if (monitor && monitor.isChanged()) {
		return "Your unsaved changes may be lost.";		
	}
}

function finalizePage(){
	if (switchPageID != null){
		monitor.stop();
		editPage(switchPageID);
		switchPageID = null;
	} else {
		//cancel onbeforeupload when mousing over a javascript link in the page.  To avoid too many popups in IE.
		var links = getEl("page").contentWindow.document.getElementsByTagName("A");
		for (var i=0;i<links.length;i++){
			if (links[i].href.indexOf("javascript:top.")==0){
				xAddEvent(links[i],"mouseover",cancelOnBeforeUnload);
				xAddEvent(links[i],"mouseout",setOnBeforeUnload);
			}
		}
		setDefaultArea();
		setPageStatus("");

		//Refresh My Pages, if necessary
		if (myPagesTab.isShowing && autoRefreshMyPages){
			refreshMyPages();
			autoRefreshMyPages = false;
		}

		//Set up change monitor
		monitor.Fields = [];
		monitor.addField("getEl('txtName').value",{});
		monitor.addField("getEl('txtTitle').value",{});
		monitor.addField("getEl('txtNavTitle').value",{});
		monitor.addField("getEl('rbShowInNavYes').checked",{});
		monitor.addField("getEl('txtBrowserTitle').value",{});
		monitor.addField("getEl('txtMetaDescription').value",{});
		monitor.addField("dojo.json.serialize(selectedTopicsArray)",{});
		monitor.addField("getEl('rbMembersOnlyYes').checked",{});
		monitor.addField("getEl('rbLinkPublicYes').checked",{});
		monitor.addField("getSelectedValues(getEl('userGroupIDs')).join(',')",{});
		//html fields
		for (id in window.getEl("page").contentWindow.htmlFields) {
			var propName = "getHtmlField('" + id + "').getRawContents()";
			if (!monitor.hasField(propName)){
				monitor.addField(propName,{});
			}
		}
		monitor.start();
	}
}

function checkForChanges(pageID){
	if (monitor.isChanged()){
		if (confirm("Would you like to save your changes?")){
			dojo.widget.byId('dlgSave').show();
			switchPageID = pageID;
			return false;
		}else{
			return true;
		}
	}else{
		return true;
	}
}

function refreshMyPages(){
	//console.log("Refreshing My Pages");
	dojo.io.bind({
		url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=GetWorkInProgressJson",
	    load: function(type, a){
			var ul = getEl("wipUl")
			ul.innerHTML = "";
			if (a.length>0){
				for (var i=0;i<a.length;i++){
					addPageLink(ul,a[i]);
				}
			} else {
				ul.appendChild(document.createElement("i")).innerHTML = "You don't have any work in progress.";
			}
	    },
	    mimetype: "text/json-comment-filtered"
	});
	dojo.io.bind({
		url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=GetWorkflowItemsJson",
	    load: function(type, a){
			var div = getEl("workflow");
			div.innerHTML = "";
			for (var i=0;i<a.length;i++){
				div.appendChild(document.createElement("b")).innerHTML = a[i][0] + ":";
				ul = div.appendChild(document.createElement("ul"));
				for (var j=0;j<a[i][1].length;j++){
					addPageLink(ul,a[i][1][j]);
				}
			}
	    },
	    mimetype: "text/json-comment-filtered"
	});
}
function addPageLink(ul,a){
	ul.appendChild(document.createElement("li")).innerHTML = "<a href='#' onclick='editPage(" + a[0] + ")'>" + stripHTML(a[1]) + "</a>";
}


function refreshTopics(){
	dojo.io.bind({
		url:AppVirtualPath+"/Lighthouse/Admin/rpc.cfm?object=Topic&method=GetAll",
	    load: function(type, evaldObj){
	    	topicsArray = evaldObj;
			populateSelectList(getEl("selectTopics"),topicsArray);
	    },
	    mimetype: "text/json-comment-filtered"
	});
}

function addNewTopic(){
	if (getEl("newTopics").value != newTopicsPrompt){
		addTopics(getEl("newTopics").value);
		getEl("newTopics").value = "";
	}
}

function addTopics(s){
	var topic = trim(s);
	var topicID = "";
	if (s.length > 0 && !topicSelected(topic)){
		for (var i=0;i<getEl("selectTopics").options.length;i++){
			if (getEl("selectTopics").options[i].text == topic){
				topicID = getEl("selectTopics").options[i].value;
				break;
			}
		}
		selectedTopicsArray.push([topicID,topic])
	}
	selectedTopicsArray.sort(compareTopics);
	displayTopics();
	autoRefreshTopics = true;
	return true;
}

function topicSelected(topic){
	topic = topic.toLowerCase();
	for (var i=0;i<selectedTopicsArray.length;i++){
		if (selectedTopicsArray[i][1].toLowerCase()==topic){
			return true;
		}
	}
	return false;
}

function compareTopics(a,b){
	if (a[1].toLowerCase()<b[1].toLowerCase()) return -1;
	if (b[1].toLowerCase()<a[1].toLowerCase()) return 1;
	return 0;
}

function removeTopic(i){
	if (confirm("Are you sure you want to remove the topic \"" + selectedTopicsArray[i][1] + "\"?")){
		selectedTopicsArray.splice(i,1);
		displayTopics();
	}
}

function displayTopics(){
	var html = ""
	for (var i=0;i<selectedTopicsArray.length;i++){
		html += "<div>" + selectedTopicsArray[i][1] + " <span class=indicator title='Remove this topic' onclick=removeTopic(" + i + ")>X</span></div>";
	}
	getEl("displayTopics").innerHTML = html;
}

function checkMembersOnly(){
	getEl("divLinkPublic").style.display = getEl("divUserGroups").style.display = getEl("rbMembersOnlyYes").checked?"":"none";
}

function getHtmlField(id){
	return getEl("page").contentWindow.htmlFields[id]
}

function setDefaultArea() {
	var pageFrame = getEl("page").contentWindow;
	if (pageFrame.htmlFields && htmlToolbars && htmlToolbars["main"]){
		var field = pageFrame.htmlFields["body"];
		if (field) {
			htmlToolbars["main"].htmlField = field;
			field.htmlToolbar = htmlToolbars["main"];
		}
	}
}

function editPage(pageID,reload) {
	if (reload){
		setPageStatus("Reloading page.")
		getEl("postback").contentWindow.location = AppVirtualPath + "/Lighthouse/Admin/pageHiddenForm.cfm?pageID=" + pageID + "&reloadPage=true";
	} else if(checkForChanges(pageID)){
		setPageStatus("Loading page.")
		getEl("postback").contentWindow.location = AppVirtualPath + "/Lighthouse/Admin/pageHiddenForm.cfm?pageID=" + pageID;
	}
}

function setFrameSize(){
	getEl("page").style.height = (dojo.html.getViewport().height-93).toString()+"px";
}

function pageSelected() {
	this.go = function() {
		if (doGo) {
			editPage(selector.selectedNodes[0].widgetId);
		} else {
			doGo = true;
		}
	}
}

function refreshPageTree() {
	if (treeTab.parent.selected){
		var parents = p.COOKIECRUMB.split(",");
		for (var i=0;i<parents.length;i++){
			var parentNode = dojo.widget.byId(parents[i]);
			if (parentNode){
				controller.refreshChildren(parentNode,true);
			} else {
				break;
			}
		}
		controller.refreshChildren(parentNode,true);
		node = dojo.widget.byId(p.PAGEID.toString());
		if (node) controller.refreshChildren(node,true);
	}
}

function selectPage() {
	if (treeTab.parent.selected){
		node = dojo.widget.byId(p.PAGEID.toString());
		if (node == null){
			refreshPageTree();
		}
		if (node && !node.selected) {
			doGo = false;
			selector.deselectAll();
			selector.select(node);
			if (node.isFolder) {
				controller.expand(node,false);
			}
		}
	}
}

function updateLink() {
	if (getEl("link")){
		getEl("link").innerHTML = httpUrl + "/" + getUrlName();
		if (getEl("txtName").value.toLowerCase() != getUrlName()) {
			alert("The page name is used to contruct the url for the page, and can therefore only contain letters, numbers, dashes or underscores.\nOther characters, such as spaces, are not allowed.");
			getEl("txtName").value = getUrlName();
		}
	}
}

function getUrlName() {
	return getEl("txtName").value.toLowerCase().replace(/[^0-9a-z-_\/]/g,"");
}

function setPageProperties(page) {
	p = page;
   	getEl("txtName").value = p.NAME;
	getEl("txtName").onkeyup = updateLink;
	updateLink();
   	getEl("txtTitle").value = p.TITLE;
   	getEl("txtNavTitle").value = p.NAVTITLE;
   	getEl("txtBrowserTitle").value = p.TITLETAG;
   	getEl("txtMetaDescription").value = p.METADESCRIPTION;
   	if (p.SHOWINNAV == 0){
    	getEl("rbShowInNavNo").checked = getEl("rbShowInNavNo").defaultChecked = true;
   	}else{
    	getEl("rbShowInNavYes").checked = getEl("rbShowInNavYes").defaultChecked = true;
   	}
	getEl("pageStatusName").innerHTML = p.STATUSNAME;
	getEl("pageIsActive").innerHTML = p.LIVEEXISTS;	
	if (autoRefreshTopics){
		refreshTopics();
		autoRefreshTopics = false;
	}
	selectedTopicsArray = eval(p.TOPICS);
	displayTopics();

	//permissions
   	if (p.MEMBERSONLY == 0){
    	getEl("rbMembersOnlyNo").checked = getEl("rbMembersOnlyNo").defaultChecked = true;
   	}else{
    	getEl("rbMembersOnlyYes").checked = getEl("rbMembersOnlyYes").defaultChecked = true;
   	}
   	if (p.LINKPUBLIC == 0){
    	getEl("rbLinkPublicNo").checked = getEl("rbLinkPublicNo").defaultChecked = true;
   	}else{
    	getEl("rbLinkPublicYes").checked = getEl("rbLinkPublicYes").defaultChecked = true;
   	}
	selectValues(getEl("userGroupIDs"),p.USERGROUPID.split(","),false,true);
	checkMembersOnly();
}

//Toolbar functions
function validateForm(formObj) {
	//Transfer page properties to hidden form
	if (checkText(getEl("txtName"),"Name")){
		createHiddenField("name",getEl("txtName").value);
	} else {
		if (!pageInfoTab.parent.selected) main.selectChild(pageInfoTab.parent);
		return false;
	}
	createHiddenField("title",getEl("txtTitle").value);
	if (checkText(getEl("txtNavTitle"),"Navigation Title")){
		createHiddenField("navtitle",getEl("txtNavTitle").value);
	} else {
		if (!pageInfoTab.parent.selected) main.selectChild(pageInfoTab.parent);
		return false;
	}
	createHiddenField("showInNav",getEl("rbShowInNavYes").checked?"1":"0");
	createHiddenField("titleTag",getEl("txtBrowserTitle").value);
	createHiddenField("metaDescription",getEl("txtMetaDescription").value);
	createHiddenField("topics",dojo.json.serialize(selectedTopicsArray));
	createHiddenField("membersOnly",getEl("rbMembersOnlyYes").checked?"1":"0");
	createHiddenField("linkPublic",getEl("rbLinkPublicYes").checked?"1":"0");
	createHiddenField("userGroupID",getSelectedValues(getEl("userGroupIDs")).join(","));
	
	// find editable area inputs in the page and transfer values to hidden form fields.
	var editableAreaInputs = window.parent.page.document.getElementsByName("editableAreaInput");
	for (var i=0;i<editableAreaInputs.length;i++) {
		createHiddenField("pagePart_" + editableAreaInputs[i].id,editableAreaInputs[i].value);
	}
	return true;
}

function createHiddenField(id,value) {
	var formPage = getEl("postback").contentWindow;
	var formObj = formPage.getEl("toolbarForm");
	var hiddenField;
	if (formPage.getEl(id)) {
		hiddenField = formPage.getEl(id);
	} else {
		hiddenField = formPage.document.createElement("INPUT");
		hiddenField.type = "hidden";
		hiddenField.id = id;
		hiddenField.name = id;
		formObj.appendChild(hiddenField);
	}
	hiddenField.value = value;
}

function deleteThisPage() {
	var formPage = getEl("postback").contentWindow;
	if (confirm("This page will be deleted.  Continue?")) {
		autoRefreshMyPages = true;
		setPageStatus("Deleting page.")
		formPage.getEl("toolbarForm").deletePage.value = "true";
		formPage.getEl("toolbarForm").submit();
	}
}

function changeStatus(statusID) {
	var formPage = getEl("postback").contentWindow;
	formPage.getEl("toolbarForm").statusID.value = statusID;
	saveChanges();
	dojo.widget.byId("dlgSave").hide();
}

function changeMembersOnly(membersOnly) {
	var formPage = getEl("postback").contentWindow;
	if (membersOnly=="") membersOnly="0";
	formPage.getEl("toolbarForm").membersOnly.value = membersOnly;
	saveChanges();
}

function saveChanges() {
	var formPage = getEl("postback").contentWindow;
	if (validateForm(formPage.getEl("toolbarForm"))) {
		monitor.stop();
		autoRefreshMyPages = true;
		setPageStatus("Saving Changes")
		formPage.getEl("toolbarForm").submit();
	}
}

function setPageStatus(msg){
	if (msg.length > 0){
		if (monitor) monitor.stop();
		getEl("monitorStatus").style.display = "none";
		getEl("editorStatus").innerHTML = "<img src=\"" + AppVirtualPath + "/Lighthouse/Resources/images/ajax-loader.gif\" alt=\"Progress Indicator\" style=\"margin-right:5px;\" align=absmiddle>" + msg;
		getEl("editorStatus").style.display = "";
		getEl("divPageStatus").style.display = "none";
	} else {
		getEl("editorStatus").innerHTML = "";
		getEl("editorStatus").style.display = "none";
		getEl("divPageStatus").style.display = "";
	}
}

function reloadToolbar(queryString) {
	var formPage = getEl("postback").contentWindow;
	formPage.location.replace(AppVirtualPath + "/Lighthouse/Admin/pageHiddenForm.cfm?" + queryString);
}

// show popup dialog box
var dialogWin;
function showDialog(dialogName) {
	var formPage = getEl("postback").contentWindow;
	var pageID = formPage.p.PAGEID;
	var parentPageID = formPage.p.PARENTPAGEID;
	var sectionID = formPage.p.SECTIONID;
	var dialogWidth = 550;
	var dialogHeight = 400;
	var queryString = "";
	switch (dialogName) {
		case "template" :
			queryString = "&select=1";
			break;
		case "archive" :
			queryString = "&pageID=" + pageID + "&select=1";
			break;
		case "status" :
			queryString = "&pageID=" + pageID;
			break;
		case "browse" :
			queryString = "";
			break;
		case "permissions" :
			queryString = "&pk=" + pageID;
			break;
		case "properties" :
			queryString = "&pk=" + pageID;
			break;
		case "newPage" :
			queryString = "&parentPageID=" + parentPageID + "&sectionID=" + sectionID;
			break;
	}
	dialogWin = popupDialog("dialog",dialogWidth,dialogHeight,"resizable=1,scrollbars=1,status=1");
	dialogWin.location.href = "index.cfm?adminFunction=dialogs%2F" + dialogName + "&currentpageid=" + pageID + queryString;
}

function showWindow(windowName){
	var formPage = getEl("postback").contentWindow;
	var pageID = formPage.p.PAGEID;
	var url;
	switch (windowName) {
		case "versions" :
			url = "index.cfm?adminFunction=versionsView&pageID=" + pageID;
			break;
		case "preview" :
			url = "../page.cfm?pageVersion=working&pageID=" + pageID;
			break;
	}
	window.open(url,windowName);
}

// function to catch template selection from popup dialog
function TemplateID_add(templateID,name) {
	var formPage = getEl("postback").contentWindow;
	formPage.getEl("toolbarForm").templateID.value = templateID;
	dialogWin.close();
	saveChanges();
}
function TemplateID_delete (templateID) {
	var formPage = getEl("postback").contentWindow;
	formPage.getEl("toolbarForm").templateID.value = "";
}
// Check to see if an item is already selected
function TemplateID_isSelected (templateID) {
	var formPage = getEl("postback").contentWindow;
	if (formPage.getEl("toolbarForm").templateID.value == templateID) {
		return true;
	} else {
		return false;
	}
}
