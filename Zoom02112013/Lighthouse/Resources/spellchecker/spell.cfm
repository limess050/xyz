
<!--
Executes spell checker
Author: Peter Freitag (pfreitag@cfdev.com)
Company: CFDEV.COM
Part of the CFX_JSpellChecker package by CFDEV.COM
-->
<html>
<head>
<cfparam name="spellCheckContent" default="">
<cfparam name="jsvar" default="">

<!--- see application.cfm for request definitions --->
<CFX_JSpellCheck
	searchdepth="#Request.searchdepth#"
	clx="#Request.clx#"
	tlx="#Request.tlx#"
	userdict="#Request.userdict#"
	englishphonetic="#Request.englishphonetic#"
	format="#Request.format#"
	suggestions="#Request.suggestions#"
	multilingual="#Request.multilingual#"
	striphtml="#Request.striphtml#"
	action="check"
	words="#spellCheckContent#"
	variable="jsoutput"
	charlimit="100000">
<script>
var iterator = -1; //pointer to the current word index
var curpos = 0; //current word position in document
var ignore = new Array();
var change = new Array();
var changeto = new Array();
var replacements = new Array();
//START: CFX_JSpellCheck output
<cfoutput>#jsoutput#</cfoutput>
//END:	CFX_JSpellCheck output

function increment() {
	//goes to the next word in the list
	iterator++;
	document.speller.suggestbtn.disabled = 1;

	if (iterator < numMispelled) {

		if (!isSkipped(mispelled[iterator])) { //hasn't been ignored or change all'd
			document.speller.spelled.value = mispelled[iterator];
			document.speller.changeto.value = suggestions[iterator][0];
			delete_options(document.speller.suggest);

			//parent.bottom.document.open();
			//parent.bottom.document.write("<html><body>");
			//parent.bottom.document.write("<font face='verdana' color='red' size='-2'>... " + getContext() + " ...</font>");
			//parent.bottom.document.write("</body></html>");
			//parent.bottom.document.close();
			parent.bottom.document.getElementById("checkerStatus").innerHTML = "... " + getContext() + " ...";

			for (var i=0;i<suggestions[iterator].length;i++) { //populate suggestion box
				if (suggestions[iterator][i] != "null") {
					var o = new Option(suggestions[iterator][i],suggestions[iterator][i]);
					document.speller.suggest.options[i] = o;
				}
			}
			document.speller.suggest.selectedIndex = 0;

		}

		else {
			increment();
		}
	}

	else {
		//done
		if (!parent.opener.checkAll || !parent.opener.spellCheckNextField()) {
			alert("Spell Check Complete.");
			done();
			parent.close();
		} else {
			done();
		}
	}

	if (typeof(bottom_span) != "undefined") {
		bottom_span.innerText = "Spell Checker Ready..."
	}
}

function delete_options(selectObject) {
	for (var i=0;i<selectObject.options.length;i++) {
		selectObject.options[i] = null;
	}
}

function ignore_all() {
	ignore[ignore.length] = mispelled[iterator];
	replacements[iterator] = null;
	increment();
}

function change_all() {
	change[change.length] = mispelled[iterator];
	changeto[changeto.length] = document.speller.changeto.value;
	replacements[iterator] = document.speller.changeto.value;
	increment();
}

function change_one() {
	replacements[iterator] = document.speller.changeto.value;
	increment();
}

function suggestClick() {
	document.speller.suggestbtn.disabled = 1;
	document.speller.changeto.value = document.speller.suggest.options[document.speller.suggest.options.selectedIndex].text;
}

function isSkipped(word) {
	//has it been ignored?
	for (var i=0;i<ignore.length;i++) {
		if (ignore[i] == word) {
			replacements[iterator] = null;
			return true;
		}
	}
	//do we want to change all?
	for (var i=0;i<change.length;i++) {
		if (change[i] == word) {
			replacements[iterator] = changeto[i];
			return true;
		}
	}
	return false;
}

function enable() { //enable add and suggest buttons
	document.speller.suggestbtn.disabled = 0;
}

