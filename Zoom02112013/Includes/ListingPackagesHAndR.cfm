<cfparam name="InCart" default="0">
<cfparam name="HasOpenHAndRPackages" default="0">


<cfinclude template="ListingPackagesHAndRQueries.cfm">

<cfoutput>
<cfif HasOpenHAndRPackages and (not InCart or HasHAndRListingsInCart)>
	<cfif InCart>		
		<br clear="all">
		<hr class="red" /> <br />
	</cfif>
	<div id="HR4Div">			
		<strong>Current Housing and Rental Listing Package:</strong><br>
		<cfloop query="getHRListingPackages">
			<cfif ListingsInPackage lt ListingsPaidFor and (not Len(PaymentDate) or DateDiff("d",Now(),DateAdd("yyyy",1,PaymentDate)))>
				<cfif not Len(PaymentDate) or PaymentStatusID neq "2">
					<em>This order is still pending payment.</em><br />
				</cfif>
				<cfif ListingsPaidFor is "1000000">Unlimited<cfelse>#ListingsPaidFor#</cfif> Listings Paid For<br>
				#ListingsInPackage# Listing<cfif ListingsInPackage gt 1>s</cfif> Used | <cfif ListingsPaidFor is "1000000">Unlimited<cfelse>#HAndRPackageListingsRemaining#</cfif> Listing<cfif HAndRPackageListingsRemaining gt 1>s</cfif> Remaining<br>
				Package expires <cfif not Len(ExpirationDate)>1 year after payment is received.<cfelse>on: #DateFormat(ExpirationDate,'dd/mm/yyyy')#</cfif>
			</cfif>
		</cfloop>
	</div>
	<br clear="all">
	<hr class="red" /> <br />
	<cfset InCartHAndRDisplayed="1">
<cfelseif not InCart>
	<div id="HR4Div">			
		Economically cross-market your properties on ZoomTanzania.com and have the ability to change your property listing(s) info at any time 24/7.
		<p>
		<!--- 5 listings for #dollarFormat(getHandRListingPackageFees.FivePerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=H&Listings=5'" ><br />
		10 listings for #dollarFormat(getHandRListingPackageFees.TenPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=H&Listings=10'" ><br />
		20 listings for #dollarFormat(getHandRListingPackageFees.TwentyPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=H&Listings=20'" ><br /> --->
		Unlimited listings for #dollarFormat(getHandRListingPackageFees.UnlimitedPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=H&Listings=Unlimited'" ><br />
		</p>
	</div>
	<br clear="all">
	<hr class="red" /> <br />
</cfif>
</cfoutput>
