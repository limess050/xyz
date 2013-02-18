/////////////////////////////////////
// Column
/////////////////////////////////////
lh.Column = function(/*Object*/props) {
    for (prop in props){
		this[prop] = props[prop];
	}
	lh.Columns[this.NAME] = this;
}
lh.Column.prototype = {
	render: function(){},
	setValue: function(value){
		getEl(this.fieldId).value = getEl(this.fieldId).defaultValue = value;
	},
	getValue: function(){
		return getEl(this.fieldId).value;
	},
	validate: function(){
		if (cfBoolean(this.REQUIRED)) {
			return checkText(getEl(this.fieldId),this.DISPNAME);
		} else {
			return true;
		}
	}
}

/////////////////////////////////////
// TextColumn
/////////////////////////////////////
lh.TextColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.TextColumn.prototype = new lh.Column;

/////////////////////////////////////
// IntegerColumn
/////////////////////////////////////
lh.IntegerColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.IntegerColumn.prototype = new lh.Column;

/////////////////////////////////////
// TextareaColumn
/////////////////////////////////////
lh.TextareaColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.TextareaColumn.prototype = {
	render: function(){}, 
	setValue: function(/*Object*/value){
		if (getEl(this.fieldId + "_workArea") != undefined) {
			getEl(this.fieldId).value = value;
			//need to delay for it to work in Firefox
			setTimeout("xInitField(\"" + this.fieldId + "\",\"" + dojo.string.escapeJavaScript(value) + "\")",1000);
		} else {
			getEl(this.fieldId).value = getEl(this.fieldId).defaultValue = value;
		}
	},
	getValue: function(){
		return getEl(this.fieldId).value;
	},
	validate: function(){
		return true;
	}	
}

/////////////////////////////////////
// CheckboxColumn
/////////////////////////////////////
lh.CheckboxColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.CheckboxColumn.prototype = {
	render: function(){}, 
	setValue: function(/*Object*/value){
		getEl(this.fieldId).checked = getEl(this.fieldId).defaultChecked = (value == this.ONDISPLAYVALUE);
	},
	getValue: function(){
		return (getEl(this.fieldId).checked ? this.ONDISPLAYVALUE : this.OFFDISPLAYVALUE);
	},
	validate: function(){
		return true;
	}	
}

/////////////////////////////////////
// SelectColumn
/////////////////////////////////////
lh.SelectColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.SelectColumn.prototype = {
	render: function(){
	}, 
	setValue: function(/*Object*/value){
		selectValues(getEl(this.fieldId),value.split(","),true);
	},
	getValue: function(){
		return getSelectedText(getEl(this.fieldId)).join(", ");
	},
	validate: function(){
		if (cfBoolean(this.REQUIRED)) {
			return checkSelected(getEl(this.fieldId),this.DISPNAME);
		} else {
			return true;
		}
	},
	populateSelectList:function(fieldNameSuffix,selectedValues,synchValues) {
		childSelectObj = getEl(this.NAME + fieldNameSuffix);
		parentSelectObj = getEl(this.PARENTCOLUMN + fieldNameSuffix);
		if (parentSelectObj && getSelectedValues(parentSelectObj).length > 0) {
			synchValues = getSelectedValues(parentSelectObj);
		}
		this.availableValues = this.getAvailableValues(fieldNameSuffix, synchValues);
		populateSelectList(childSelectObj,this.availableValues,selectedValues);
		//If parent is required and is not selected, remind to select
		if (cfBoolean(this.Table.Columns[this.PARENTCOLUMN].REQUIRED) && synchValues.length == 0){
			childSelectObj.options.length = 1;
			childSelectObj.options[0].text = "--- Select " + this.Table.Columns[this.PARENTCOLUMN].DISPNAME + " First ---";
			childSelectObj.options[0].value = "";
			childSelectObj.disabled = true;
		} else if (childSelectObj.options.length == 1) {
			childSelectObj.options[0].text = "--- None Available ---";
			childSelectObj.options[0].value = "";
			childSelectObj.disabled = true;
		} else {
			if (childSelectObj.type != "select-multiple"){
				childSelectObj.options[0].text = "--- Select " + this.DISPNAME + " ---";
				childSelectObj.options[0].value = "";
			}
			childSelectObj.disabled = false;
		}
		//If column is required and only one option exists, select it
		if (cfBoolean(this.REQUIRED) && childSelectObj.options.length == 2){
			childSelectObj.selectedIndex = 1;
		}
		if (this.CHILDCOLUMN.length > 0 && this.populateChildSelectList && getEl(this.CHILDCOLUMN + fieldNameSuffix)){
			this.populateChildSelectList(fieldNameSuffix,childSelectObj);
		}
	},
	getAvailableValues: function(fieldNameSuffix, synchValues) {
		var parentColumnIds = synchValues.join(",");
	
		if (parentColumnIds.length > 0){
			var vals;
		    dojo.io.bind({
		        url: AppVirtualPath + "/Lighthouse/Components/Column.cfc?method=GetChildColumnValuesJson",
				content: {
					Auth: getEl(this.NAME + fieldNameSuffix + "_ChildColumnValuesAuthToken").value,
					Value: this.FKCOLNAME,
					Text: this.FKDESCR,
					Table: this.FKTABLE,
					Where: this.FKWHERE,
					ParentColumn: this.PARENTCOLUMN,
					ParentColumnCfSqlType: this.Table.Columns[this.PARENTCOLUMN].CFSQLTYPE,
					ParentColumnID: parentColumnIds,
					OrderBy: this.FKORDERBY
				},
		        load: function(type, q){
		            vals = q.DATA;
		        },
			    mimetype: "text/json",
				sync: true
		    });
			return vals;
		} else {
			return [];
		}
	},
	populateChildSelectList:function(fieldNameSuffix,parentSelectList) {
		var synchValues = getSelectedValues(parentSelectList);
		var childSelectList = getEl(this.CHILDCOLUMN + fieldNameSuffix);
		if (childSelectList) {
			selectedValues = getSelectedValues(childSelectList);
			this.Table.Columns[this.CHILDCOLUMN].populateSelectList(fieldNameSuffix,selectedValues,synchValues);
		} else {
			alert("The column " + this.Table.Columns[this.CHILDCOLUMN].DISPNAME + " is not available to update and so may be invalid.");
		}
	}
}

