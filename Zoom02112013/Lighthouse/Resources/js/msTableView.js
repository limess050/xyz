///////////////////////////////////////////////////////////////
// File Name: 	msTableView.js
// Javascript specific to MS_TableView.cfm
///////////////////////////////////////////////////////////////

/////////////////////////////////////
// Note that Lighthouse automatically sets the following javascript variables to make
// them available to functions:
// MCFResourcesPath
/////////////////////////////////////

function showColumnMenu(sourceElement) {
	var colName = sourceElement.getAttribute("colName");
	var dm = new dhtmlMenu(colName + "_contextMenu");
	if (!dm.exists()) {
		var items = new Array();
		var label, href, token, thisOrderBy, newOrderBy, re;

		//Orderby
		thisOrderBy = sourceElement.getAttribute("orderBy");
		if (thisOrderBy != "") {
			newOrderBy = orderBy;
			newOrderBy = newOrderBy.replace(new RegExp(reEscape(thisOrderBy) + " desc","gi"),"");
			newOrderBy = newOrderBy.replace(new RegExp(reEscape(thisOrderBy) + "($|,)","gi"),"$1");
			newOrderBy = newOrderBy.replace(/,,/g,",");
			newOrderBy = newOrderBy.replace(/^,|,$/g,"");
			if (newOrderBy.length > 0) newOrderBy = "," + newOrderBy;

			re = new RegExp("^" + reEscape(thisOrderBy) + "($|,)","gi");
			if (orderBy.search(re) == -1) {
				items[items.length] = new dhtmlMenuItem("link","Sort Ascending",orderByUrl + "&orderBy=" + encodeURIComponent(thisOrderBy + newOrderBy),MCFResourcesPath + "/images/arrowdn.gif");
			}

			re = new RegExp("^" + reEscape(thisOrderBy) + " desc" + "($|,)","gi");
			if (orderBy.search(re) == -1) {
				items[items.length] = new dhtmlMenuItem("link","Sort Descending",orderByUrl + "&orderBy=" + encodeURIComponent(thisOrderBy + " desc" + newOrderBy),MCFResourcesPath + "/images/arrowup.gif");
			}
		}

		//Column Edit
		if (sourceElement.getAttribute("editable") == 1) {
			token = "&" + colName + "_editCol=1";
			if (actionURL.indexOf(token) > -1) {
				label = "Stop Editing Column";
				href = replace(actionURL,token,"");
			} else {
				label = "Edit Column";
				href = actionURL + token;
			}
			items[items.length] = new dhtmlMenuItem("link",label,href);
		}

		//Hide Column
		newActionURL = removeQueryParam(actionURL,"lh_ViewColumns") + "&lh_ViewColumns=" + encodeURIComponent(listRemove(columnList,colName))
		items[items.length] = new dhtmlMenuItem("link","Hide Column",newActionURL);

		//Move Column
		if (!isLastColumn(colName)) {
			newActionURL = removeQueryParam(actionURL,"lh_ColumnOrder") + "&lh_ColumnOrder=" + encodeURIComponent(shiftColumn(colName,1))
			items[items.length] = new dhtmlMenuItem("link","Move Column Right",newActionURL);
		}
		if (!isFirstColumn(colName)) {
			newActionURL = removeQueryParam(actionURL,"lh_ColumnOrder") + "&lh_ColumnOrder=" + encodeURIComponent(shiftColumn(colName,-1))
			items[items.length] = new dhtmlMenuItem("link","Move Column Left",newActionURL);
		}
		dm.create(items);
	}
	var params = new Array();
	dm.toggleShow("underElement",sourceElement);
}
function hideColumnMenu(sourceElement) {
	var colName = sourceElement.getAttribute("colName");
	var dm = new dhtmlMenu(colName + "_contextMenu");
	dm.hide();
}


function shiftColumn(colName,increment) {
	var tempColumns = columns.concat();
	// Get index of column
	var oldIndex,newIndex;
	for (var i = 0; i < tempColumns.length; i ++) {
		if (colName == tempColumns[i][0]) {
			oldIndex = i;
			break;
		}
	}
	// Get new Index
	if (increment == 1) {
		for (var i = oldIndex + 1; i < tempColumns.length; i ++) {
			if (tempColumns[i][2]) {
				newIndex = i;
				break;
			}
		}
	} else {
		for (var i = oldIndex - 1; i > -1; i --) {
			if (tempColumns[i][2]) {
				newIndex = i;
				break;
			}
		}
	}
	tempArray = tempColumns[oldIndex];
	tempColumns[oldIndex] = tempColumns[newIndex];
	tempColumns[newIndex] = tempArray;
	return getColumnOrderList(tempColumns);
}
function getColumnOrderList(tempColumns) {
	var columnOrderList = tempColumns[0][0];
	for (var i = 1; i < tempColumns.length; i ++) {
		columnOrderList += "," + tempColumns[i][0];
	}
	return columnOrderList;
}
function isFirstColumn(colName) {
	for (var i = 0; i < columns.length; i ++) {
		if (colName == columns[i][0]) {
			return true;
			break;
		} else if (columns[i][2]) {
			return false;
			break;
		}
	}
}
function isLastColumn(colName) {
	for (var i = columns.length - 1; i > -1; i --) {
		if (colName == columns[i][0]) {
			return true;
			break;
		} else if (columns[i][2]) {
			return false;
			break;
		}
	}
}


function showAddColumnMenu(sourceElement) {
	var dm = new dhtmlMenu("AddColumnsMenu");
	if (!dm.exists()) {
		var items = new Array();
		var label, href, re;
		for (var i = 0; i < columns.length; i ++) {
			var colName = columns[i][0];
			if (!listFind(columnList,colName)) {
				newActionURL = removeQueryParam(actionURL,"lh_ViewColumns") + "&lh_ViewColumns=" + encodeURIComponent(columnList + "," + colName)
				items[items.length] = new dhtmlMenuItem("link","Add " + columns[i][1] + " Column",newActionURL);
			}
		}
		if (items.length == 0) {
			items[0] = new dhtmlMenuItem("link","No More Columns Available","javascript:voide(0);");
		}
		dm.create(items);
	}
	dm.toggleShow("underElement",sourceElement)
}
function hideAddColumnMenu(sourceElement) {
	var dm = new dhtmlMenu("AddColumnsMenu");
	dm.hide();
}
