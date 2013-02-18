/////////////////////////////////////
// Lighthouse objects
// Meant to work together with CFC's of the same name.
/////////////////////////////////////

lh.getPage = function(pageID){
	var p;	
	dojo.io.bind({
	    url: AppVirtualPath+"/Lighthouse/Admin/rpc.cfm?object=Page&method=GetWorkingPage&pageID="+pageID,
	    load: function(type, evaldObj){
	    	p = new lh.Page(evaldObj[0]);
	    },
	    mimetype: "text/json-comment-filtered",
		sync:true
	});
	return p;
}
lh.Page = function(props) {
    for(prop in props){this[prop]=props[prop];}
	
	this.titleDisplay = this.title=""?this.navtitle:this.title;
	if (this.templatename=="") this.templatename = "Default";
}
lh.Page.prototype = {
	update:function(){
		dojo.io.bind({
			url:AppVirtualPath+"/Lighthouse/Admin/rpc.cfm?object=Page&method=Update",
			load:function(type, evaldObj){
				if (!evaldObj) {
					alert("Error updating page.")
				}
			},
			formNode:getEl("pageInfo"),
			mimetype:"text/json-comment-filtered"
		});
	}
};
