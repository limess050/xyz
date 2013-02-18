/////////////////////////////////////
// Table
/////////////////////////////////////
lh.Table = function(/*Object*/props) {
	dojo.lang.mixin(this,props);
	this.Columns = new Object();
	this.Tables = new Object();
	this.Rows = new Array();
	if ("COLUMNS" in this) {
		for (colName in this.COLUMNS){
			this.addColumn(this.COLUMNS[colName]);
		}
	}
	lh.Tables[this.NAME] = this;
	this.nextId = 1;
}
lh.Table.prototype = {
	addColumn: function(/*Object*/props){
		props.Table = this;
		switch (props.TYPE.toLowerCase()) {
			case "childtable":
				this.Tables[props.NAME] = new lh.Table(props); 
				break;
			case "text":
				this.Columns[props.NAME] = new lh.TextColumn(props);
				break;
			case "integer":
				this.Columns[props.NAME] = new lh.IntegerColumn(props);
				break;
			case "checkbox":
				this.Columns[props.NAME] = new lh.CheckboxColumn(props);
				break;
			case "checkbox":
				this.Columns[props.NAME] = new lh.CheckboxColumn(props);
				break;
			case "select-popup":
				this.Columns[props.NAME] = new lh.SelectPopupColumn(props);
				break;
			case "file":
				this.Columns[props.NAME] = new lh.FileColumn(props);
				break;
			case "select":
				this.Columns[props.NAME] = new lh.SelectColumn(props);
				break;
			case "date":
				this.Columns[props.NAME] = new lh.DateColumn(props);
				break;
			case "textarea":
				this.Columns[props.NAME] = new lh.TextareaColumn(props);
				break;
			case "select-multiple":
				this.Columns[props.NAME] = new lh.SelectMultipleColumn(props);
				break;
			default:
				this.Columns[props.NAME] = new lh.Column(props);
				break;
		}
		return this.Columns[props.NAME]; 
	},
	addRow: function(){
		return new lh.Row(this); 
	},
	// Get row index
	getRowIndex: function(id) {
	    for (var i=0;i<this.Rows.length;i++){
	        if (this.Rows[i].id == id) {
	            return i;
	            break;
	        }
	    }
	    return -1;
	},

	setOrder: function() {
		if (this.ORDERCOLUMN && this.ORDERCOLUMN.length > 0) {
			var orderNum = 0;
			var dn,up = null;
			for (var i=0; i<this.Rows.length; i++) {
				orderNum++;
				var r = this.Rows[i];
				r.OrderField.value = orderNum;
				r.MoveUpButton.style.visibility = (i==0?"hidden":"visible");
				r.MoveDownButton.style.visibility = (i==this.Rows.length-1?"hidden":"visible");
			}
		}
	},
	
	validate: function(){
		var row,cell;
		var valid = true;
		if (this.Rows.length > 0){
			for (var r=0;r<this.Rows.length;r++){
				row = this.Rows[r];
				for (var c=0;c<row.Cells.length;c++){
					cell = row.Cells[c];
					if ("validate" in cell){
						valid = cell.validate();
						if (!valid) return valid;
					}
				}
			}
		} else {
			if (cfBoolean(this.REQUIRED)){
				alert("You did not enter any values into the \"" + this.DISPNAME + "\" field. This is a required field. Please enter one now.")
				return false;
			}
		}
		return valid;
	},
	
	getValue: function(){
		var values = [];
		for (var r=0;r<this.Rows.length;r++){
			values[r] = new Object();
			for (var c=0;c<this.Rows[r].Cells.length;c++){
				var cell = this.Rows[r].Cells[c];
				if (cfBoolean(cell.EDITABLE)){
					values[r][cell.NAME] = cell.getValue();
				}
			}
		}
		return dojo.json.serialize(values);
	},
	
	monitorColumns: function(/*lh.ChangeMonitor*/monitor){
		for (var c=0;c<this.COLUMNORDER.length;c++){
			var col = this.Columns[this.COLUMNORDER[c]];
			if (col && cfBoolean(col.EDITABLE)){
				//TODO: Set up all column types to create cell objects.
				if (col.NAME in lh.Cells){
					monitor.addField("lh.Cells['" + col.NAME + "'].getValue();",{name:col.DISPNAME});
				} else {
					col.fieldId = col.NAME;
					monitor.addField("lh.Columns['" + col.NAME + "'].getValue();",{name:col.DISPNAME});
				}
			} else {
				var t = this.Tables[this.COLUMNORDER[c]];
				if (t){
					monitor.addField("lh.Tables['" + t.NAME + "'].getValue();",{name:t.DISPNAME});
				}
			}
		}
	}	
}