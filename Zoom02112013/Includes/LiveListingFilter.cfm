<cfoutput>
and L.Active=1

and L.Reviewed=1 

and L.DeletedAfterSubmitted=0 

and (L.Deadline is null or L.Deadline >= #application.CurrentDateInTZ#)

AND (L.ListingTypeID <> 15
	OR EXISTS (SELECT ListingID FROM ListingEventDays with (NOLOCK) WHERE ListingID=L.ListingID 
			AND ListingEventDate >= #application.CurrentDateInTZ#))		
			
and (L.ListingTypeID IN (1,2,14,15) or (L.ExpirationDate >= #application.CurrentDateInTZ# and L.PaymentStatusID in (2,3)))
and L.Blacklist_fl = 0
</cfoutput>