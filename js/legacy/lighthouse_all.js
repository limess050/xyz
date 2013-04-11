//All Lighthouse javascript files minified using CFJSMin and combined

//firebug/firebugx.js
if(!("console"in window)||!("firebug"in console))
{var names=["log","debug","info","warn","error","assert","dir","dirxml","group","groupEnd","time","timeEnd","count","trace","profile","profileEnd"];window.console={};for(var i=0;i<names.length;++i)
window.console[names[i]]=function(){}}

//Resources/js/lighthouse.js
lh=new Object();lh.Tables=new Object();lh.Rows=new Object();lh.Columns=new Object();lh.Cells=new Object();lh.addTable=function(props){lh.Tables[props.ID]=new lh.Table(props);return lh.Tables[props.ID]}
lh.ChangeMonitor=function(listener){this.listener=listener;this.Fields=[];this.ChangedFields=[];this.timeout=null;this.isStarted=false;}
lh.ChangeMonitor.prototype={addField:function(propName,props){props.propName=propName;this.Fields.push(new lh.ChangeMonitorField(props));},hasField:function(propName){for(var i=0;i<this.Fields.length;i++){if(this.Fields[i].propName==propName){return true;}}
return false;},start:function(){for(var i=0;i<this.Fields.length;i++){this.Fields[i].init();}
if(!this.isStarted){this.timeout=setInterval(this.listener,1000);this.isStarted=true;}},stop:function(){if(this.timeout!=null){clearInterval(this.timeout);}
this.isStarted=false;},isChanged:function(){if(this.isStarted){this.ChangedFields=[];for(var i=0;i<this.Fields.length;i++){if(this.Fields[i].isChanged()){this.ChangedFields.push(this.Fields[i]);}}
return(this.ChangedFields.length>0);}else{return false;}}}
lh.ChangeMonitorField=function(props){for(prop in props){this[prop]=props[prop];}}
lh.ChangeMonitorField.prototype={init:function(){try{this.baseValue=eval(this.propName);this.currentValue=this.baseValue;}catch(e){console.warn(this.propName+": "+e.message);}},isChanged:function(){try{this.currentValue=eval(this.propName);}catch(e){}
return(this.baseValue!=this.currentValue);}}
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
lh.LoadStylesheet=function(doc,url){var lnk=document.createElement('link');lnk.type="text/css";lnk.rel="stylesheet";lnk.href=url;doc.getElementsByTagName("head")[0].appendChild(lnk);}
lh.GetSetting=function(setting,loadFunction){dojo.io.bind({url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=GetSetting&setting="+encodeURIComponent(setting),load:loadFunction,mimetype:"text/json-comment-filtered"});}
lh.SaveSetting=function(setting,data){dojo.io.bind({url:AppVirtualPath+"/Lighthouse/Components/User.cfc?method=SaveSetting&setting="+encodeURIComponent(setting)+"&data="+encodeURIComponent(data),mimetype:"text/json-comment-filtered"});}

//Resources/js/library.js
function popupWindow(windowName,width,height){eval("var "+windowName+" = window.open('','"+windowName+"','width="+width+",height="+height+",resizable=1,scrollbars=1')");eval(windowName+".focus()");return eval(windowName);}
function popupWindow2(windowName,options){eval("var "+windowName+" = window.open('','"+windowName+"','"+options+"')");eval(windowName+".focus()");return eval(windowName);}
function popupDialog(windowName,width,height,options,url){if(url==null)url="";if(options==null)options="status=no,toolbar=no,menubar=no,location=no";var top=(screen.availHeight-height)/2;var left=(screen.availWidth-width)/2;options="height="+height+",width="+width+",top="+top+",left="+left+","+options;eval("var "+windowName+" = window.open('"+url+"','"+windowName+"','"+options+"')");eval(windowName+".focus()");return eval(windowName);}
function upperCase(fieldObj){fieldObj.value=fieldObj.value.toUpperCase();}
function lowerCase(fieldObj){fieldObj.value=fieldObj.value.toLowerCase();}
function titleCase(fieldObj){words=fieldObj.value.split(" ");exceptions=",a,an,the,and,but,or,nor,so,to,as,at,by,for,from,in,into,of,on,onto,to,with,";for(var i=0;i<words.length;i++){if(i==0||exceptions.indexOf(","+words[i].toLowerCase()+",")==-1){firstLetterIndex=words[i].search(/\w/);words[i]=words[i].substring(0,firstLetterIndex+1).toUpperCase()+words[i].substring(firstLetterIndex+1,words[i].length).toLowerCase()}else{words[i]=words[i].toLowerCase();}}
fieldObj.value=words.join(" ");}
function stripHTML(s){s=s.replace(/<[^>]*>/g," ");s=s.replace(/&nbsp;/g," ");s=trim(s);return s;}
function trim(s){s=s.replace(/(^\s+|\s+$)/g,"");return s;}
function fillEmptyCells(){var tds=document.getElementsByTagName("TD");for(var i=0;i<tds.length;i++){if(tds[i].innerHTML.search(/[^\s]/)==-1){tds[i].innerHTML="&nbsp;";}}}
function setChecked(formObj,checked,pattern){if(pattern!=null)re=new RegExp("^"+pattern+"$","i");var e=formObj.elements;for(var i=0;i<e.length;i++){if(e[i].type=="checkbox"){if(pattern==null||e[i].id.search(re)!=-1){e[i].checked=checked;}}}}
function checkAll(checked,parentNodeId,pattern){var parentNode=document;if(parentNodeId!=null)parentNode=document.getElementById(parentNodeId);var checkboxes=parentNode.getElementsByTagName("INPUT");for(var i=0;i<checkboxes.length;i++){if(checkboxes[i].type=="checkbox"&&(pattern==null||(checkboxes[i].id&&checkboxes[i].id.search(pattern)>-1))){checkboxes[i].checked=checked;}}}
var zIndex=100;function showHide(obj,sh,position,el){if(obj){if(sh==null){if(obj.style.visibility=="hidden"){sh="show";}else{sh="hide";}}
if(position!=null){if(position=="rightOfElement"){obj.style.left=(_totalOffsetLeft(el)+el.offsetWidth)+"px";obj.style.top=_totalOffsetTop(el)+"px";}else if(position=="underElement"){obj.style.left=_totalOffsetLeft(el)+"px";obj.style.top=(_totalOffsetTop(el)+el.offsetHeight)+"px";}}
if(sh=="show"){_setSelectVisibility("hidden",obj);zIndex++;obj.style.zIndex=zIndex;obj.style.visibility="visible";}else{_setSelectVisibility("visible",obj);obj.style.visibility="hidden";}}}
function toggleDisplay(obj,sh,type){if(sh==null){if(obj.style.display!="none"){sh="hide";}else{sh="show";}}
if(type==null){type="inline";}
if(sh=="show"){obj.style.display="inline";}else{obj.style.display="none";}}
var dmTimeout=new Array();var dmTimeoutLength=500;function dhtmlMenu(id){this.id=id;}
dhtmlMenu.prototype.exists=function(){if(document.getElementById(this.id)){return true;}else{return false;}}
dhtmlMenu.prototype.create=function(items){if(this.exists()){document.body.removeChild(document.getElementById(this.id));}
var ul=document.createElement("UL");ul.id=this.id;ul.className="DHTMLMENU";ul.style.visibility="hidden";ul.style.position="absolute";ul.style.left="0px";ul.style.top="0px";for(var i=0;i<items.length;i++){var item=items[i];var li,a,label,img,input;li=document.createElement("LI");li.setAttribute("unselectable","on");li.setAttribute("menuID",this.id);li.onmouseover=dhtmlMenuItemMouseover;li.onmouseout=dhtmlMenuItemMouseout;ul.appendChild(li);switch(item.type){case"link":a=document.createElement("A");a.setAttribute("unselectable","on");li.appendChild(a);if(item.image!=null&&item.image!=""){img=document.createElement("IMG");img.setAttribute("unselectable","on");img.src=item.image;a.appendChild(img);}
a.href=item.href
a.innerHTML=a.innerHTML+item.label;if(a.href.indexOf("javascript:")==0){xAddEvent(a,"mouseover",top.cancelOnBeforeUnload);xAddEvent(a,"mouseout",top.setOnBeforeUnload);}
break;case"checkbox":input=document.createElement("INPUT");input.setAttribute("unselectable","on");input.type="checkbox";input.id=item.id;input.onclick=item.onclick;li.appendChild(input);label=document.createElement("LABEL");label.setAttribute("unselectable","on");label.htmlFor=item.id;label.innerHTML=item.label;li.appendChild(label);break;}}
document.body.appendChild(ul);for(var i=0;i<items.length;i++){if(items[i].type=="checkbox"&&items[i].checked){document.getElementById(items[i].id).checked=true;}}}
dhtmlMenu.prototype.positionUnderElement=function(el){var ul=document.getElementById(this.id);ul.style.left=_totalOffsetLeft(el)+"px";ul.style.top=_totalOffsetTop(el)+el.offsetHeight+"px";}
dhtmlMenu.prototype.positionAt=function(left,top){var ul=document.getElementById(this.id);ul.style.left=left+"px";ul.style.top=top+"px";}
dhtmlMenu.prototype.toggleShow=function(location,params){switch(location){case"underElement":this.positionUnderElement(arguments[1]);break;case"at":this.positionAt(arguments[1],arguments[2]);break;}
if(dmTimeout[this.id]!=null)clearTimeout(dmTimeout[this.id])
showHide(document.getElementById(this.id));}
dhtmlMenu.prototype.show=function(location,el){if(location=="underElement"){this.positionUnderElement(el)}
if(dmTimeout[this.id]!=null)clearTimeout(dmTimeout[this.id])
showHide(document.getElementById(this.id),'show');}
dhtmlMenu.prototype.hide=function(){if(dmTimeout[this.id]!=null)clearTimeout(dmTimeout[this.id])
dmTimeout[this.id]=setTimeout("showHide(document.getElementById('"+this.id+"'),'hide')",dmTimeoutLength);}
dhtmlMenu.prototype.isVisible=function(){if(this.exists()){if(document.getElementById(this.id).style.visibility=="visible"){return true;}else{return false;}}else{return false;}}
function dhtmlMenuItem(type,label){this.type=type;this.label=label;switch(type){case"link":this.href=arguments[2];this.image=arguments[3];break;case"checkbox":this.id=arguments[2];this.checked=arguments[3];this.onclick=arguments[4];break;}}
function dhtmlMenuItemMouseover(e){var srcEl=xGetEventSrcElement(e);if(srcEl.tagName!="LI")srcEl=getParentByTagName(srcEl,"LI");srcEl.className="DHTMLMENU ITEMHOVER";for(var i=0;i<srcEl.childNodes;i++)srcEl.childNotes[i].className="DHTMLMENU ITEMHOVER";var ul=getParentByTagName(srcEl,"UL");if(dmTimeout[ul.id]!=null)clearTimeout(dmTimeout[ul.id])}
function dhtmlMenuItemMouseout(e){var srcEl=xGetEventSrcElement(e);if(srcEl.tagName!="LI")srcEl=getParentByTagName(srcEl,"LI");srcEl.className="";for(var i=0;i<srcEl.childNodes;i++)srcEl.childNotes[i].className="";var ul=getParentByTagName(srcEl,"UL");dmTimeout[ul.id]=setTimeout("showHide(document.getElementById('"+ul.id+"'),'hide')",dmTimeoutLength);}
function setOnBeforeUnload(){if(window.onBeforeUnload){window.onbeforeunload=window.onBeforeUnload;}}
function cancelOnBeforeUnload(){if(window.onBeforeUnload){window.onbeforeunload=null;}}
var _setSelectVisibilityWindowedElements;function _setSelectVisibility(visibility,obj){if(obj!=null){var oTop=_totalOffsetTop(obj);var oLeft=_totalOffsetLeft(obj);var oBottom=oTop+obj.offsetHeight;var oRight=oLeft+obj.offsetWidth;}
if(_setSelectVisibilityWindowedElements==null){var selectObjs=document.getElementsByTagName("SELECT");var specialObjs=document.getElementsByTagName("OBJECT");_setSelectVisibilityWindowedElements=new Array();for(var i=0;i<selectObjs.length;i++)_setSelectVisibilityWindowedElements[_setSelectVisibilityWindowedElements.length]=selectObjs[i];for(var i=0;i<specialObjs.length;i++)_setSelectVisibilityWindowedElements[_setSelectVisibilityWindowedElements.length]=specialObjs[i];}
for(var i=0;i<_setSelectVisibilityWindowedElements.length;i++){element=_setSelectVisibilityWindowedElements[i];if(visibility=="hidden"){var sTop=_totalOffsetTop(element);var sLeft=_totalOffsetLeft(element);var sBottom=sTop+element.offsetHeight;var sRight=sLeft+element.offsetWidth;if(((oTop<=sTop&&sTop<=oBottom)||(oTop<=sBottom&&sBottom<=oBottom)||(sTop<=oTop&&sBottom>=oBottom)||(sTop>=oTop&&sBottom<=oBottom))&&((oLeft<=sLeft&&sLeft<=oRight)||(oLeft<=sRight&&sRight<=oRight)||(sLeft<=oLeft&&sRight>=oRight)||(sLeft>=oLeft&&sRight<=oRight))){element.style.visibility="hidden";}}else{element.style.visibility="visible";}}}
function _totalOffsetLeft(el){return el.offsetLeft+(el.offsetParent?_totalOffsetLeft(el.offsetParent):0);}
function _totalOffsetTop(el){return el.offsetTop+(el.offsetParent?_totalOffsetTop(el.offsetParent):0);}
function moveObjUp(o){if(o.previousSibling!=null){var vals=getInputsToCheck(o);var p=o.parentNode;var s=o.previousSibling;var c=p.removeChild(o);var n=p.insertBefore(c,s);setCheckedInputs(n,vals);}}
function moveObjDown(o){if(o.nextSibling!=null){var vals=getInputsToCheck(o.nextSibling);var p=o.parentNode;var s=p.removeChild(o.nextSibling);var n=p.insertBefore(s,o);setCheckedInputs(n,vals);}}
function getInputsToCheck(o){var cb=o.getElementsByTagName("INPUT");var vals=new Array();for(var i=0;i<cb.length;i++){if(cb[i].type=="checkbox"){if(cb[i].checked!=cb[i].defaultChecked){vals.push([i,cb[i].checked]);}}}
return vals;}
function setCheckedInputs(o,vals){var cb=o.getElementsByTagName("INPUT");for(var i=0;i<vals.length;i++){cb[vals[i][0]].checked=vals[i][1];}}
function moveUp(obj){selectedArray=new Array();for(i=1;i<obj.length;i++){if(obj[i].selected&&!obj[i-1].selected){scrollTop=obj[i].scrollTop;moveObjUp(obj[i]);obj[i].scrollTop=scrollTop-obj[i].offsetHeight;selectedArray.push(i-1);}}
for(n=0;n<selectedArray.length;n++){obj[selectedArray[n]].selected=true;}}
function moveDown(obj){selectedArray=new Array();for(i=obj.length-2;i>-1;i--){if(obj[i].selected&&!obj[i+1].selected){scrollTop=obj[i].scrollTop;moveObjDown(obj[i]);obj[i].scrollTop=scrollTop+obj[i].offsetHeight;selectedArray.push(i+1);}}
for(n=0;n<selectedArray.length;n++){obj[selectedArray[n]].selected=true;}}
function selectAll(selectObj){for(var i=0;i<selectObj.length;i++){selectObj.options[i].selected=true;}}
function getSelectedValues(selectObj){var selectedValues=new Array();for(var i=0;i<selectObj.length;i++){if(selectObj.options[i].selected&&selectObj.options[i].value!=""){selectedValues[selectedValues.length]=selectObj.options[i].value;}}
return selectedValues;}
function getSelectedText(selectObj){var selectedText=new Array();for(var i=0;i<selectObj.length;i++){if(selectObj.options[i].selected&&selectObj.options[i].value!=""){selectedText[selectedText.length]=selectObj.options[i].text;}}
return selectedText;}
function populateSelectList(selectObj,values,selectedValues,synchValues){var n=1;if(selectObj.type=="select-multiple")n=0;if(selectedValues==null)selectedValues=[];if(synchValues==null)synchValues=[];selectObj.options.length=n;for(var i=0;i<values.length;i++){if(synchValues.length==0||arrayContains(synchValues,values[i][2])){selectObj.options[n]=new Option(values[i][1],values[i][0]);if(arrayContains(selectedValues,values[i][0])){selectObj.options[n].selected=true;}
n++;}}}
function selectValues(selectObj,values,setAsDefault,deselectCurrent){for(var i=0;i<selectObj.length;i++){if(arrayContains(values,selectObj.options[i].value)){selectObj.options[i].selected=true;if(setAsDefault!==null&&setAsDefault){selectObj.options[i].defaultSelected=true;}}else if(deselectCurrent){selectObj.options[i].selected=false;}}}
function sortOptions(selectObj){var optionArray=new Array;for(var i=0;i<selectObj.options.length;i++){optionArray[i]=new Array(selectObj.options[i].value,selectObj.options[i].text,selectObj.options[i].selected);}
optionArray.sort(sortOptions_alpha);for(var i=0;i<selectObj.options.length;i++){selectObj.options[i].value=optionArray[i][0];selectObj.options[i].text=optionArray[i][1];selectObj.options[i].selected=optionArray[i][2];}}
function sortOptions_alpha(opt1,opt2){if(opt1[1]>opt2[1]){return 1;}else{return-1;}}
var reWhitespace=/^\s+$/;var reEmail=/^([a-zA-Z0-9_\.\-\&])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/i;var reFloat=/^-?((\d+(\.\d*)?)|((\d*\.)?\d+))$/;var mPrefix="You did not enter a value into the \""
var mSuffix="\" field. This is a required field. Please enter it now."
var mPrefix2="You did not select a value for \""
var mSuffix2="\". This information is required. Please select a value now."
var iEmail="We have detected an invalid e-mail address. Please review the e-mail address you've entered and try again.";function isEmpty(s){return((s==null)||(s.length==0))}
function isWhitespace(s){return(isEmpty(s)||reWhitespace.test(s));}
function isEmail(s){return reEmail.test(s)}
function isNumber(s){return reFloat.test(s)}
function warnEmpty(fieldObj,s){if(fieldObj.type!="hidden"){fieldObj.focus();}
alert(mPrefix+s+mSuffix);return false}
function warnInvalid(fieldObj,s){if(fieldObj.type!="hidden"){fieldObj.focus();if(fieldObj.select)fieldObj.select()}
alert(s)
return false}
function checkText(fieldObj,s){if(isWhitespace(fieldObj.value))return warnEmpty(fieldObj,s);else return true;}
function checkLength(fieldObj,maxLength,s){if(fieldObj.value.length>maxLength){return warnInvalid(fieldObj,"The value in the \""+s+"\" field cannot have more than "+maxLength+" characters.\nIt currently has "+fieldObj.value.length+" characters");}else{return true;}}
function checkChecked(fieldObj,s){if(fieldObj.length){for(i=0;i<fieldObj.length;i++){if(fieldObj[i].checked)return true;}
fieldObj[0].focus();}else{if(fieldObj.checked)return true;fieldObj.focus();}
alert(mPrefix2+s+mSuffix2);return false;}
function checkSelected(fieldObj,s){for(i=0;i<fieldObj.length;i++){if(fieldObj.options[i].selected&&fieldObj.options[i].value.length>0)return true;}
fieldObj.focus();alert(mPrefix2+s+mSuffix2);return false;}
function checkEmail(fieldObj){if(fieldObj.value!=""){fieldObj.value=trim(fieldObj.value);if(!isEmail(fieldObj.value))return warnInvalid(fieldObj,iEmail);}
return true;}
function checkNumber(fieldObj,s){var value=fieldObj.value;value=value.replace(/[$,]/g,"");if(value==""){fieldObj.value=value;return true;}
if(!isNumber(value)){return warnInvalid(fieldObj,"The value in field "+s+" must be a number.");}else{fieldObj.value=value;return true;}}
function checkDate(fieldObj, s) {
	dateStr = fieldObj.value;
	if (isEmpty(dateStr)) return true;

	var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)((\d{2}|\d{4}))$/;
	var matchArray = dateStr.match(datePat); // is the format ok?
	if (matchArray == null) {
		return warnInvalid (fieldObj,"Value in field " + s + " must be in the form of mm/dd/yyyy.");
	}
	month = matchArray[3]; // parse date into variables
	day = matchArray[1];
	year = matchArray[5];
	if (month < 1 || month > 12) { // check month range
		return warnInvalid (fieldObj,"Month must be between 1 and 12 for field " + s + ".");
	}
	if (day < 1 || day > 31) {
		return warnInvalid (fieldObj,"Day must be between 1 and 31 for field " + s + ".");
	}
	if (year < 1900 || year > 2078) {
		return warnInvalid (fieldObj,"Year must be between 1900 and 2078 for field " + s + ".");
	}
	if ((month==4 || month==6 || month==9 || month==11) && day==31) {
		return warnInvalid (fieldObj,"Month "+month+" doesn't have 31 days for field " + s + ".")
	}
	if (month == 2) { // check for february 29th
		var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
		if (day > 29 || (day==29 && !isleap)) {
			return warnInvalid (fieldObj,"February " + year + " doesn't have " + day + " days for field " + s + ".");
		}
	}
	return true; // date is valid
}
function checkPhone(fieldObj,s){var value=fieldObj.value;if(value==""){return true;}
value=value.replace(/\(/g,"");value=value.replace(/\)/g,"");value=value.replace(/[\s.x-]/g,"");if(!isNumber(value)){return warnInvalid(fieldObj,"The value in field "+s+" must be a valid phone number.");}
if(value.length<10){return warnInvalid(fieldObj,"The value in field "+s+" must be a valid phone number.");}
return true;}
function checkFile(formObj,colName,s){var uploadFieldObj=formObj.elements[colName];if(isWhitespace(uploadFieldObj.value)){if(formObj.elements[colName+"_OldFile"]){var oldfileFieldObj=formObj.elements[colName+"_OldFile"];var deleteCheckbox=formObj.elements[colName+"_Delete"];if(isWhitespace(oldfileFieldObj.value)||deleteCheckbox.checked){return warnEmpty(uploadFieldObj,s);}else{return true;}}
return warnEmpty(uploadFieldObj,s);}
return true;}
function reEscape(s){return s.replace(/[\\\^\$\*\+\?\.\(\)\|\[\]\{\}]/g,"\\$&");}
function htmlEncode(s){return s.replace(/\&/g,"\&amp;");}
function getCheckedValue(fieldObj){for(var i=0;i<fieldObj.length;i++){if(fieldObj[i].checked){break}}
return fieldObj[i].value}
function getSelectedValue(fieldObj){for(var i=0;i<fieldObj.length;i++){if(fieldObj[i].selected){return fieldObj[i].value}}
return"";}
function yesNoFormat(b){return b==1?"Yes":(b==0?"No":(b?"Yes":"No"));}
function replace(s,subexpr,replacestring){var i=s.indexOf(subexpr);if(i>-1){s=s.substring(0,i)+replacestring+s.substring(i+subexpr.length,s.length)}
return s;}
function replaceAll(s,subexpr,replacestring){if(replacestring.indexOf(subexpr)>-1){alert("replacestring contains subexpression.  aborting to avoid infinite loop.\nreplacestring: "+replacestring+"\nsubexpression: "+subexpr);return s;}
var i=s.indexOf(subexpr);while(i>-1){s=s.substring(0,i)+replacestring+s.substring(i+subexpr.length,s.length)
i=s.indexOf(subexpr);}
return s;}
function listAppend(list,value,delimiter){if(delimiter==null)delimiter=",";if(list!=null&&list!="")list+=delimiter+value;else list=value;return list;}
function listRemove(list,value,delimiter){if(delimiter==null)delimiter=",";list=list.replace(new RegExp(reEscape(value),"gi"),"");list=list.replace(new RegExp(delimiter+delimiter,"g"),delimiter);list=list.replace(new RegExp("^"+delimiter+"|"+delimiter+"$","g"),"");return list;}
function listShiftRight(list,value){list=list.replace(new RegExp("("+reEscape(value)+"),([^$,]+)","gi"),"$2,$1");return list;}
function listShiftLeft(list,value){list=list.replace(new RegExp("([^^,]+),("+reEscape(value)+")","gi"),"$2,$1");return list;}
function listFind(list,value,delimiter){if(delimiter==null)delimiter=",";return list.match(new RegExp("[^"+delimiter+"]*(^|"+delimiter+")"+reEscape(value)+"($|"+delimiter+")[^"+delimiter+"]*"));}
function arrayContains(arr,val,ignoreCase){if(ignoreCase){val=val.toLowerCase();for(var i=0;i<arr.length;i++){if(arr[i].toLowerCase()==val){return true;break;}}}else{for(var i=0;i<arr.length;i++){if(arr[i]==val){return true;break;}}}
return false;}
function arrayRemoveDuplicates(arr,ignoreCase){var newArr=[];for(var i=0;i<arr.length;i++){if(!arrayContains(newArr,arr[i],ignoreCase)){newArr.push(arr[i]);}}
return newArr;}
function split(s,del){var arr;if(s.length>0){arr=s.split(del);}else{arr=new Array();}
return arr;}
function getScrollWidth(win){if(win==null)win=window;var w=win.pageXOffset||win.document.body.scrollLeft||win.document.documentElement.scrollLeft;return w?w:0;}
function getScrollHeight(win){if(win==null)win=window;var h=win.pageYOffset||win.document.body.scrollTop||win.document.documentElement.scrollTop;return h?h:0;}
function getParentByTagName(el,tagName){return(el.parentNode.tagName==tagName?el.parentNode:getParentByTagName(el.parentNode,tagName));}
function getEl(id){return document.getElementById(id);}
function isGecko(){return(window.navigator.product=="Gecko");}
function xGetEventSrcElement(e){if(window.event){return window.event.srcElement;}else if(e&&e.currentTarget){return e.currentTarget;}}
function xGetEvent(win,e){if(win.event){return win.event;}else{return e;}}
function xGetEventSrcElementForWindow(win,e){if(win.event){return win.event.srcElement;}else{return e.target;}}
function xAddEvent(obj,name,handler){if(obj.attachEvent){obj.attachEvent("on"+name,handler);}else{obj.addEventListener(name,handler,false);}}
function xGetSelection(win){if(win.document.selection){return win.document.selection;}else{return win.getSelection();}}
function xGetSelectionRange(win){if(win.document.selection){return win.document.selection.createRange();}else{return win.getSelection().getRangeAt(0);}}
function xGetRangeText(rng){if(rng.text){return rng.text;}else if(rng.toString){return rng.toString();}else{return"";}}
function xRangeParentElement(rng){if(rng.parentElement){return rng.parentElement();}else{var parentNode=rng.commonAncestorContainer;while(parentNode.nodeType!=1)parentNode=parentNode.parentNode;return parentNode;}}
function xMoveToElementText(rng,element){if(rng.moveToElementText){rng.moveToElementText(element);}else{rng.selectNodeContents(element);}}
function xSelectRange(win,rng){if(rng.select){rng.select();}else{var sel=xGetSelection(win);sel.removeAllRanges();sel.addRange(rng);}}
function xSelectElement(win,el){var rng=xGetSelectionRange(win);xMoveToElementText(rng,el);xSelectRange(win,rng);}
function xCloneRange(rng){if(rng.duplicate){return rng.duplicate();}else{return rng.cloneRange();}}
function xElementIsInRange(element,rng){if(rng.duplicate){var elementRange=rng.duplicate();elementRange.moveToElementText(element);elementRange.moveStart("character");elementRange.moveEnd("character",-1);return rng.inRange(elementRange);}else{var elementRange=document.createRange();elementRange.selectNode(element);return(rng.compareBoundaryPoints(rng.START_TO_START,elementRange)<1&&rng.compareBoundaryPoints(rng.END_TO_END,elementRange)>-1)||(element.tagName!="IMG"&&xRangesAreIdentical(rng,elementRange));}}
function xInsertTextInRange(doc,rng,text){if(rng.insertNode){var newNode=doc.createTextNode(text);rng.insertNode(newNode);rng.selectNode(newNode);}else{rng.pasteHTML(text);rng.findText(text,-text.length);}}
function xRangesAreIdentical(range1,range2){if(xGetRangeText(range1)==xGetRangeText(range2)){return true;}else{return false;}}
function xReplaceElement(oldEl,newTagName){var newEl;if(isGecko()){newEl=oldEl.ownerDocument.createElement(newTagName);newEl.innerHTML=oldEl.innerHTML;oldEl.parentNode.replaceChild(newEl,oldEl);}
return newEl;}
function xCloneElement(oldEl){var newEl;newEl=oldEl.ownerDocument.createElement(oldEl.tagName);newEl.innerHTML=oldEl.innerHTML;return newEl;}
function xGetStyleSheetRules(ss){if(ss.rules){return ss.rules;}else{return ss.cssRules;}}
function xGetXml(url){if(document.implementation&&document.implementation.createDocument){xmlDoc=document.implementation.createDocument("","",null);}else if(window.ActiveXObject){xmlDoc=new ActiveXObject("Microsoft.XMLDOM");}
if(xmlDoc!=null)xmlDoc.load(url);return xmlDoc;}
isSelectionCollapsed=function(win){if(win==null)win=window;if(win.document["selection"]){return win.document.selection.createRange().text=="";}else if(win["getSelection"]){var selection=win.getSelection();return selection.isCollapsed;}}
function cfBoolean(s){s=String(s).toLowerCase();return(s=="yes"||s=="true");}
function removeQueryParam(s,p){p=reEscape(p);s=s.replace(new RegExp("&"+p+"=[^&]*|"+p+"=[^&]*&|"+p+"=[^&]*","gi"),"");return s;}

//Resources/js/table.js
lh.Table=function(props){dojo.lang.mixin(this,props);this.Columns=new Object();this.Tables=new Object();this.Rows=new Array();if("COLUMNS"in this){for(colName in this.COLUMNS){this.addColumn(this.COLUMNS[colName]);}}
lh.Tables[this.NAME]=this;this.nextId=1;}
lh.Table.prototype={addColumn:function(props){props.Table=this;switch(props.TYPE.toLowerCase()){case"childtable":this.Tables[props.NAME]=new lh.Table(props);break;case"text":this.Columns[props.NAME]=new lh.TextColumn(props);break;case"integer":this.Columns[props.NAME]=new lh.IntegerColumn(props);break;case"checkbox":this.Columns[props.NAME]=new lh.CheckboxColumn(props);break;case"checkbox":this.Columns[props.NAME]=new lh.CheckboxColumn(props);break;case"select-popup":this.Columns[props.NAME]=new lh.SelectPopupColumn(props);break;case"file":this.Columns[props.NAME]=new lh.FileColumn(props);break;case"select":this.Columns[props.NAME]=new lh.SelectColumn(props);break;case"date":this.Columns[props.NAME]=new lh.DateColumn(props);break;case"textarea":this.Columns[props.NAME]=new lh.TextareaColumn(props);break;case"select-multiple":this.Columns[props.NAME]=new lh.SelectMultipleColumn(props);break;default:this.Columns[props.NAME]=new lh.Column(props);break;}
return this.Columns[props.NAME];},addRow:function(){return new lh.Row(this);},getRowIndex:function(id){for(var i=0;i<this.Rows.length;i++){if(this.Rows[i].id==id){return i;break;}}
return-1;},setOrder:function(){if(this.ORDERCOLUMN&&this.ORDERCOLUMN.length>0){var orderNum=0;var dn,up=null;for(var i=0;i<this.Rows.length;i++){orderNum++;var r=this.Rows[i];r.OrderField.value=orderNum;r.MoveUpButton.style.visibility=(i==0?"hidden":"visible");r.MoveDownButton.style.visibility=(i==this.Rows.length-1?"hidden":"visible");}}},validate:function(){var row,cell;var valid=true;if(this.Rows.length>0){for(var r=0;r<this.Rows.length;r++){row=this.Rows[r];for(var c=0;c<row.Cells.length;c++){cell=row.Cells[c];if("validate"in cell){valid=cell.validate();if(!valid)return valid;}}}}else{if(cfBoolean(this.REQUIRED)){alert("You did not enter any values into the \""+this.DISPNAME+"\" field. This is a required field. Please enter one now.")
return false;}}
return valid;},getValue:function(){var values=[];for(var r=0;r<this.Rows.length;r++){values[r]=new Object();for(var c=0;c<this.Rows[r].Cells.length;c++){var cell=this.Rows[r].Cells[c];if(cfBoolean(cell.EDITABLE)){values[r][cell.NAME]=cell.getValue();}}}
return dojo.json.serialize(values);},monitorColumns:function(monitor){for(var c=0;c<this.COLUMNORDER.length;c++){var col=this.Columns[this.COLUMNORDER[c]];if(col&&cfBoolean(col.EDITABLE)){if(col.NAME in lh.Cells){monitor.addField("lh.Cells['"+col.NAME+"'].getValue();",{name:col.DISPNAME});}else{col.fieldId=col.NAME;monitor.addField("lh.Columns['"+col.NAME+"'].getValue();",{name:col.DISPNAME});}}else{var t=this.Tables[this.COLUMNORDER[c]];if(t){monitor.addField("lh.Tables['"+t.NAME+"'].getValue();",{name:t.DISPNAME});}}}}}

//Resources/js/row.js
lh.Row=function(table){this.id=table.nextId;table.nextId++;this.Table=table;table.Rows.push(this);this.Cells=new Array();lh.Rows[table.NAME+"_"+this.id]=this;}
lh.Row.prototype={addCell:function(columnName,fieldId){var column=this.Table.Columns[columnName];if(fieldId==null)fieldId=columnName;var cell=new lh.Cell(this,column,fieldId);this.Cells[this.Cells.length]=cell;return cell;},getCell:function(columnName){for(var i=0;i<this.Cells.length;i++){if(this.Cells[i].Column.NAME==columnName){return this.Cells[i];break;}}},render:function(values){var r=this;var t=this.Table;var htmlTable=getEl(t.NAME+"_Table");var htmlTbody=htmlTable.getElementsByTagName("TBODY")[0];this.htmlRow=document.createElement("TR");this.htmlRow.id=t.NAME+"_"+this.id;htmlTbody.appendChild(this.htmlRow);var pkCol,pkVal;var dnImg="<img src=\""+MCFResourcesPath+"/images/arrowdn.gif\" alt=\"Move Down\" border=0>";var upImg="<img src=\""+MCFResourcesPath+"/images/arrowup.gif\" alt=\"Move Up\" border=0>";for(var i=0;i<t.COLUMNORDER.length;i++){var col=t.Columns[t.COLUMNORDER[i]];if(cfBoolean(col.PRIMARYKEY)){pkCol=col;if(values!=null){pkVal=values[i];}else{pkVal="";}}else{var template=getEl(t.NAME+"_"+col.NAME+"_Template");if(template){var c=this.addCell(col.NAME,t.NAME+"_"+col.NAME+"_"+this.id);c.htmlCell=document.createElement("TD");c.htmlCell.className="childtableedit";this.htmlRow.appendChild(c.htmlCell);c.htmlEditCell=c.htmlCell.appendChild(document.createElement("div"));c.htmlViewCell=c.htmlCell.appendChild(document.createElement("div"));c.htmlEditCell.innerHTML=template.innerHTML.replace(/_0/g,"_"+this.id);c.render();if(values!=null){c.setValue(values[i]);}else if(c.TYPE.toLowerCase()=="textarea"&&getEl(c.fieldId+"_workArea")!=undefined){setTimeout("xInitField(\""+c.fieldId+"\",\"\")",1000);}else if(c.TYPE.toLowerCase()=="select-popup"){if(cfBoolean(c.AUTOSELECT)){c.select();}}}}}
var btnCell=this.htmlRow.appendChild(document.createElement("TD"));var btnTbl=btnCell.appendChild(document.createElement("TABLE"));var btnBdy=btnTbl.appendChild(document.createElement("TBODY"));var btnTr=btnBdy.appendChild(document.createElement("TR"));this.btnParent=btnTr;this.addHiddenField(t.NAME+"_rowIds",r.id);if(t.ORDERCOLUMN&&t.ORDERCOLUMN.length>0){this.OrderField=this.addHiddenField(t.NAME+"_"+t.ORDERCOLUMN+"_"+r.id,"");this.MoveDownButton=r.addButton(dnImg,function(){r.moveDown();});this.MoveUpButton=r.addButton(upImg,function(){r.moveUp();});}
if(pkCol){this.addHiddenField(t.NAME+"_"+pkCol.NAME+"_"+r.id,pkVal);}
htmlTable.style.display="";if(!cfBoolean(t.EDITBYDEFAULT)){this.StopEditButton=this.addButton("Stop&nbsp;Edit",function(){r.turnOffEdit();});this.EditButton=this.addButton("Edit",function(){r.turnOnEdit();});this.EditButton.style.display="none";if(values!=null){this.turnOffEdit();}}
this.addButton("Remove",function(){r.deleteRow();});t.setOrder();},deleteRow:function(){if(confirm("Are you sure you want to delete this record?")){var tbody=this.htmlRow.parentNode;if(getEl(this.htmlRow.id+"_display")){tbody.removeChild(getEl(this.htmlRow.id+"_display"));}
tbody.removeChild(this.htmlRow);this.Table.Rows.splice(this.Table.getRowIndex(this.id),1);if(tbody.getElementsByTagName("TR").length==0){tbody.parentNode.style.display="none";}
this.Table.setOrder();}},addHiddenField:function(name,value){var hdn=document.createElement("INPUT")
hdn.type="hidden";hdn.name=name;hdn.value=value;this.htmlRow.cells[0].appendChild(hdn);return hdn;},addButton:function(label,action,id){var btn;if(id!=null)btn=getEl(id);if(btn==null){btn=document.createElement("TD");btn.id=id;btn.className="button";btn.innerHTML=label;btn.onclick=action;this.btnParent.appendChild(btn);}
return btn;},moveUp:function(){this.setDefaultChecked(this.htmlRow);moveObjUp(this.htmlRow);var i=this.Table.getRowIndex(this.id);this.Table.Rows.splice(i,1);this.Table.Rows.splice(i-1,0,this);this.Table.setOrder();},moveDown:function(){this.setDefaultChecked(this.htmlRow.nextSibling);moveObjDown(this.htmlRow);var i=this.Table.getRowIndex(this.id);this.Table.Rows.splice(i,1);this.Table.Rows.splice(i+1,0,this);this.Table.setOrder();},setDefaultChecked:function(htmlRow){var inputs=htmlRow.getElementsByTagName("input");for(var i=0;i<inputs.length;i++)inputs[i].defaultChecked=inputs[i].checked;},turnOffEdit:function(){for(var i=0;i<this.Cells.length;i++){this.Cells[i].turnOffEdit();}
this.StopEditButton.style.display="none";this.EditButton.style.display="";},turnOnEdit:function(){for(var i=0;i<this.Cells.length;i++){this.Cells[i].turnOnEdit();}
this.StopEditButton.style.display="";this.EditButton.style.display="none";}}

//Resources/js/column.js
lh.Column=function(props){for(prop in props){this[prop]=props[prop];}
lh.Columns[this.NAME]=this;}
lh.Column.prototype={render:function(){},setValue:function(value){getEl(this.fieldId).value=getEl(this.fieldId).defaultValue=value;},getValue:function(){return getEl(this.fieldId).value;},validate:function(){if(cfBoolean(this.REQUIRED)){return checkText(getEl(this.fieldId),this.DISPNAME);}else{return true;}}}
lh.TextColumn=function(props){lh.Column.call(this,props);}
lh.TextColumn.prototype=new lh.Column;lh.IntegerColumn=function(props){lh.Column.call(this,props);}
lh.IntegerColumn.prototype=new lh.Column;lh.TextareaColumn=function(props){lh.Column.call(this,props);}
lh.TextareaColumn.prototype={render:function(){},setValue:function(value){if(getEl(this.fieldId+"_workArea")!=undefined){getEl(this.fieldId).value=value;setTimeout("xInitField(\""+this.fieldId+"\",\""+dojo.string.escapeJavaScript(value)+"\")",1000);}else{getEl(this.fieldId).value=getEl(this.fieldId).defaultValue=value;}},getValue:function(){return getEl(this.fieldId).value;},validate:function(){return true;}}
lh.CheckboxColumn=function(props){lh.Column.call(this,props);}
lh.CheckboxColumn.prototype={render:function(){},setValue:function(value){getEl(this.fieldId).checked=getEl(this.fieldId).defaultChecked=(value==this.ONDISPLAYVALUE);},getValue:function(){return(getEl(this.fieldId).checked?this.ONDISPLAYVALUE:this.OFFDISPLAYVALUE);},validate:function(){return true;}}
lh.SelectColumn=function(props){lh.Column.call(this,props);}
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
lh.SelectMultipleColumn=function(props){lh.Column.call(this,props);}
lh.SelectMultipleColumn.prototype=new lh.SelectColumn;lh.SelectPopupColumn=function(props){lh.Column.call(this,props);}
lh.SelectPopupColumn.prototype={render:function(){this.SelectWindow=null;this.DisplayTable=getEl(this.fieldId+"_table");this.SelectButton=getEl(this.fieldId+"_SelectButton");if(this.NAME!=this.fieldId){this.VIEWURL+="&"+this.NAME+"_FieldID="+this.fieldId;this.POPUPURL+="&"+this.NAME+"_FieldID="+this.fieldId;}
this.DisplayTable.style.display="none";eval("window."+this.fieldId+"_add = function(pk,descr){return lh.Cells['"+this.fieldId+"'].add(pk,descr)}");eval("window."+this.fieldId+"_isSelected = function(pk){return lh.Cells['"+this.fieldId+"'].isSelected(pk)}");eval("window."+this.fieldId+"_getRow = function(pk){return lh.Cells['"+this.fieldId+"'].getRow(pk)}");eval("window."+this.fieldId+"_delete = function(pk){return lh.Cells['"+this.fieldId+"'].deleteRow(pk)}");eval("window."+this.fieldId+"_view = function(pk){return lh.Cells['"+this.fieldId+"'].view(pk)}");return this;},setValue:function(value){this.add(value[0],value[1]);},getValue:function(){return this.displayValue;},validate:function(){return true;},add:function(pk,descr){if(!this.isSelected(pk)){if(this.DisplayTable.rows.length>0){this.DisplayTable.deleteRow(0);}
var row=document.createElement("TR");row.setAttribute("rowID",pk);this.displayValue=descr;var rowObj=this.DisplayTable.appendChild(row);var cell1=rowObj.appendChild(document.createElement("TD"));cell1.innerHTML=descr;this.addButton(rowObj,"Delete","Delete "+descr,"function(){lh.Cells['"+this.fieldId+"'].deleteRow("+pk+")}");if(this.VIEWURL.length>0){this.addButton(rowObj,"View","View "+descr,"function(){lh.Cells['"+this.fieldId+"'].viewRow("+pk+")}");}
this.addButton(rowObj,"Select","Select a different record","function(){lh.Cells['"+this.fieldId+"'].select()}");getEl(this.fieldId).value=pk;if(this.SelectWindow){this.SelectWindow.close();}
this.DisplayTable.style.display="";this.SelectButton.style.display="none";}},addButton:function(row,label,title,onclick){var c=row.appendChild(document.createElement("TD"));c.className="button";eval("c.onclick = "+onclick);c.innerHTML=label;c.title=title;},isSelected:function(pk){var row=this.getRow(pk);return(row!=null);},getRow:function(pk){var rows=getEl(this.fieldId+"_table").getElementsByTagName("TR");for(var r=0;r<rows.length;r++){if(pk==rows[r].getAttribute("rowID")){return rows[r];}}
return null;},deleteRow:function(pk){row=this.getRow(pk)
row.parentNode.removeChild(row);getEl(this.fieldId).value="";this.DisplayTable.style.display="none";this.SelectButton.style.display="";},select:function(){this.SelectWindow=popupDialog(this.fieldId,700,500,"resizable=1,scrollbars=1",this.POPUPURL);},viewRow:function(pk){this.SelectWindow=popupDialog(this.fieldId,700,500,"resizable=1,scrollbars=1",this.VIEWURL.replace(/#pk#/,pk));}}
lh.DateColumn=function(props){lh.Column.call(this,props);}
lh.DateColumn.prototype={render:function(){},setValue:function(value){var d;if(cfBoolean(this.SHOWDATE)){d=new Date(value);if(!isNaN(d.getMonth()))getEl(this.fieldId).value=(d.getMonth()+1)+"/"+d.getDate()+"/"+d.getFullYear();}
if(cfBoolean(this.SHOWTIME)){if(!cfBoolean(this.SHOWDATE)){d=new Date(new Date().toLocaleDateString()+" "+value)}
if(!isNaN(d.getHours())&&(d.getHours()>0||d.getMinutes>0)){getEl(this.fieldId+"_Hour").value=dojo.string.padLeft(d.getHours()%12==0?"12":d.getHours()%12,2);getEl(this.fieldId+"_Minute").value=dojo.string.padLeft(d.getMinutes(),2);getEl(this.fieldId+"_AMPM").selectedIndex=d.getHours()<12?0:1;}}},getValue:function(){var value="";if(cfBoolean(this.SHOWDATE)){value=getEl(this.fieldId).value;}
if(cfBoolean(this.SHOWTIME)){var hour=getEl(this.fieldId+"_Hour").value;var minute=getEl(this.fieldId+"_Minute").value;var ampm=getEl(this.fieldId+"_AMPM");if(hour!=""||minute!=""){value+=" "+(hour==""?"00":hour);value+=":"+(minute==""?"00":minute);value+=" "+ampm.options[ampm.selectedIndex].value;}}
return value;},validate:function(){return true;}}
lh.FileColumn=function(props){lh.Column.call(this,props);}
lh.FileColumn.prototype={render:function(){this.InputField=getEl(this.fieldId);this.FileBrowserLink=getEl(this.fieldId+"_FileBrowserLink");this.OldFileField=getEl(this.fieldId+"_OldFile");this.CurrentFileDisplay=getEl(this.fieldId+"_CurrentFileDisplay");this.CurrentFileLink=getEl(this.fieldId+"_Link");this.DeleteCheckbox=getEl(this.fieldId+"_Delete");this.InputField.Column=this;this.InputField.onchange=function(){if(this.value.length>0)this.Column.DeleteCheckbox.checked=true;}
if(cfBoolean(this.SHOWFILEBROWSER)){this.FileBrowserLink.Column=this;this.FileBrowserLink.target="filebrowser";this.FileBrowserLink.onclick=function(){dialogParams=new Array();dialogParams.fileColumn=this.Column;var filebrowserWin=popupDialog("filebrowser",750,550,"resizable=1,scrollbars=1,status=1");filebrowserWin.location.href=MCFResourcesPath+"/dialogs/fileBrowser.cfm?uploadDir="+encodeURIComponent(this.Column.DIRECTORY);}}else{this.FileBrowserLink.style.display="none";}
this.setValue("");return this;},setValue:function(value){this.OldFileField.value=value;this.CurrentFileLink.href="/"+this.DIRECTORY+"/"+value;this.CurrentFileLink.innerHTML=value;this.CurrentFileDisplay.style.display=(value==""?"none":"");},getValue:function(value){var value=(getEl(this.fieldId).value==""?getEl(this.fieldId+"_OldFile").value:getEl(this.fieldId).value);if(getEl(this.fieldId).value!=""){return getEl(this.fieldId).value;}else if(getEl(this.fieldId+"_OldFile").value!=""){return"<a href=\""+getEl(this.fieldId+"_Link").href+"\" target=_blank>"+getEl(this.fieldId+"_OldFile").value+"</a>";}else{return"";}},validate:function(){return true;}}

//Resources/js/cell.js
lh.Cell=function(row,column,fieldId){dojo.lang.mixin(this,column);this.Row=row;this.fieldId=fieldId;lh.Cells[fieldId]=this;}
lh.Cell.prototype={turnOffEdit:function(){this.htmlViewCell.innerHTML=this.getValue();this.htmlViewCell.style.display="";this.htmlEditCell.style.display="none";this.htmlCell.className="childtableeditdisplay";},turnOnEdit:function(){this.htmlViewCell.style.display="none";this.htmlEditCell.style.display="";this.htmlCell.className="childtableedit";}}

//Resources/js/page.js
lh.getPage=function(pageID){var p;dojo.io.bind({url:AppVirtualPath+"/Lighthouse/Admin/rpc.cfm?object=Page&method=GetWorkingPage&pageID="+pageID,load:function(type,evaldObj){p=new lh.Page(evaldObj[0]);},mimetype:"text/json-comment-filtered",sync:true});return p;}
lh.Page=function(props){for(prop in props){this[prop]=props[prop];}
this.titleDisplay=this.title=""?this.navtitle:this.title;if(this.templatename=="")this.templatename="Default";}
lh.Page.prototype={update:function(){dojo.io.bind({url:AppVirtualPath+"/Lighthouse/Admin/rpc.cfm?object=Page&method=Update",load:function(type,evaldObj){if(!evaldObj){alert("Error updating page.")}},formNode:getEl("pageInfo"),mimetype:"text/json-comment-filtered"});}};

//Resources/js/wysiwyg.js
var htmlToolbars=new Array();var htmlFields=new Object();var htmlFieldClasses=new Array();var currentDiv=null;var currentToolbar=null;var currentField=null;var popupWindow=null;var fieldWindow=window;var dialogParams=null;var styleEditMode="element";function htmlToolbar(windowObj,toolbarID){this.id=toolbarID;this.htmlField=null;this.window=windowObj;}
htmlToolbar.prototype.doEdit=function(command,value){if(this.htmlField!=null){this.htmlField.hideContextMenu();xSetFieldActive(this.htmlField);switch(command){case"RemoveFormatting":removeFormatting(this.htmlField);break;default:try{if(isGecko()){switch(command){case"Bold":if(getCurrent(this.htmlField,"STRONG")!=null){var newEl=xReplaceElement(getCurrent(this.htmlField,"STRONG"),"B");xSelectElement(this.htmlField.contentWindow,newEl);}
break;case"Italic":if(getCurrent(this.htmlField,"EM")!=null){var newEl=xReplaceElement(getCurrent(this.htmlField,"EM"),"I");xSelectElement(this.htmlField.contentWindow,newEl);}
break;}}
this.htmlField.contentWindow.document.execCommand(command,false,value);}catch(ex){var msg="";if(ex.message=="Access to XPConnect service denied"){msg+="<p>The "+command+" command will not work without setting preferences for your browser.</p>";if(command=="cut")msg+="<p>Press Ctrl-x on your keyboard instead.</p>";else if(command=="copy")msg+="<p>Press Ctrl-c on your keyboard instead.</p>";else if(command=="paste")msg+="<p>Press Ctrl-v on your keyboard instead.</p>";msg+="<p>See the following url for more information:</p>";msg+="<p><a href=\"http://www.mozilla.org/editor/midasdemo/securityprefs.html\" target=\"_blank\">http://www.mozilla.org/editor/midasdemo/securityprefs.html</a></p>";}else{msg="Error message:<br>"+ex.message;}
this.alert("Command Not Supported",msg);}}}else{alert("No html edit field has been selected.");}}
checkAll=false;htmlToolbar.prototype.dialog=function(dialogName,siteEditor,fileDir,dialogWin){if(this.htmlField!=null){if(siteEditor==null)siteEditor=false;if(fileDir==null)fileDir="";var dialogWidth=500;var dialogHeight=400;var options="scrollbars=no,resizable=yes,status=no,toolbar=no,menubar=no,location=no";var dialogScript="/dialogs/element.html";currentField=this.htmlField;this.htmlField.hideContextMenu();this.htmlField.controlToText();xSetFieldActive(this.htmlField);dialogParams=new Array();dialogParams["htmlToolbar"]=this;dialogParams["htmlField"]=this.htmlField;dialogParams["dialogName"]=dialogName;dialogParams["elementName"]=dialogName.toUpperCase();dialogParams["siteEditor"]=siteEditor;dialogParams["fileDir"]=fileDir;switch(dialogName){case"link":dialogParams["elementName"]="A";break;case"anchor":dialogParams["elementName"]="A";break;case"tableCreate":dialogScript="/dialogs/tableCreate.html";break;case"img":element=getCurrent(this.htmlField,"IMG");if(element==null){dialogScript="/dialogs/filebrowser.cfm?uploadDir="+escape(fileDir);dialogWidth="700";dialogHeight="450";dialogName="imgInsert";options="resizable=1,scrollbars=1";}
break;case"editHtml":dialogScript="/dialogs/code.html";dialogWidth="760";dialogHeight="560";options="resizable=1";break;case"spellCheck":dialogScript="/spellchecker/window.cfm?jsvar=currentField.editArea.innerHTML&fieldName="+this.htmlField.fieldName;dialogWidth="450";dialogHeight="242";options="status=no,toolbar=no,menubar=no,location=no";break;}
if(dialogWin==null){popupDialog(dialogName+"PropertiesWin",dialogWidth,dialogHeight,options,MCFResourcesPath+dialogScript);}else{dialogWin.location=MCFResourcesPath+dialogScript;dialogWin.focus();}}else{alert("No html edit field has been selected.");}}
htmlToolbar.prototype.alert=function(title,message){var dialogWidth=400;var dialogHeight=380;var options="scrollbars=no,resizable=yes,status=no,toolbar=no,menubar=no,location=no";dialogParams=new Array();dialogParams["title"]=title;dialogParams["message"]=message;var dialogWin=popupDialog("alert",dialogWidth,dialogHeight,options,MCFResourcesPath+"/dialogs/alert.html");}
htmlToolbar.prototype.showStylesMenu=function(){if(this.htmlField!=null){var dm=new this.htmlField.window.dhtmlMenu("mcfWysiwygStylesMenu");if(!dm.isVisible()){xSetFieldActive(this.htmlField);currentField=this.htmlField;this.htmlField.window.currentField=this.htmlField;var items=new Array();var label,href,token,re;var currentElement=getCurrent(this.htmlField);var currentRange=xGetSelectionRange(this.htmlField.contentWindow);var els=new Array();var rules=getStylesheetRules(this.htmlField);var tagName,i,checked,elementRangeSelected,getMoreElements;getMoreElements=true;getParentElements=false;styleEditMode="element";if(xGetSelection(this.htmlField.contentWindow).type=="Control"||xGetRangeText(currentRange)==""){if(currentElement.tagName=="IMG"){els[els.length]=currentElement;getMoreElements=false;}else{getParentElements=true;}}else{var elementRange=xCloneRange(currentRange);xMoveToElementText(elementRange,currentElement);if(xRangesAreIdentical(currentRange,elementRange)){if(currentElement.tagName!="SPAN"){styleEditMode="spans";elementRangeSelected=currentElement.tagName;els[els.length]=this.htmlField.contentWindow.document.createElement("SPAN");}
getParentElements=true;}else{styleEditMode="spans";els[els.length]=this.htmlField.contentWindow.document.createElement("SPAN");if(xElementIsInRange(currentElement,currentRange)){els[els.length]=currentElement;}}}
if(getMoreElements){var element=currentElement;while((getParentElements||xElementIsInRange(element,currentRange))&&element&&element.id!=null&&element.id.indexOf("_editArea")==-1&&stripHTML(element.innerHTML)==stripHTML(currentElement.innerHTML)){els[els.length]=element;element=element.parentNode;}}
for(var r=0;r<rules.length;r++){tagName=null;if(arrayContains(rules[r][2],"")){tagName="";}else{for(var e=0;e<els.length;e++){if(arrayContains(rules[r][2],els[e].tagName)){tagName=els[e].tagName;if(elementRangeSelected==null||elementRangeSelected==tagName){break;}}}}
if(tagName!=null){for(var e=0;e<els.length;e++){if(listFind(els[e].className,rules[r][0]," ")){checked=true;break;}else{checked=false;}}
items[items.length]=new dhtmlMenuItem("checkbox",rules[r][3],rules[r][0]+"|"+tagName,checked,setStyles);}}
if(items.length==0){items[items.length]=new dhtmlMenuItem("link","No Styles Available for Selection","","");}
dm.create(items);if(this.window!=this.htmlField.window){dm.toggleShow("at",0,getScrollHeight(this.htmlField.window));}else{dm.toggleShow("underElement",document.getElementById(this.htmlField.fieldName+"_showStylesMenuButton"));}}else{dm.toggleShow();}}else{alert("No html edit field has been selected.");}}
htmlToolbar.prototype.hideStylesMenu=function(){var dm=new this.window.dhtmlMenu("mcfWysiwygStylesMenu");if(dm.isVisible())dm.toggleShow();if(this.htmlField!=null){this.htmlField.saveContents();}}
htmlToolbar.prototype.setCurrentStyle=function(){if(this.htmlField!=null){this.htmlField.hideContextMenu();}}
function htmlField(type,windowObj,fieldName,htmlToolbar){this.type=type;this.fieldName=fieldName;this.field=windowObj.document.getElementById(fieldName);this.window=windowObj;fieldWindow=this.window;if(type=="frame"){this.frame=windowObj.document.getElementById(fieldName+"_editArea");this.contentWindow=this.frame.contentWindow;this.editArea=this.contentWindow.document.body;this.editArea.id=fieldName;}else{this.contentWindow=fieldWindow;this.editArea=windowObj.document.getElementById(fieldName+"_editArea");}
this.workArea=windowObj.document.getElementById(fieldName+"_workArea");if(htmlToolbar!=null){this.htmlToolbar=htmlToolbar;if(htmlToolbar.htmlField==null)htmlToolbar.htmlField=this;}
this.field.value=cleanUp(this.workArea.innerHTML,this.window);this.editArea.innerHTML=this.workArea.innerHTML;tableSetGuidelines(this.editArea);this.setObjectEvents();getStyleXml();}
htmlField.prototype.getContents=function(){this.saveContents();return this.field.value;}
htmlField.prototype.getRawContents = function(){return this.editArea.innerHTML;}
htmlField.prototype.setContents=function(html){this.editArea.innerHTML=html;this.saveContents();}
htmlField.prototype.saveContents=function(){this.workArea.innerHTML=this.editArea.innerHTML;tableRemoveGuidelines(this.workArea);html=this.workArea.innerHTML;html=cleanUp(html,this.window);html=replaceSpecialChars(html);this.field.value=html;}
htmlField.prototype.setObjectEvents=function(){var images=this.editArea.getElementsByTagName("IMG");for(var i=0;i<images.length;i++){images[i].onresizeend=imageSetSize;}}
htmlField.prototype.showContextMenu=function(e){var dm=new this.window.dhtmlMenu("mcfWysiwygContextMenu");if(!dm.isVisible()){var items=new Array();var label,href,dialogName,image,clientX,clientY;this.controlToText();var element=xGetEventSrcElementForWindow(this.contentWindow,e);while(element!=this.editArea){if(getFriendlyTagName(element.tagName)!=element.tagName){label=getFriendlyTagName(element.tagName)+" Properties";dialogName=element.tagName.toLowerCase();image="";switch(element.tagName){case"TABLE":image="tableProperties.gif";break;case"TR":image="rowProperties.gif";break;case"TD":image="cellProperties.gif";break;case"IMG":image="insertImage.gif";break;case"STRONG":image="bold.gif";break;case"EM":image="italic.gif";break;case"U":image="underline.gif";break;case"UL":image="insertUnorderedList.gif";break;case"P":image="justifyleft.gif";break;case"SUP":image="superscript.gif";break;case"SUB":image="subscript.gif";break;case"A":if(element.name!=""){dialogName="anchor";image="createBookmark.gif";}else{dialogName="link";image="createLink.gif";}
break;}
href="javascript:fieldWindow.htmlFields[\""+this.fieldName+"\"].htmlToolbar.dialog(\""+dialogName+"\")";if(image!="")image=MCFResourcesPath+"/images/toolbar/"+image;items[items.length]=new dhtmlMenuItem("link",label,href,image);}
element=element.parentNode;}
if(items.length>0){dm.create(items);clientX=xGetEvent(this.window,e).clientX;clientY=xGetEvent(this.window,e).clientY;if(this.type=="frame"){clientX=clientX+_totalOffsetLeft(this.frame);clientY=clientY+_totalOffsetTop(this.frame);}else{clientX=clientX+getScrollWidth(this.window);clientY=clientY+getScrollHeight(this.window);}
dm.toggleShow("at",clientX,clientY);}}else{dm.toggleShow();}
return false;}
htmlField.prototype.hideContextMenu=function(){var dm=new this.window.dhtmlMenu("mcfWysiwygContextMenu");if(dm.isVisible())dm.toggleShow();}
htmlField.prototype.setActive=function(){var range=xGetSelectionRange(this.contentWindow);xMoveToElementText(range,this.editArea);range.collapse();xSelectRange(this.contentWindow,range);}
htmlField.prototype.controlToText=function(){if(xGetSelection(this.contentWindow).type=="Control"){var oControlRange=xGetSelectionRange(this.contentWindow);var e=oControlRange(0);xGetSelection(this.contentWindow).empty();var s=xGetSelectionRange(this.contentWindow);xMoveToElementText(s,e);xSelectRange(this.contentWindow,s);}}
htmlField.prototype.getTrimmedSelection=function(){var rng=xGetSelectionRange(this.contentWindow);if(rng.text){while(rng.text.substr(0,1)==" "){rng.moveStart("character",1);}
while(rng.text.substr(rng.text.length-1,1)==" "){rng.moveEnd("character",-1);}
xSelectRange(this.contentWindow,rng);}
return rng;}
function imageSetSize(e){imageObj=xGetEventSrcElement(e);if(imageObj){if(imageObj.style.width!=""){imageObj.setAttribute("width",imageObj.offsetWidth);imageObj.setAttribute("height",imageObj.offsetHeight);imageObj.style.width="";imageObj.style.height="";}else{imageObj.setAttribute("width",imageObj.width);imageObj.setAttribute("height",imageObj.height);}}}
function getCurrent(htmlField,tagName){var element=null;if(tagName==""||tagName==null){if(xGetSelection(htmlField.contentWindow).type=="Control"){var oControlRange=xGetSelectionRange(htmlField.contentWindow);for(var i=0;i<oControlRange.length;i++){if(oControlRange(i).nodeType==1){element=oControlRange(i);}}}else{var selectedTextRange=xGetSelectionRange(htmlField.contentWindow);element=xRangeParentElement(selectedTextRange);if(element.id&&element.id.indexOf("_editArea")>-1){var selectedText=selectedTextRange.text;var newTextRange=xCloneRange(selectedTextRange);newTextRange.collapse();element=xRangeParentElement(newTextRange);if(element.id.indexOf("_editArea")>-1){if(htmlField.editArea.innerHTML=="")editArea.innerHTML="&nbsp;";if(htmlField.editArea.childNodes[0].nodeType==1){element=htmlField.editArea.firstChild;}else{element=htmlField.editArea.ownerDocument.createElement("P");element.innerHTML=htmlField.editArea.innerHTML;htmlField.editArea.innerHTML="";htmlField.editArea.appendChild(element);xMoveToElementText(newTextRange,element);newTextRange.collapse();xSelectRange(htmlField.contentWindow,newTextRange);}}
if(selectedText!=""){newTextRange.findText(selectedText);xSelectRange(htmlField.contentWindow,newTextRange);}}
if(selectedTextRange.duplicate){var newElement=element;var elementRange=selectedTextRange.duplicate();xMoveToElementText(elementRange,newElement);var newElementRange=elementRange.duplicate();newElementRange.moveStart("character");while(selectedTextRange.inRange(newElementRange)&&newElement.parentNode&&newElement.parentNode.id!=null&&newElement.parentNode.id.indexOf("_editArea")==-1){xMoveToElementText(newElementRange,newElement.parentNode);newElementRange.moveStart("character");if(selectedTextRange.inRange(newElementRange)){newElement=newElement.parentNode;}}
xMoveToElementText(newElementRange,newElement);if(newElementRange.text!=elementRange.text){element=newElement;}}}}else{if(xGetSelection(htmlField.contentWindow).type=="Control"){var oControlRange=xGetSelectionRange(htmlField.contentWindow);for(var i=0;i<oControlRange.length;i++){if(oControlRange(i).tagName==tagName){return oControlRange(i);}}
element=oControlRange(0);}else{if(tagName=="IMG"){if(htmlField.contentWindow.document["selection"]||!htmlField.contentWindow.getSelection().isCollapsed){element=getElementInSelection(htmlField,"IMG");}}else{var rng=xGetSelectionRange(htmlField.contentWindow);element=xRangeParentElement(rng);}}
while(element!=null&&element.tagName!=tagName&&element!=htmlField.editArea){element=element.parentNode;}
if(element==htmlField.editArea)element=null;}
return element;}
function selectCurrent(htmlField,tagName){var element=getCurrent(htmlField,tagName);var currentRange=xGetSelectionRange(htmlField.contentWindow);if(element!=null){xMoveToElementText(currentRange,element);xSelectRange(htmlField.contentWindow,currentRange);}else if(xGetSelection(htmlField.contentWindow).type!="Control"){if(currentRange.htmlText){if(currentRange.htmlText.indexOf("<"+tagName+" ")>-1){currentRange.collapse();xSelectRange(htmlField.contentWindow,currentRange);element=getCurrent(htmlField,tagName);while(element!=null&&element.tagName!=tagName){currentRange.move("character",1);xSelectRange(htmlField.contentWindow,currentRange);element=getCurrent(htmlField,tagName);}
if(element!=null){xMoveToElementText(currentRange,element);xSelectRange(htmlField.contentWindow,currentRange);}}else if(currentRange.htmlText.length==0){currentRange.move("character",-1);xSelectRange(htmlField.contentWindow,currentRange);element=getCurrent(htmlField,tagName);if(element!=null){xMoveToElementText(currentRange,element);xSelectRange(htmlField.contentWindow,currentRange);}else{currentRange.move("character",1);xSelectRange(htmlField.contentWindow,currentRange);}}}}
return element;}
function getElementInSelection(htmlField,tagName){var els=htmlField.contentWindow.document.getElementsByTagName(tagName);var currentRange=xGetSelectionRange(htmlField.contentWindow);for(var i=0;i<els.length;i++){if(xElementIsInRange(els[i],currentRange)){return els[i];}}
return null;}
function tableInsertRow(htmlToolbar,offset){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;var newTR=tbody.insertRow(tr.rowIndex+offset);tableCleanCells(htmlToolbar.htmlField)}}
function tableDeleteRow(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;tbody.deleteRow(tr.rowIndex);tableCleanCells(htmlToolbar.htmlField)}}
function tableInsertColumn(htmlToolbar,offset){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;var rows=tbody.rows;if(offset==0){var gridIndex=1;for(var c=0;c<td.cellIndex;c++)gridIndex=gridIndex+tr.cells[c].colSpan;}else{var gridIndex=0;for(var c=0;c<=td.cellIndex;c++)gridIndex=gridIndex+tr.cells[c].colSpan;}
for(var r=0;r<rows.length;r++){var i=0;for(var c=0;c<rows[r].cells.length;c++){if(i+1==gridIndex&&offset==0){rows[r].insertCell(rows[r].cells[c].cellIndex);break;}
i=i+rows[r].cells[c].colSpan;if(i>gridIndex){rows[r].cells[c].setAttribute("colSpan",rows[r].cells[c].getAttribute("colSpan")+1);break;}else if(i==gridIndex){rows[r].insertCell(rows[r].cells[c].cellIndex+offset);break;}}}
tableCleanCells(htmlToolbar.htmlField)}}
function tableDeleteColumn(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var cellIndex=td.cellIndex;var tr=td.parentNode;var tbody=tr.parentNode;var rows=tbody.rows;var gridIndex=1;for(var c=0;c<td.cellIndex;c++)gridIndex=gridIndex+tr.cells[c].colSpan;for(var r=0;r<rows.length;r++){var i=0;for(var c=0;c<rows[r].cells.length;c++){i=i+rows[r].cells[c].colSpan;if(i>gridIndex||(i==gridIndex&&rows[r].cells[c].colSpan>1)){rows[r].cells[c].setAttribute("colSpan",rows[r].cells[c].getAttribute("colSpan")-1);break;}else if(i==gridIndex){rows[r].deleteCell(rows[r].cells[c].cellIndex);break;}}}
tableCleanCells(htmlToolbar.htmlField)}}
function tableIncreaseColSpan(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;if(tr.cells.length>td.cellIndex+1){if(trim(tr.cells[td.cellIndex+1].innerHTML)!="<br>"){td.innerHTML=td.innerHTML+" "+tr.cells[td.cellIndex+1].innerHTML;}
tr.deleteCell(td.cellIndex+1);td.setAttribute("colSpan",td.colSpan+1);}
tableCleanCells(htmlToolbar.htmlField);}}
function tableDecreaseColSpan(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;if(td.getAttribute("colSpan")>1){tr.insertCell(td.cellIndex+1);td.setAttribute("colSpan",td.colSpan-1);}
tableCleanCells(htmlToolbar.htmlField);}}
function tableIncreaseRowSpan(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;var currRowSpan=td.getAttribute("rowSpan");if(tbody.rows.length>tr.rowIndex+currRowSpan){td.setAttribute("rowSpan",td.getAttribute("rowSpan")+1);}
tableCleanCells(htmlToolbar.htmlField);}}
function tableDecreaseRowSpan(htmlToolbar){var td=getCurrent(htmlToolbar.htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;var currRowSpan=td.getAttribute("rowSpan");if(td.getAttribute("rowSpan")>1){td.setAttribute("rowSpan",td.getAttribute("rowSpan")-1);}
tableCleanCells(htmlToolbar.htmlField);}}
function tableCleanCells(htmlField){var td=getCurrent(htmlField,"TD");if(td!=null&&td.tagName=="TD"){var tr=td.parentNode;var tbody=tr.parentNode;var rows=tbody.rows;var rowCells=new Array();var maxCells=0;for(var r=0;r<rows.length;r++){rowCells[r]=0;}
for(var r=0;r<rows.length;r++){for(var c=0;c<rows[r].cells.length;c++){rowCells[r]=rowCells[r]+rows[r].cells[c].colSpan;if(isGecko()&&rows[r].cells[c].childNodes.length==0){rows[r].cells[c].appendChild(htmlField.contentWindow.document.createElement("BR"));}
if(rows[r].cells[c].rowSpan>1){for(var s=r+1;s<r+rows[r].cells[c].rowSpan;s++){rowCells[s]=rowCells[s]+rows[r].cells[c].colSpan;}}}
if(rowCells[r]>maxCells)maxCells=rowCells[r];}
for(var r=0;r<rows.length;r++){if(rowCells[r]!=maxCells){var diff=maxCells-rowCells[r];if(diff>0){for(var d=0;d<diff;d++){td=rows[r].insertCell(rowCells[r]+d);if(isGecko())td.appendChild(htmlField.contentWindow.document.createElement("BR"));}}else{for(var d=0;d>diff;d--){rows[r].deleteCell(rowCells[r]+d);}}}}}
tableSetGuidelines(htmlField.editArea);}
function tableSetGuidelines(id){var tables=id.getElementsByTagName("TABLE");for(var t=0;t<tables.length;t++){if(tables[t].border==0){tables[t].border=1;tables[t].className=listAppend(tables[t].className,"showborders"," ");}}}
function tableRemoveGuidelines(id){var tables=id.getElementsByTagName("TABLE");for(var t=0;t<tables.length;t++){if(listFind(tables[t].className,"showborders"," ")){tables[t].border=0;tables[t].className=listRemove(tables[t].className,"showborders"," ");}}}
var stylesheetRules=new Array();var stylesheetXml;function getStyleXml(){if(stylesheetXml==null)stylesheetXml=xGetXml(AppVirtualPath+"/style.xml")}
function getStylesheetRules(htmlField){if(stylesheetRules.length==0){var ss=htmlField.contentWindow.document.styleSheets;var ssArray=new Array();var re=/^\s*([^, ]*)\.([^,: ]+)$/i;var rules,rule,ruleInfo,selectors,classSelector;var styleNames=new Array();if(stylesheetXml!=null){var styles=stylesheetXml.getElementsByTagName("style");for(var i=0;i<styles.length;i++){styleNames[styles[i].getElementsByTagName("class")[0].firstChild.nodeValue.toLowerCase()]=styles[i].getElementsByTagName("name")[0].firstChild.nodeValue;}}
for(var s=0;s<ss.length;s++){ssArray[ssArray.length]=ss[s];if(ss[s].imports){for(var i=0;i<ss[s].imports.length;i++){ssArray[ssArray.length]=ss[s].imports[i];}}}
for(var s=0;s<ssArray.length;s++){try{rules=xGetStyleSheetRules(ssArray[s]);}catch(e){rules=[];}
for(var r=0;r<rules.length;r++){rule=rules[r];if(rule.cssText&&rule.cssText.indexOf("@import")>-1){ssArray[ssArray.length]=rule.styleSheet;}
if(rule.selectorText!=null){selectors=rule.selectorText.split(",");for(var s2=0;s2<selectors.length;s2++){classSelector=selectors[s2].match(re);if(classSelector!=null&&styleNames[classSelector[2].toLowerCase()]){tag=classSelector[1];className=classSelector[2];ruleInfo=null;for(var i=0;i<stylesheetRules.length;i++){if(stylesheetRules[i][0]==className){ruleInfo=stylesheetRules[i];break;}}
if(ruleInfo==null){ruleInfo=new Array();ruleInfo[0]=className;ruleInfo[1]=rule;ruleInfo[2]=new Array();ruleInfo[3]=styleNames[classSelector[2].toLowerCase()];stylesheetRules.push(ruleInfo);}
if(!arrayContains(ruleInfo[2],tag)){ruleInfo[2].push(tag.toUpperCase());}}}}}}
stylesheetRules.sort(compareStylesheetRules);}
return stylesheetRules;}
function compareStylesheetRules(ruleInfo1,ruleInfo2){if(ruleInfo1[3]>ruleInfo2[3]){return 1;}else{return-1;}}
function wysiwygAddClass(className,tagName,element){if(styleEditMode=="spans"){if(tagName=="SPAN"){var currentRange=xGetSelectionRange(currentField.contentWindow);currentField.contentWindow.document.execCommand("FontSize",false,"1");fontElements=currentField.editArea.getElementsByTagName("FONT");var firstSpan,lastSpan;for(var i=fontElements.length-1;i>-1;i--){if(fontElements[i].parentNode.tagName=="SPAN"&&stripHTML(fontElements[i].innerHTML)==stripHTML(fontElements[i].parentNode.innerHTML)){spanElement=fontElements[i].parentNode;spanElement.innerHTML=fontElements[i].innerHTML;}else{var spanElement=currentField.contentWindow.document.createElement("SPAN");spanElement.innerHTML=fontElements[i].innerHTML;fontElements[i].parentNode.replaceChild(spanElement,fontElements[i]);}
spanElement.className=className;if(lastSpan==null)lastSpan=spanElement;}
firstSpan=spanElement;if(currentRange.duplicate){var elementRange=xCloneRange(currentRange);xMoveToElementText(elementRange,firstSpan);currentRange.setEndPoint("StartToStart",elementRange);xMoveToElementText(elementRange,lastSpan);currentRange.setEndPoint("EndToEnd",elementRange);xSelectRange(currentField.contentWindow,currentRange);}else if(firstSpan!=null&&lastSpan!=null){currentRange.setStartBefore(firstSpan);currentRange.setEndAfter(lastSpan);}}else{var els=currentField.contentWindow.document.getElementsByTagName(tagName);var currentRange=xGetSelectionRange(currentField.contentWindow);for(var i=0;i<els.length;i++){if(xElementIsInRange(els[i],currentRange)){els[i].className=listAppend(els[i].className,className," ");}}}}else{if(element==null)element=getCurrent(currentField,tagName);if(element!=null){element.className=listAppend(element.className,className," ");}}}
function wysiwygRemoveClass(className,tagName,element){if(styleEditMode=="element"){if(element==null)element=getCurrent(currentField);var foundClass=false;while(!foundClass&&element&&element.id!=null&&element.id.indexOf("_editArea")==-1){if(listFind(element.className,className," ")){element.className=listRemove(element.className,className," ");foundClass=true;}else{element=element.parentNode;}}}else{var els=currentField.contentWindow.document.getElementsByTagName(tagName);var currentRange=xGetSelectionRange(currentField.contentWindow);for(var i=0;i<els.length;i++){if(xElementIsInRange(els[i],currentRange)){els[i].className=listRemove(els[i].className,className," ");}}}}
function setStyles(e){var srcEl=xGetEventSrcElementForWindow(currentField.window,e);if(srcEl.tagName=="LABEL"){srcEl=srcEl.ownerDocument.getElementById(srcEl.getAttribute("for"));}
var info=srcEl.id.split("|");if(srcEl.checked){wysiwygAddClass(info[0],info[1]);}else{wysiwygRemoveClass(info[0],info[1]);}
if(currentField!=null){currentField.saveContents();}}
function removeFormatting(htmlField){editArea=htmlField.editArea;workArea=htmlField.workArea;var html;html=editArea.innerHTML;workArea.innerHTML=html;tableRemoveGuidelines(workArea);workArea.innerHTML=workArea.innerHTML.replace(/<(\/?)(h[1234567]|address|pre)/gi,"<$1p");workArea.innerHTML=workArea.innerHTML.replace(/<\/?(font|span)[^>]*>/gi,"");if(workArea.innerHTML.indexOf("<?xml:namespace")>-1){workArea.innerHTML=workArea.innerHTML.replace(/<(\?xml:namespace|\/?[a-z0-9]+:[a-z0-9]+)[^>]*>/gi,"");}
workArea.innerHTML=workArea.innerHTML.replace(/(<ul|<li) [^>]+>/gi,"$1>");workArea.innerHTML=workArea.innerHTML.replace(/(<[^>]+) style="[^"]+"/gi,"$1");workArea.innerHTML=workArea.innerHTML.replace(/(<[^>]+) class=("[^"]+"|[^ ">]+)/gi,"$1");workArea.innerHTML=cleanUp(workArea.innerHTML);tableSetGuidelines(workArea);editArea.innerHTML=workArea.innerHTML;}
function cleanUp(s,editWindow){var re=new RegExp("(href|src)=\""+window.location.protocol+"//"+window.location.hostname+"(:"+window.location.port+")?/","gi");s=s.replace(re,"$1=\"/");if(editWindow!=null){re=new RegExp("href=\""+reEscape(editWindow.location.pathname)+"("+reEscape(htmlEncode(editWindow.location.search))+")?"+"[^#\"]*#([^\"]+)","gi");s=s.replace(re,"href=\"#$2");}
s=s.replace(/<P( [^>]+)?>((\s*<P( [^>]+)?>[\s\S]+?<\/P>\s*)+)<\/P>/gi,"<DIV$1>$2</DIV>");s=cleanUpStyle(s);s=s.replace(/([^\n\r])(<\/ul>|<li>)/gi,"$1\n$2");s=s.replace(/(<br>|<\/p>|<\/ul>|<\/table>|<\/div>)([^\n\r])/gi,"$1\n$2");s=s.replace(/<!--\[[^\]]*\]-->/g, "");return s;}
function trimLocalUrl(s){var re=new RegExp(window.location.protocol+"//"+window.location.hostname+"(:"+window.location.port+")?/","gi");return s.replace(re,"/")}
function cleanUpStyle(s){s=s.replace(/<span( class="")?( style="")?>([^<]*(<br>[^<]*)*)<\/span>/gi,"$3");s=s.replace(/<span( [^>]+)?><\/span>/gi,"");return s;}
function toHex(dec){var result=parseInt(dec).toString(16);if(result.length==1)result=("0"+result);result=result.substring(4,6).toUpperCase()+result.substring(2,4).toUpperCase()+result.substring(0,2).toUpperCase();if(result.length==2)result=result+"0000";if(result.length==4)result=result+"00";return result;}
function replaceSpecialChars(s){var reEmail=/(mailto:)?([\w.-]+\@[\w.-]+\.[\w]{2,4})/i;var n=1;while(s.search(reEmail)!=-1){found=s.match(reEmail);s=replaceAll(s,found[0],munge(found[0]));n++;if(n>1000)break;}
return s;}
function replaceSpecialChars_Text(s){s=replaceAll(s,"?","--");s=replaceAll(s,"?","-");s=replaceAll(s,"?","(tm)");s=replaceAll(s,"?","...");s=replaceAll(s,"?","\"");s=replaceAll(s,"?","\"");s=replaceAll(s,"?","'");s=replaceAll(s,"?","'");return s;}
function munge(s){txt="";for(var j=0;j<s.length;j++){txt+="&#"+s.charCodeAt(j)+";";}
return txt;}
function getFriendlyTagName(tagName){switch(tagName){case"P":return"Paragraph";break;case"A":return"Link";break;case"UL":return"List";break;case"OL":return"List";break;case"LI":return"List Item";break;case"STRONG":return"Bold Text";break;case"B":return"Bold Text";break;case"EM":return"Italic Text";break;case"I":return"Italic Text";break;case"U":return"Underlined Text";break;case"SUP":return"SuperScript Text";break;case"SUB":return"SubScript Text";break;case"BLOCKQUOTE":return"Indented Text";break;case"IMG":return"Image";break;case"TABLE":return"Table";break;case"TR":return"Table Row";break;case"TH":return"Table Header";break;case"TD":return"Table Cell";break;case"FONT":return"Text";break;case"SPAN":return"Text";break;default:return tagName;}}
function wysiwygInit(){var htmlToolbar=null;var frames=document.getElementsByTagName("IFRAME");for(var f=0;f<frames.length;f++){if(listFind(frames[f].className,"editable"," ")){var fieldId=replace(frames[f].id,"_editArea","");wysiwygInitField(fieldId);}}}
function wysiwygInitField(fieldId){var htmlToolbar=null;var frame=getEl(fieldId+"_editArea");if(htmlToolbars[fieldId])htmlToolbar=htmlToolbars[fieldId];htmlFields[fieldId]=new top.htmlField('frame',window,fieldId,htmlToolbar);var doc=frame.contentWindow.document;xAddEvent(doc,"click",wysiwygClick);xAddEvent(doc,"focus",wysiwygFocus);xAddEvent(doc,"blur",wysiwygBlur);xAddEvent(doc,"contextmenu",wysiwygContextmenu);if(htmlFieldClasses[fieldId])doc.body.className=listAppend(doc.body.className,htmlFieldClasses[fieldId]," ");wysiwygSetDesignMode(doc);if(!htmlToolbars[fieldId])wysiwygResize();}
function wysiwygSetDesignMode(doc){try{doc.designMode="on";try{doc.execCommand("styleWithCSS",false,false);}catch(ex){doc.execCommand("useCSS",false,true);}}catch(ex){}
lh.LoadStylesheet(doc,AppVirtualPath+"/style.css");}
function wysiwygResize(){var frames=document.getElementsByTagName("IFRAME");var doc,lineHeight,c,height;for(var f=0;f<frames.length;f++){doc=frames[f].contentWindow.document;if(doc.body){height=doc.body.offsetHeight;if(frames[f].contentWindow.getComputedStyle(doc.body,null)){lineHeight=frames[f].contentWindow.getComputedStyle(doc.body,null).getPropertyValue("line-height").replace("px","");}
if(isNaN(lineHeight)){lineHeight=15;}
if(height<lineHeight)height=lineHeight;c=doc.body.childNodes;if(c.length>0){if(c[0].offsetTop!=undefined)height=height+c[0].offsetTop;}
for(var i=0;i<c.length;i++){if(c[i].offsetTop!=undefined&&height<c[i].offsetTop+c[i].offsetHeight){height=c[i].offsetTop+c[i].offsetHeight;}}
frames[f].style.height=height+"px";}}
setTimeout("wysiwygResize()",500);}
function wysiwygClick(e){var doc=xGetEventSrcElement(e);if(htmlFields[doc.body.id]){htmlFields[doc.body.id].hideContextMenu();if(htmlFields[doc.body.id].htmlToolbar){htmlFields[doc.body.id].htmlToolbar.hideStylesMenu();}}}
function wysiwygFocus(e){var doc=xGetEventSrcElement(e);if(doc.designMode=="off"){wysiwygSetDesignMode(doc);}
wysiwygSetFieldToolbar(htmlFields[doc.body.id]);}
function wysiwygBlur(e){try{var doc=xGetEventSrcElement(e);htmlFields[doc.body.id].saveContents();}catch(er){}}
function wysiwygContextmenu(e){e.preventDefault();var doc=xGetEventSrcElement(e);wysiwygSetFieldToolbar(htmlFields[doc.body.id]);htmlFields[doc.body.id].showContextMenu(e);}
function wysiwygSetFieldToolbar(htmlField){if(htmlField.toolbar==null&&top.htmlToolbars){var htmlToolbar=top.htmlToolbars["main"];if(htmlField&&htmlToolbar){htmlField.htmlToolbar=htmlToolbar;htmlToolbar.htmlField=htmlField;}}}
function xSetFieldActive(htmlField){if(htmlField.editArea.setActive){htmlField.editArea.setActive();}else{htmlField.contentWindow.focus();}}
function xInitField(fieldId,value){htmlToolbars[fieldId]=new top.htmlToolbar(window,fieldId);getEl(fieldId).value=value;getEl(fieldId+"_workArea").innerHTML=value;if(getEl(fieldId+"_editArea").tagName=="IFRAME"){wysiwygInitField(fieldId)}else{htmlFields[fieldId]=new htmlField("inline",window,fieldId,htmlToolbars[fieldId]);}}

//Resources/js/menubar.js
function Browser(){var ua,s,i;this.isIE=false;this.isNS=false;this.isMac=false;this.version=null;ua=navigator.userAgent;s="Mac";if((i=ua.indexOf(s))>=0){this.isMac=true;}
s="MSIE";if((i=ua.indexOf(s))>=0){this.isIE=true;this.version=parseFloat(ua.substr(i+s.length));return;}
s="Netscape6/";if((i=ua.indexOf(s))>=0){this.isNS=true;this.version=parseFloat(ua.substr(i+s.length));return;}
s="Gecko";if((i=ua.indexOf(s))>=0){this.isNS=true;this.version=6.1;return;}}
var browser=new Browser();var activeButton=null;if(browser.isIE)document.onmousedown=pageMousedown;if(browser.isNS)document.addEventListener("mousedown",pageMousedown,true);function pageMousedown(event){var el;if(!activeButton)return;if(browser.isIE)el=window.event.srcElement;if(browser.isNS)el=(event.target.className?event.target:event.target.parentNode);if(el==activeButton)return;if(el.className!="menuButton"&&el.className!="menuItem"&&el.className!="menuItemSep"&&el.className!="menu")resetButton(activeButton);}
var vis="visible";function buttonClick(button,menuName){button.blur();if(!button.menu)button.menu=document.getElementById(menuName);if(activeButton&&activeButton!=button)resetButton(activeButton);if(button.isDepressed)resetButton(button);else depressButton(button);return false;}
function buttonMouseover(button,menuName){if(activeButton&&activeButton!=button){resetButton(activeButton);if(menuName)buttonClick(button,menuName);}}
function depressButton(button){var w,dw,x,y;button.className="menuButtonActive";if(browser.isIE&&!browser.isMac){if(!button.menu.firstChild.style.width){w=button.menu.firstChild.offsetWidth;button.menu.firstChild.style.width=w+"px";dw=button.menu.firstChild.offsetWidth-w;w-=dw;button.menu.firstChild.style.width=w+"px";}}
x=getPageOffsetLeft(button);y=getPageOffsetTop(button)+button.offsetHeight;if(browser.isNS&&browser.version<6.1)y--;button.menu.style.left=x+"px";button.menu.style.top=y+"px";button.menu.style.visibility="visible";_setSelectVisibility("hidden",button.menu);button.isDepressed=true;activeButton=button;}
function resetButton(button){_setSelectVisibility("visible");button.className="menuButton";if(button.menu)button.menu.style.visibility="hidden";button.isDepressed=false;activeButton=null;}
function getPageOffsetLeft(el){return el.offsetLeft+(el.offsetParent?getPageOffsetLeft(el.offsetParent):0);}
function getPageOffsetTop(el){return el.offsetTop+(el.offsetParent?getPageOffsetTop(el.offsetParent):0);}
