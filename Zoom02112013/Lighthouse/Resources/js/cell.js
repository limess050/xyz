/////////////////////////////////////
// Cell
/////////////////////////////////////
lh.Cell = function(/*Row*/row,/*Column*/column,/*String*/fieldId) {
	//The cell adopts all the properties of its column, and adds properties to determine the row
	dojo.lang.mixin(this,column);
	this.Row = row;
	this.fieldId = fieldId;
	lh.Cells[fieldId] = this;
}
lh.Cell.prototype = {
	turnOffEdit: function(){
		this.htmlViewCell.innerHTML = this.getValue();
		this.htmlViewCell.style.display = "";
		this.htmlEditCell.style.display = "none";
		this.htmlCell.className = "childtableeditdisplay";
	},
	turnOnEdit: function(){
		this.htmlViewCell.style.display = "none";
		this.htmlEditCell.style.display = "";
		this.htmlCell.className = "childtableedit";
	}	
}