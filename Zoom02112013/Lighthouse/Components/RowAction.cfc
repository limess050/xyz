<cfcomponent name="RowAction" hint="Defines an action that can be performed on a row.">

	<cfinclude template="../Functions/LighthouseLib.cfm">

	<cffunction name="Init" description="Instantiate a row action." output="false" returntype="RowAction">
		<cfargument name="Properties" required="true" type="struct">
		<cfargument name="Table" required="true" type="struct">

		<cfscript>
		This.Name = Properties.ActionName;

		if (Not StructKeyExists(Table.RowActions,This.Name)) {
			ArrayAppend(Table.RowActionOrder,This.Name);
		}
		Table.RowActions[This.Name] = This;
	
		This.Type = GetProperty(Properties,"Type",This.Name);
		This.Label = GetProperty(Properties,"Label",This.Name);
		if (Not StructKeyExists(Properties,"ConditionalParam")) {
			if (This.Type is "Select") {
				This.ConditionalParam = "Select";
			} else {
				This.ConditionalParam = "";
			}
		} else {
			This.ConditionalParam = Properties.ConditionalParam;
		}
		This.Layout = GetProperty(Properties,"Layout","");
		This.Target = GetProperty(Properties,"Target","");

	
		if (Len(This.ConditionalParam)) {
			if (StructKeyExists(url,This.ConditionalParam)) {
				Table.persistentParams = addQueryParam(Table.persistentParams,This.ConditionalParam,"Yes");
			}
		}
		switch (This.Type) {
			case "Select": {
				This.ColName = GetProperty(Properties,"ColName","");
				
				if (StructKeyExists(url,"#Properties.ColName#_FieldID")) {
					This.FieldID = url["#Properties.ColName#_FieldID"];
					Table.persistentParams = addQueryParam(Table.persistentParams,"#Properties.ColName#_FieldID",url["#Properties.ColName#_FieldID"]);
				} else {
					This.FieldID = This.ColName;
				}
				
				This.JSFunction = GetProperty(Properties,"JSFunction","opener.#This.FieldID#_add");
				This.Descr = GetProperty(Properties,"Descr","");
				This.DescrColName = "Action_#This.Name#_Descr";
	
				// record special column that must be returned
				SpecialColumn = StructNew();
				SpecialColumn.Name = This.DescrColName;
				SpecialColumn.Expression = This.Descr;
				ArrayAppend(Table.SpecialColumns,SpecialColumn);
	
				break;
			}
			case "Custom": {
				This.Href = GetProperty(Properties,"Href","");
				This.OnClick = GetProperty(Properties,"OnClick","");
				This.RequiredColumns = GetProperty(Properties,"RequiredColumns","");
				This.Condition = GetProperty(Properties,"Condition","");
	
				for (i = 1; i lte ListLen(This.RequiredColumns); i = i + 1) {
					column = ListGetAt(This.RequiredColumns,i);
					// record special column that must be returned
					SpecialColumn = StructNew();
					SpecialColumn.Name = Replace(column,".","_") & "_SpecialColumn";
					This.Href = Replace(This.Href,"###column###","###SpecialColumn.Name###","ALL");
					This.OnClick = Replace(This.OnClick,"###column###","###SpecialColumn.Name###","ALL");
					This.Condition = Replace(This.Condition,"#column#","#SpecialColumn.Name#","ALL");
					SpecialColumn.Expression = column;
					ArrayAppend(Table.SpecialColumns,SpecialColumn);
				}
				break;
			}
		}
		</cfscript>		
		<cfreturn This>
	</cffunction>

</cfcomponent>