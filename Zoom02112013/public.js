/*
javascript required by site design
*/

function checkDateDDMMYYYY(fieldObj, s) {
	dateStr = fieldObj.value;
	if (isEmpty(dateStr)) return true;

	var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)((\d{2}|\d{4}))$/;
	var matchArray = dateStr.match(datePat); // is the format ok?
	if (matchArray == null) {
		return warnInvalid (fieldObj,"Value in field " + s + " must be in the form of dd/mm/yyyy.");
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


