/////////////////////////////////////
// Row
/////////////////////////////////////
lh.Row = function(/*Table*/table) {
	this.id = table.nextId;
	table.nextId++; 
	this.Table = table;
	table.Rows.push(this);
	this.Cells = new Array();
	lh.Rows[table.NAME + "_" + this.id] = this;
}
lh.Row.prototype = {
	addCell: function(/*String*/columnName,/*String*/fieldId){
		var column = this.Table.Columns[columnName];
		if (fieldId == null) fieldId = columnName;
		var cell = new lh.Cell(this,column,fieldId);
		this.Cells[this.Cells.length] = cell; 
		return cell; 
	},
	getCell: function(/*String*/columnName){
		for (var i=0;i<this.Cells.length;i++){
			if (this.Cells[i].Column.NAME == columnName) {
				return this.Cells[i];
				break; 
			}
		}
	},
	render: function (values) {
		var r = this;
		var t = this.Table;
		var htmlTable = getEl(t.NAME + "_Table");
		var htmlTbody = htmlTable.getElementsByTagName("TBODY")[0];
		this.htmlRow = document.createElement("TR");
		this.htmlRow.id = t.NAME + "_" + this.id; 
		htmlTbody.appendChild(this.htmlRow);
		var pkCol,pkVal;
		var dnImg = "<img src=\"" + MCFResourcesPath + "/images/arrowdn.gif\" alt=\"Move Down\" border=0>";
		var upImg = "<img src=\"" + MCFResourcesPath + "/images/arrowup.gif\" alt=\"Move Up\" border=0>";
		
		//render columns
		for (var i=0; i<t.COLUMNORDER.length; i++) {
			var col = t.Columns[t.COLUMNORDER[i]];
			if (cfBoolean(col.PRIMARYKEY)){
				pkCol = col;
				if (values != null) {
					pkVal = values[i];	
				}else{
					pkVal = "";
				}
			} else {
				var template = getEl(t.NAME + "_" + col.NAME + "_Template");
				if (template) {
					var c = this.addCell(col.NAME,t.NAME + "_" + col.NAME + "_" + this.id);
					c.htmlCell = document.createElement("TD");
					c.htmlCell.className = "childtableedit";
					this.htmlRow.appendChild(c.htmlCell);
					c.htmlEditCell = c.htmlCell.appendChild(document.createElement("div"));
					c.htmlViewCell = c.htmlCell.appendChild(document.createElement("div"));
					c.htmlEditCell.innerHTML = template.innerHTML.replace(/_0/g,"_" + this.id);
					c.render();
					if (values != null) {
						c.setValue(values[i]);
					} else if (c.TYPE.toLowerCase() == "textarea" && getEl(c.fieldId + "_workArea") != undefined) {
						//initialize blank wysiwyg field.  Pause for a second to prevent problems in Firefox
						setTimeout("xInitField(\"" + c.fieldId + "\",\"\")",1000);
					} else if (c.TYPE.toLowerCase() == "select-popup") {
						if (cfBoolean(c.AUTOSELECT)) {
							c.select();
						}
					}
				}
			}
		}
		var btnCell = this.htmlRow.appendChild(document.createElement("TD"));
		var btnTbl = btnCell.appendChild(document.createElement("TABLE"));
		var btnBdy = btnTbl.appendChild(document.createElement("TBODY"));
		var btnTr = btnBdy.appendChild(document.createElement("TR"));
		this.btnParent = btnTr;
	
	    this.addHiddenField(t.NAME + "_rowIds",r.id);
		if (t.ORDERCOLUMN && t.ORDERCOLUMN.length > 0) {
		    this.OrderField = this.addHiddenField(t.NAME + "_" + t.ORDERCOLUMN + "_" + r.id,"");
			this.MoveDownButton = r.addButton(dnImg,function(){r.moveDown();});
			this.MoveUpButton = r.addButton(upImg,function(){r.moveUp();});
		}
		if (pkCol){
			this.addHiddenField(t.NAME + "_" + pkCol.NAME + "_" + r.id,pkVal);
		}
	
		htmlTable.style.display = "";
		//Buttons
		if (!cfBoolean(t.EDITBYDEFAULT)) {
			this.StopEditButton = this.addButton("Stop&nbsp;Edit",function(){r.turnOffEdit();});
			this.EditButton = this.addButton("Edit",function(){r.turnOnEdit();});
			this.EditButton.style.display = "none";
			if (values != null) {
				this.turnOffEdit();
			}
		}
		this.addButton("Remove",function(){r.deleteRow();});
		t.setOrder();
	},
	deleteRow: function() {
		if (confirm("Are you sure you want to delete this record?")) {
			var tbody = this.htmlRow.parentNode;
			if (getEl(this.htmlRow.id + "_display")) {
				tbody.removeChild(getEl(this.htmlRow.id + "_display"));
			}
			tbody.removeChild(this.htmlRow);
	        this.Table.Rows.splice(this.Table.getRowIndex(this.id),1);
			if (tbody.getElementsByTagName("TR").length == 0) {
				tbody.parentNode.style.display = "none";
			}
			this.Table.setOrder();
		}
	},
	addHiddenField: function(name,value) {
	    var hdn = document.createElement("INPUT")
	    hdn.type = "hidden";
	    hdn.name = name;
	    hdn.value = value;
		this.htmlRow.cells[0].appendChild(hdn);
		return hdn;
	},
	addButton: function(label,action,id) {
		//if id provided, check to see if button already exists
		var btn;
		if (id != null) btn = getEl(id);
		if (btn == null) {
			btn = document.createElement("TD");
			btn.id = id;
			btn.className = "button";
			btn.innerHTML = label;
			btn.onclick = action;
			this.btnParent.appendChild(btn);
		}
		return btn;
	},
	moveUp: function() {
	    this.setDefaultChecked(this.htmlRow);
	    moveObjUp(this.htmlRow);
	    var i = this.Table.getRowIndex(this.id);
	    this.Table.Rows.splice(i,1);
	    this.Table.Rows.splice(i-1,0,this);
	    this.Table.setOrder();
	},
	moveDown: function() {
	    this.setDefaultChecked(this.htmlRow.nextSibling);
	    moveObjDown(this.htmlRow);
	    var i = this.Table.getRowIndex(this.id);
	    this.Table.Rows.splice(i,1);
	    this.Table.Rows.splice(i+1,0,this);
	    this.Table.setOrder();
	},
	setDefaultChecked: function(htmlRow) {
	    // Set defaultChecked attribute for checkboxes.  This is necessary to not lose checked state when rows are moved
	    var inputs = htmlRow.getElementsByTagName("input");
	    for (var i = 0; i < inputs.length; i ++) inputs[i].defaultChecked = inputs[i].checked;
	},
	turnOffEdit: function() {
		for (var i=0;i<this.Cells.length;i++){
			this.Cells[i].turnOffEdit();
		}
		this.StopEditButton.style.display = "none";
		this.EditButton.style.display = "";
	},
	turnOnEdit: function() {
		for (var i=0;i<this.Cells.length;i++){
			this.Cells[i].turnOnEdit();
		}
		this.StopEditButton.style.display = "";
		this.EditButton.style.display = "none";
	}	
}