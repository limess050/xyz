/*
	LeftCorner.js
	randy anderson (randerson@leftcorner.com)
	Code is free to use for any purpose
	
	Description:
	 	JavaScript equivilants of useful ColdFusion functions. 
		Refer to ColdFusion documentation for more information!	
		
	Notes: 
		Not for older browsers (JavaScript 1.5 for some methods)
		
		Quite a few methods depend on other methods. Be careful if you 
		remove/rename a method!
		
		DateDiff modified from function written by Rob Eberhardt, 
		Slingshot Solutions - http://slingfive.com/
		
		IsDate modified from function written by Craig H. Rettig, 
		Bit Bucket Heaven - http://www.bitbucketheaven.com/
		
		DollarFormat was modified from function called FormatCurrency 
		listed by multiple authors, could not locate the true author
		
		Round works slightly different in my implementation verses ColdFusion.
		ColdFusion only rounds whole numbers. LeftCorner.Round() allows 
		an optional argument of number of places to round decimals. For 
		example LeftCorner.Round(3.143,2) would return "3.14". ColdFusion would 
		return "3".
	
	Methods: 	
		Abs(number)
		ArrayAppend(array, value)
		ArrayLen(array)
		ArraySort(array, sort_type [, sort_order ])
		ArrayToList(array [, delimiter ])
		Ceiling(number)
		Compare(string1, string2)
		CompareNoCase(string1, string2)		
		DateDiff(datepart, date1, date2)
		DecimalFormat(number)
		DollarFormat(number)
		Find(substring, string)
		FindNoCase(substring, string)
		Insert(substring, string, position)
		IsDate(date)
		IsNumeric(string)
		LCase(string)
		Left(string, count)
		Len(sting)
		ListAppend(list, value, [, delimiters])
		ListDeleteAt(list, position [, delimiters ])
		ListFind(list, value [, delimiters ]))
		ListFindNoCase(list, value [, delimiters ]))
		ListGetAt(list, position [, delimiters ]))
		ListLen(list [, delimiters])
		ListToArray(list [, delimiters])
		LTrim(string)
		Mid(string, start, count)
		Replace(string, substring1, substring2 [, scope ])
		ReplaceNoCase(string, substring1, substring2 [, scope ])
		Reverse(string)
		Right(string, count)
		Round(number [, number of decimal places])
		RTrim(string)
		Trim(string)
		UCase(string)
		URLDecode(string)
		URLEncodedFormat(string)		
		
	Usage:
		Methods belong to object LeftCorner.
		Thus, to determine a string length with the Len()
		function as an example one would invoke the method like so:
		
		LeftCorner.Len("how long is this string?");
		
		The methods are designed to behave their ColdFusion 
		counterparts with one notable exception, method names are 
		case sensitive! 
		
		LeftCorner.LEN("Why don't I work?") will fail 
		as an example.
	
	Code Variable Abbreviations:
		a 		= array
		c 		= count
		d 		= delimiters
		d1,d2 	= date one, date two
		dp 		= date part
		i 		= index
		l 		= list
		n 		= number
		p 		= position
		r 		= return value/string/etc 
		s 		= string
		s1,s2 	= string one, string two
		sb 		= substring
		sb1,sb2	= substring one, substring two
		so 		= sort order
		st 		= sort type
		sc 		= scope
		v 		= value
*/
var LeftCorner = {
	_CommaForThousands: function(n){
			var r = n.slice(0, n.indexOf('.'));
			for (var i = 0; i < Math.floor((r.length-(1+i))/3); i++){
				r = n.substring(0,n.length-(4*i+3)) + ',' + n.substring(n.length-(4*i+3));
			}
			return r;
	},
	Abs: function(n){
		return Math.abs(n);
	},	
	ArrayAppend: function(a, v){
		a[a.length] = v;
		return a;
	},
	ArraySort: function(a,st,so){
		var _so;
		if (st.toUpperCase() == 'TEXTNOCASE'){ 
			if(!so || so.toUpperCase() != "DESC"){
				_so = function(a, b) {a = a.toUpperCase(); b = b.toUpperCase(); if (a < b){return -1;} else if(a > b){return 1;} else {return 0;}};
			} else {
				_so = function(a, b) {a = a.toUpperCase(); b = b.toUpperCase(); if (a > b){return -1;} else if(a < b){return 1;} else {return 0;}};
			}		
		} else if (st.toUpperCase() == 'TEXT'){ 
			if(!so || so.toUpperCase() != "DESC"){
				_so = function(a, b) {if (a < b){return -1;} else if(a > b){return 1;} else {return 0;}};
			} else {
				_so = function(a, b) {if (a > b){return -1;} else if(a < b){return 1;} else {return 0;}};
			}		
		} else if (st.toUpperCase() == 'NUMERIC'){
			if(!so || so.toUpperCase() != "DESC"){
				_so = function(a,b) {return a - b;};
			} else {
				_so = function(a,b) {return b - a;};
			}			
		}
		return a.sort(_so);
	},
	ArrayToList: function(a,d){
		if(!d){d = ",";}
		var re = /[,]/gi;
		return a.toString().replace(re, d);
	},
	ArrayLen: function(a){		
		return a.length;		
	},	
	Ceiling: function(n){
		return Math.ceil(n);
	},
	Compare: function(s1,s2){
		if (s1 == s2) {return 0;}
		if (s1 > s2) {return 1;}	
		else {return -1;}
	},
	CompareNoCase: function(s1,s2){
		return this.Compare(s1.toUpperCase(),s2.toUpperCase());
	},
	DateDiff: function(dp,d1,d2){
		var dt1 = new Date(d1);
		var dt2 = new Date(d2);
		var iDiffMS = dt2.valueOf() - dt1.valueOf();
		var dtDiff = new Date(iDiffMS);
		var nYears  = dt2.getUTCFullYear() - dt1.getUTCFullYear();
		var nMonths = dt2.getUTCMonth() - dt1.getUTCMonth() + (nYears!==0 ? nYears*12 : 0);
		var nQuarters = nMonths / 3;		
		var nMilliseconds = iDiffMS;
		var nSeconds = iDiffMS / 1000;
		var nMinutes = nSeconds / 60;
		var nHours = nMinutes / 60;
		var nDays  = nHours / 24;
		var nWeeks = nDays / 7;
		var iDiff = 0;		
		switch(dp.toLowerCase()){
			case "yyyy": return nYears;
			case "q": return nQuarters;
			case "m": return nMonths;
			case "y": return nDays;
			case "d": return nDays;
			case "w": return nDays;
			case "ww":return nWeeks;		
			case "h": return nHours;
			case "n": return nMinutes;
			case "s": return nSeconds;
			case "ms":return nMilliseconds;
			default: return "invalid interval: '" + dp + "'";
		}
	},
	DecimalFormat: function(n){ 
		var r = n.toFixed(2);
		var bp = this._CommaForThousands(r.slice(0, r.indexOf('.') + 1));
		var ap = this.Right(r,2);
		r = bp + '.' + ap;
		return r;
	},
	DollarFormat: function(n) {
		var _n = n.toString().replace(/\$|\,/g,'');
		_n = _n.toString().replace('(','-');
		_n = _n.toString().replace(')','');
		if(isNaN(_n)){
			_n = 0;
		}
		var	sign = (_n == (_n = Math.abs(n)));
			_n = Math.floor(_n*100+0.50000000001);
		var	cents = _n%100;
			_n = Math.floor(_n/100).toString();		
		if(cents < 10){
			cents = "0" + cents;
		}
		_n = this._CommaForThousands(_n);
		return (((sign)?'':'(') + '$' + _n + '.' + cents + ((sign)?'':')'));
	},
	Find: function(sb,s){
		 return s.toString().indexOf(sb) + 1;
	},
	FindNoCase: function(sb,s){		
		return this.Find(sb.toUpperCase(),s.toUpperCase());
	},
	Insert: function(sb,s,p){
		return s.slice(0, p) + sb + s.slice(p, s.length);
	},
	IsDate: function(d){
		var datePat 	= /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/;
		var matchArray 	= d.toString().match(datePat);	
		if (matchArray === null) {
			return false;
		}	
		var month 	= matchArray[1];
		var day 	= matchArray[3];
		var year 	= matchArray[5];	
		if (month < 1 || month > 12) { 
			return false;
		}	
		if (day < 1 || day > 31) {
			return false;
		}	
		if ((month==4 || month==6 || month==9 || month==11) && day==31) {
			return false;
		}	
		if (month == 2) { 
			var isleap = (year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0));
				if (day > 29 || (day==29 && !isleap)) {
					return false;
				}
		}
		return true; 
	},
	IsNumeric: function(s){
		if (isNaN(s)){
			return false;
		} else {
			return true;
		}
	},
	LCase: function(s){		
		return s.toLowerCase();			
	},
	Left: function(s,c){
		return s.slice(0, c);
	},	
	Len: function(s){		
		return s.length;
	},
	ListAppend: function(l, v, d){
		if(!d){d = ",";}
		var r = ""; 
		if (this.ListLen(l)){
			r = l + d + v;
		} else {
			r = v;
		}
		return r;
	},
	ListDeleteAt: function(l, p, d){
		if(!d){d = ",";}
		var i,posInList;
		var posInArray = p - 1;
		var thisD 	= "";
		var r = ""; 
		for(i = 0; i < l.split(d).length; i++){
			if (i != posInArray){
				posInList = i + 1;
				if (r.length){
					thisD 	= d;
				}
				r += thisD + this.ListGetAt(l, posInList, d);
			}
		}
		return r;
	},
	ListFind: function (l,v,d){
		if(!d){d = ",";}
		var r = 0;
		var listToArray = l.split(d);
		for (var i=0; i < listToArray.length; i++){		
			if (listToArray[i] == v){
				r = i + 1;
				break;
			}
		}
		return r;
	},
	ListFindNoCase: function(l,v,d){
		if(!d){d = ",";}
		return this.ListFind(l.toUpperCase(), v.toUpperCase(), d);
	},
	ListGetAt: function (l, p, d){
		if(!d){d = ",";}
		return l.split(d)[p - 1];
	},	
	ListLen: function(l,d){			
		if(!d){d = ",";}		
		return l.split(d).length;
	},	
	ListToArray: function(l,d){		
		var r,a,i;			
		if(!d){d = ",";}		
		r = [];
		a = l.split(d);			
		for(i=1; i <= a.length; i++){
			r[i] = a[i - 1];
		}			
		return r;	
	},
	LTrim: function(s){
		return s.toString().replace(/^\s*/, '');
	},	
	Mid: function(s, start, c){
		start -= 1;
		return s.slice(start,start + c);
	},
	Replace: function(s,sb1,sb2,sc){
		if(!sc || sc.toUpperCase() != "ALL"){
			sc = "";
		} else {
			sc ="g";
		} 	
		var re = new RegExp(sb1,sc);
		return s.replace(re,sb2);
	},
	ReplaceNoCase: function(s,sb1,sb2,sc){
		if(!sc || sc.toUpperCase() != "ALL"){
			sc = "i";
		} else {
			sc ="gi";
		} 	
		var re = new RegExp(sb1,sc);
		return s.replace(re,sb2);
	},
	Reverse: function(s){
		var i = s.length;
		var r = "";	
		for (i; 0 <= i; i--){	
			r += s.charAt(i);	
		}	
		return r;
	},
	Right: function(s,c){
		return s.slice(s.length - c, s.length);
	},
	Round: function(n,p) {
		if (!isNaN(n.toFixed(p))){
			return n.toFixed(p);
		} else {
			return n;
		}
	},
	RTrim: function(s){
		return s.toString().replace(/\s*$/, '');
	},
	Trim: function(s){
		return s.replace(/^\s*|\s*$/g,'');
	},
	UCase: function(s){		
		return s.toUpperCase();			
	},
	URLDecode: function(s){
		return unescape(s);
	},	
	URLEncodedFormat: function(s){
		return encodeURI(s);
	}
};