function addword() {
	var word = document.speller.spelled.value;
	change[change.length] = word;
	changeto[changeto.length] = word;
	replacements[iterator] = word;
	if (confirm("Are You Sure you want to add " + word + " to the Dictionary")) {
		parent.bottom.location = "addword.cfm?word=" + word;
	}
	increment();
}

//replaces the first index of
function replace(string, search, replace, pos) {
	  if (typeof(pos) == "undefined") { var pos = 0; }
      //var i = string.indexOf(search, pos);
	  var i = getWordPos(string, search, pos);
      return (string.substring(0,i) + replace + string.substring(i + search.length, string.length));
}

function getWordPos(str, match,  pos) {
	//delimits a word as something with non alpha-numeric chars before and after it
	if (typeof(pos) == "undefined") { var pos = 0; }
	var subst = " " + str.substr(pos, str.length);

	//remove _s they cause problems
	while (subst.indexOf("_") != 0 && subst.indexOf("_") != -1) {
		var i = subst.indexOf("_");
		subst = subst.substring(0,i) + " " + subst.substring(i + 1, subst.length);
	}
	subst = subst.toLowerCase();
	match = match.toLowerCase();
	//if its the first pos, then there is no chars before it
	if (subst.indexOf(match) != 0 || subst.indexOf(match) != -1) {
		subst += " "; //add padding
		//not case sensitive!
		subst = subst.toLowerCase();
		match = match.toLowerCase();
		var re = new RegExp("\\W" + match + "\\W");
		var subpos = subst.search(re);
		//add 1 because it matches a char before
		var wordpos = pos+subpos+1;
		//make sure its not in a tag
		if (subst.indexOf("<") != -1 && subst.indexOf(">") != -1 && subst.indexOf("<") < subpos && subst.indexOf(">") > subpos)
		{
			return (pos + getWordPos(subst, match, subst.indexOf(">")+1));
		}
		else {	return wordpos-1;  }
	}
	else { return pos; }
}

function done() {
	if (numMispelled==0) {
		//parent.close();
		return;
	}
	var string = document.speller.originalContent.value;
	var idx = 0;
	var pos = 0;
	for (var i=0;i<numMispelled;i++) {
		for (var n=0;n<=i;n++) {
			if (mispelled[n] == mispelled[i]) {
				pos = getWordPos(string, mispelled[i], idx);
				idx = pos + mispelled[i].length;

				break;
			}
		}

		if (replacements[i] != null) {
			string = replace(string, mispelled[i], replacements[i], pos);
			//if we replaced it with a smaller word...
			if (idx > getWordPos(string, replacements[i], pos)) {
				idx = getWordPos(string, replacements[i], pos) +replacements[i].length;
			}
		}
	}
	<cfoutput>
	parent.opener.#jsvar# = string;
	</cfoutput>
	//parent.close();
}

function suggester() {
	parent.bottom.location = "suggest.cfm?word=" + document.speller.changeto.value;
}

function doSuggest(word, num, sugg) {
	/*
		word = the word that was suggested
		num = number of suggestions returned
		sugg = 2d array of suggestions
	*/

	document.speller.spelled.value = word;
	if (num == 0) {
		alert(word + " is spelled correct.");
		change_one();
		return;
	}
	delete_options(document.speller.suggest);

	for (var i=0;i<sugg[0].length;i++) { //populate suggestion box
		var o = new Option(sugg[0][i],sugg[0][i]);
		document.speller.suggest.options[i] = o;
	}
	document.speller.suggest.selectedIndex = 0;
	document.speller.changeto.value = sugg[0][0];

}

