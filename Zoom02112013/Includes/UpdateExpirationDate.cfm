NO LONGER IN USE<br>
includes/UpdateExpirationDate.cfm<cfabort>
<cfif not IsDefined('ListingIDToUpdate') and IsDefined('ListingID') and ListLen(ListingID) is 1>
	<cfset ListingIDToUpate=ListingID>
</cfif>
<cfquery name="CalculateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	SELECT CASE 
		WHEN EXISTS
			(SELECT ListingRenewalID
        	FROM ListingRenewals LEFT OUTER JOIN
        	Orders ON ListingRenewals.OrderID = Orders.OrderID
        	WHERE ListingRenewals.ListingID = L.ListingID AND ((Orders.PaymentStatusID = 2 AND Orders.PaymentDate IS NOT NULL) 
			OR ListingRenewals.OrderID IS NULL)) 
		THEN DateAdd(day, LT.TermExpiration *
            (SELECT COUNT(ListingRenewalID) + 1
			FROM ListingRenewals LEFT OUTER JOIN Orders ON ListingRenewals.OrderID = Orders.OrderID
            WHERE ListingRenewals.ListingID = L.ListingID AND ((Orders.PaymentStatusID = 2 AND Orders.PaymentDate IS NOT NULL) 
			OR ListingRenewals.OrderID IS NULL)), 
				CASE WHEN O.PaymentStatusID = 2 AND O.PaymentDate IS NOT NULL 
                THEN O.PaymentDate ELSE L.DateListed END) 
		WHEN O.PaymentStatusID = 2 AND O.PaymentDate IS NOT NULL AND L.Reviewed = 1
		THEN DateAdd(day, LT.TermExpiration, O.PaymentDate) 
		WHEN L.OrderID IS NULL AND L.InProgress = 0 AND L.DateListed IS NOT NULL AND L.Reviewed = 1 
		THEN DateAdd(day, LT.TermExpiration, L.DateListed) 
		ELSE NULL END AS ExpirationDate
	FROM Listings L 
	LEFT OUTER JOIN Orders O ON L.OrderID = O.OrderID 
	LEFT OUTER JOIN ListingTypes LT ON L.ListingTypeID = LT.ListingTypeID
	Where L.ListingID = <cfqueryparam value="#ListingIDToUpate#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfquery name="updateExpirationDate" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Update Listings
	Set ExpirationDate=<cfqueryparam value="#CalculateExpirationDate.ExpirationDate#" cfsqltype="CF_SQL_DATE" null="#NOT LEN(CalculateExpirationDate.ExpirationDate)#">
	Where ListingID = <cfqueryparam value="#ListingIDToUpate#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
		