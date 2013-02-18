//Create Lighthouse namespace
lh = new Object(); 
lh.Tables = new Object();
lh.Rows = new Object();
lh.Columns = new Object();
lh.Cells = new Object();

lh.addTable = function(/*Object*/props){
	lh.Tables[props.ID] = new lh.Table(props);
	return lh.Tables[props.ID]
}

//Change Monitor
lh.ChangeMonitor = function(/*Function*/listener){
	this.listener = listener;
	this.Fields = [];
	this.ChangedFields = [];
	this.timeout = null;
	this.isStarted = false;
}
lh.ChangeMonitor.prototype = {
	addField:function(/*String*/propName,/*Object*/props){
		props.propName = propName;
		this.Fields.push(new lh.ChangeMonitorField(props));
	},
	hasField:function(/*String*/propName){
		for (var i=0;i<this.Fields.length;i++){
			if (this.Fields[i].propName == propName){
				return true;
			}
		}
		return false;
	},
	start:function(){
		for (var i=0;i<this.Fields.length;i++){
			this.Fields[i].init();
		}
		if (!this.isStarted){
			this.timeout = setInterval(this.listener,1000);
			this.isStarted = true;
		}
	},
	stop:function(){
		if (this.timeout != null){
			clearInterval(this.timeout);
		}
		this.isStarted = false;
	},
	isChanged:function(){
		if (this.isStarted){
			this.ChangedFields = [];
			for (var i=0;i<this.Fields.length;i++){
				if (this.Fields[i].isChanged()){
					this.ChangedFields.push(this.Fields[i]);
				}
			}
			return (this.ChangedFields.length>0);
		} else {
			return false;
		}
	}	
}
lh.ChangeMonitorField = function(/*Object*/props){
    for (prop in props){this[prop]=props[prop];}
}
lh.ChangeMonitorField.prototype = {
	init: function(){
		try{
			this.baseValue = eval(this.propName);
			this.currentValue = this.baseValue;
		} catch (e){
			console.warn(this.propName + ": " + e.message);
		}
	},
	isChanged:function(){
		try{
			this.currentValue = eval(this.propName);
		} catch (e){
			//console.warn(e.message);
		}
		return (this.baseValue!=this.currentValue);
	}
}

//Show a popup calendar widget next to an input field
lh.ShowPopupCalendar = function(/*Element*/input, format){
	if (format == null) {
		format = "M/d/yyyy";
	} else {
		format = format.replace(/D/g,"d");
		format = format.replace(/m/g,"M");
		format = format.replace(/Y/g,"y");
	}
	console.log(format);
	var x = _totalOffsetLeft(input) + input.offsetWidth;
	var y = _totalOffsetTop(input);
	var pop = dojo.widget.createWidget("PopupContainer",{toggle:"fade",toggleDuration:200});
	var cal = dojo.widget.createWidget("DatePicker",{value:"today"});
	pop.domNode.appendChild(cal.domNode);
	pop.open(x,y,document.body);
	if (input.value.length>0)cal.setDate(dojo.date.parse(input.value,{datePattern:format,selector:"dateOnly"}));
	dojo.event.connect(cal,"onValueChanged",function(){
		input.value=dojo.date.format(cal.value,{datePattern:format,selector:"dateOnly"});
		pop.close(true);
	})
}

//Dynamically load a stylesheet in a page.
lh.LoadStylesheet = function(/*document*/doc,/*String*/url){
	var lnk = document.createElement('link');
	lnk.type = "text/css";
	lnk.rel = "stylesheet";
	lnk.href = url;
	doc.getElementsByTagName("head")[0].appendChild(lnk);	
}

//Get a client setting
lh.GetSetting = function(/*String*/setting,/*Function*/loadFunction){
	dojo.io.bind({
		url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=GetSetting&setting=" + encodeURIComponent(setting),
	    load:loadFunction,
	    mimetype: "text/json-comment-filtered"
	});
}

//Save a client setting 
lh.SaveSetting = function(/*String*/setting,/*String*/data){
	dojo.io.bind({
		url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=SaveSetting&setting=" + encodeURIComponent(setting) + "&data=" + encodeURIComponent(data),
	    mimetype: "text/json-comment-filtered"
	});
}