function getContext() {
	//gets the context of the current word.
	var string = document.speller.originalContent.value;
	string = stripTags(string);
	var context = "";
	var word = mispelled[iterator];
	// +/- from the word
	var range = 50;

	//word position
	var idx = -1;
	idx = getWordPos(string, word, curpos);
	curpos = idx;

	var minIDX = 0;
	if (idx > range) {
		minIDX = idx-range;
	}
	var maxIDX = string.length;
	if ((idx+range+word.length) < maxIDX) {
		maxIDX = idx + word.length + range;
	}
	context  = string.substring(minIDX, maxIDX);
	minIDX = 0;
	maxIDX = context.length;
	idx = getWordPos(context, word, 0);
	//first >
	if (context.indexOf(">", minIDX) < idx && context.indexOf(">", minIDX) > 0) {
		minIDX = context.indexOf(">", minIDX)+1;
	}
	//go to first space of context
	if (context.indexOf(" ", minIDX) < idx && context.indexOf(" ", minIDX) > 0) {
		minIDX = context.indexOf(" ", minIDX);
	}
	//last space
	if (context.lastIndexOf(" ", idx) > (idx + word.length)) {
		maxIDX = context.lastIndexOf(" ", minIDX);
	}
	//first .
	if (context.indexOf(".", minIDX) < idx && context.indexOf(".", minIDX) > 0) {
		minIDX = context.indexOf(".", minIDX)+1;
	}
	//last .
	if (context.lastIndexOf(".", idx) > (idx + word.length)) {
		maxIDX = context.lastIndexOf(".", minIDX);
	}

	//first < after the word
	if (context.indexOf("<", idx) > idx) {
		maxIDX = context.indexOf("<", idx);
	}
	context = context.substring(minIDX, maxIDX);

	idx = getWordPos(context, word, 0);

	//Set the mispelled word back in the orginial format. Jeff Jackson 4/29/2002
	//This was the custom dictionary is setup with the correct format.
	document.speller.spelled.value = context.substring(idx,idx+word.length);

	context = insert(context, "<b>", idx);
	idx = getWordPos(context, word, 0);
	context = insert(context, "</b>", idx+word.length);

	return context;
}

function stripTags(str) {
        var buffer = "";
        var startPos = str.indexOf("<",0);
		var i = 0;
        while (startPos >= 0 && i < str.length)
        {
            var endPos = str.indexOf(">", startPos);
			if (endPos == -1) { break; }
            buffer = str.substring(0, startPos);
            buffer += " "; //add whitespace to prevent concatination
            buffer+= str.substring(endPos+1, str.length);

            str = buffer;

            startPos = str.indexOf("<");
			i++;
        }
        return str;
}

function insert(string, substr, position) {
	var front = string.substring(0, position);
	var end = string.substring(position, string.length);
	return front + substr + end;
}
</script>
<style>
	TD {
		font-family: MS Sans Serif,arial,verdana;
		font-size: 9pt;
		vertical-align : top;
	}
</style>
</head>
<body onLoad="increment();">
<form name="speller">

	<table border="0" width="425" height="200" cellpadding="2" cellspacing="0"
		<cfif trim(jsoutput) is "var numMispelled = 0;"> style="visibility:hidden"</cfif>>
		<tr>
			<td>
				Not In Dictionary:
			</td>
			<td colspan="3">
				<input type="Text" readonly name="spelled" style="background-Color:silver;width:300;" size="37">
			</td>
		</tr>
		<tr>
			<td>Change To:</td>
			<td colspan="3">
				<input type="text" name="changeto" size="37" style="width:300;" onKeyPress="enable()">
			</td>
		</tr>
		<tr>
			<td>Suggestions:</td>
			<td width="150">
				<select name="suggest" size="7" style="width:150;" onChange="suggestClick()" onClick="suggestClick()" ondblclick="suggestClick();change_one();">
					<option>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
				</select>
			</td>
			<td>
				<input type="button" value="Ignore" width="90" style="width:90;" onClick="increment()"><br>
				<input type="Button" value="Change" width="90" style="width:90;" onClick="change_one()"><br>
				<input type="Button" value="Add" width="90" style="width:90;" name="addbtn" onClick="addword()">
			</td>
			<td>
				<input type="button" value="Ignore All" width="90" style="width:90;" onClick="ignore_all()"><br>
				<input type="Button" value="Change All" width="90" style="width:90;" onClick="change_all()"><br>
				<input type="Button" value="Suggest" width="90" style="width:90;" name="suggestbtn" onClick="suggester()">
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="3" align="right">
				<nobr>
				<input type="button" value="Done" width="90" style="width:90;" onClick="done();parent.close();">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="button" value="Cancel" width="90" style="width:90" onClick="parent.close();">
				</nobr>
			</td>
		</tr>
	</table>
	<textarea style="visibility:hidden" name="originalContent"><cfoutput>#spellCheckContent#</cfoutput></textarea>

</form>

</body>
</html>