/////////////////////////////////////
// SelectMultipleColumn
/////////////////////////////////////
lh.SelectMultipleColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.SelectMultipleColumn.prototype = new lh.SelectColumn;

/////////////////////////////////////
// Select-Popup Column
/////////////////////////////////////
lh.SelectPopupColumn = function(props) {
	lh.Column.call(this,props);
}
lh.SelectPopupColumn.prototype = {
	render: function() {
		this.SelectWindow = null;
		this.DisplayTable = getEl(this.fieldId + "_table");
		this.SelectButton = getEl(this.fieldId + "_SelectButton");
		if (this.NAME != this.fieldId) {
			this.VIEWURL += "&" + this.NAME + "_FieldID=" + this.fieldId;
			this.POPUPURL += "&" + this.NAME + "_FieldID=" + this.fieldId;
		}
		this.DisplayTable.style.display = "none";
	
		//set functions for backward compatibility
		eval("window." + this.fieldId + "_add = function(pk,descr){return lh.Cells['" + this.fieldId + "'].add(pk,descr)}");
		eval("window." + this.fieldId + "_isSelected = function(pk){return lh.Cells['" + this.fieldId + "'].isSelected(pk)}");
		eval("window." + this.fieldId + "_getRow = function(pk){return lh.Cells['" + this.fieldId + "'].getRow(pk)}");
		eval("window." + this.fieldId + "_delete = function(pk){return lh.Cells['" + this.fieldId + "'].deleteRow(pk)}");
		eval("window." + this.fieldId + "_view = function(pk){return lh.Cells['" + this.fieldId + "'].view(pk)}");
		return this;
	},
	setValue: function(/*Array*/value){
		this.add(value[0],value[1]);
	},
	getValue: function(){
		return this.displayValue;
	},
	validate: function(){
		return true;
	},
	add: function(pk,descr) {
		//Make sure it's not already selected
		if (!this.isSelected(pk)) {
			if (this.DisplayTable.rows.length > 0) {
				this.DisplayTable.deleteRow(0);
			}
			var row = document.createElement("TR");
			row.setAttribute("rowID",pk);
			this.displayValue = descr;
			var rowObj = this.DisplayTable.appendChild(row);
			var cell1 = rowObj.appendChild(document.createElement("TD"));
			// Set contents of cells
			cell1.innerHTML = descr;
	
			// Delete button
			this.addButton(rowObj,"Delete","Delete " + descr,"function(){lh.Cells['" + this.fieldId + "'].deleteRow(" + pk + ")}");
			//View button
			if (this.VIEWURL.length > 0) {
				this.addButton(rowObj,"View","View " + descr,"function(){lh.Cells['" + this.fieldId + "'].viewRow(" + pk + ")}");
			}
			// Select new button
			this.addButton(rowObj,"Select","Select a different record","function(){lh.Cells['" + this.fieldId + "'].select()}");
	
			getEl(this.fieldId).value = pk;
			if (this.SelectWindow) {
				this.SelectWindow.close();
			}
			this.DisplayTable.style.display = "";
			this.SelectButton.style.display = "none";
		}
	},
	addButton: function(row,label,title,onclick) {
		var c = row.appendChild(document.createElement("TD"));
		c.className = "button";
		eval("c.onclick = " + onclick);
		c.innerHTML = label;
		c.title = title;
	},
	//Check to see if an item is already selected
	isSelected: function(pk) {
		var row = this.getRow(pk);
		return (row != null);
	},
	//Get row for an item
	getRow: function(pk) {
		var rows = getEl(this.fieldId + "_table").getElementsByTagName("TR");
		for (var r = 0; r < rows.length; r ++) {
			if (pk == rows[r].getAttribute("rowID")) {
				return rows[r];
			}
		}
		return null;
	},
	//Remove a row
	deleteRow: function(pk) {
		row = this.getRow(pk)
		row.parentNode.removeChild(row);
		getEl(this.fieldId).value = "";
		this.DisplayTable.style.display = "none";
		this.SelectButton.style.display = "";
	},
	//Select
	select: function() {
		this.SelectWindow = popupDialog(this.fieldId,700,500,"resizable=1,scrollbars=1",this.POPUPURL);
	},
	//View
	viewRow: function(pk) {
		this.SelectWindow = popupDialog(this.fieldId,700,500,"resizable=1,scrollbars=1",this.VIEWURL.replace(/#pk#/,pk));
	}
}
/////////////////////////////////////
// DateColumn
/////////////////////////////////////
lh.DateColumn = function(/*Object*/props) {
	lh.Column.call(this,props);
}
lh.DateColumn.prototype = {
	render: function(){}, 
	setValue: function(/*Object*/value){
		var d;
		if (cfBoolean(this.SHOWDATE)) {
			d = new Date(value);
			if(!isNaN(d.getMonth())) getEl(this.fieldId).value = (d.getMonth()+1)+"/"+d.getDate()+"/"+d.getFullYear();
		}
		if (cfBoolean(this.SHOWTIME)) {
			if (!cfBoolean(this.SHOWDATE)) {
				d = new Date(new Date().toLocaleDateString() + " " + value)
			}
			if(!isNaN(d.getHours())&&(d.getHours()>0||d.getMinutes>0)) {
				getEl(this.fieldId+"_Hour").value = dojo.string.padLeft(d.getHours()%12==0?"12":d.getHours()%12,2);
				getEl(this.fieldId+"_Minute").value = dojo.string.padLeft(d.getMinutes(),2);
				getEl(this.fieldId+"_AMPM").selectedIndex = d.getHours()<12?0:1;
			}
		}
	},
	getValue: function(){
		var value = "";
		if (cfBoolean(this.SHOWDATE)) {
			value = getEl(this.fieldId).value;
		}
		if (cfBoolean(this.SHOWTIME)) {
			var hour = getEl(this.fieldId+"_Hour").value;
			var minute = getEl(this.fieldId+"_Minute").value;
			var ampm = getEl(this.fieldId+"_AMPM");
			if (hour!=""||minute!=""){
				value += " " + (hour==""?"00":hour);
				value += ":" + (minute==""?"00":minute);
				value += " " + ampm.options[ampm.selectedIndex].value;
			}
		}
		return value;
	},
	validate: function(){
		return true;
	}
}
/////////////////////////////////////
// File Column
/////////////////////////////////////
lh.FileColumn = function(props) {
	lh.Column.call(this,props);
}
lh.FileColumn.prototype = {
	render: function() {
		this.InputField = getEl(this.fieldId);
		this.FileBrowserLink = getEl(this.fieldId + "_FileBrowserLink");
		this.OldFileField = getEl(this.fieldId + "_OldFile");
		this.CurrentFileDisplay = getEl(this.fieldId + "_CurrentFileDisplay");
		this.CurrentFileLink = getEl(this.fieldId + "_Link");
		this.DeleteCheckbox = getEl(this.fieldId + "_Delete");
			
		this.InputField.Column = this;
		this.InputField.onchange = function(){
			if (this.value.length > 0) this.Column.DeleteCheckbox.checked = true;
		}
			
		if (cfBoolean(this.SHOWFILEBROWSER)) {
			this.FileBrowserLink.Column = this;
			this.FileBrowserLink.target = "filebrowser"; 
			this.FileBrowserLink.onclick = function() {
				dialogParams = new Array();
				dialogParams.fileColumn = this.Column;  
				var filebrowserWin = popupDialog("filebrowser",750,550,"resizable=1,scrollbars=1,status=1");
				filebrowserWin.location.href = MCFResourcesPath + "/dialogs/fileBrowser.cfm?uploadDir=" + encodeURIComponent(this.Column.DIRECTORY);
			}
		} else {
			this.FileBrowserLink.style.display = "none";
		}
		this.setValue("");
		return this;
	},
	setValue: function(value){
		this.OldFileField.value = value;
		this.CurrentFileLink.href = "/" + this.DIRECTORY + "/" + value;
		this.CurrentFileLink.innerHTML = value;
		this.CurrentFileDisplay.style.display = (value==""?"none":"");
	},
	getValue: function(value){
		var value = (getEl(this.fieldId).value == "" ? getEl(this.fieldId + "_OldFile").value : getEl(this.fieldId).value);
		if (getEl(this.fieldId).value != "") {
			return getEl(this.fieldId).value;
		} else if (getEl(this.fieldId + "_OldFile").value != "") {
			return "<a href=\"" + getEl(this.fieldId + "_Link").href + "\" target=_blank>" + getEl(this.fieldId + "_OldFile").value + "</a>";
		} else {
			return "";
		}
	},
	validate: function(){
		return true;
	}	
}