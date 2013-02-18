<cfscript>
function GetNthOccOfDayInMonth(NthOccurrence,TheDayOfWeek,TheMonth,TheYear)
{
Var TheDayInMonth=0;
if(TheDayOfWeek lt DayOfWeek(CreateDate(TheYear,TheMonth,1))){
TheDayInMonth= 1 + NthOccurrence*7 + (TheDayOfWeek - DayOfWeek(CreateDate(TheYear,TheMonth,1))) MOD 7;
}
else{
TheDayInMonth= 1 + (NthOccurrence-1)*7 + (TheDayOfWeek - DayOfWeek(CreateDate(TheYear,TheMonth,1))) MOD 7;
}
//If the result is greater than days in month or less than 1, return -1
if(TheDayInMonth gt DaysInMonth(CreateDate(TheYear,TheMonth,1)) OR TheDayInMonth lt 1){
return -1;
}
else{
return TheDayInMonth;
}
}

</cfscript>