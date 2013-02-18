<cfparam name="InCart" default="0">
<cfparam name="HasOpenVPackages" default="0">
<cfparam name="InCartHAndRDisplayed" default="0">


<cfinclude template="ListingPackagesVQueries.cfm">

<cfoutput>
<cfif HasOpenVPackages and (not InCart or HasVListingsInCart)>
	<cfif InCart and not InCartHAndRDisplayed>	
		<br clear="all">
		<hr class="red" /> <br />
	</cfif>
	<div id="FBSO4Div">			
		<strong>Current Vehicle Listing Package:</strong><br>
		<cfloop query="getVListingPackages">
			<cfif ListingsInPackage lt ListingsPaidFor and (not Len(PaymentDate) or DateDiff("d",Now(),DateAdd("yyyy",1,PaymentDate)))>
				<cfif not Len(PaymentDate) or PaymentStatusID neq "2">
					<em>This order is still pending payment.</em><br />
				</cfif>
				<cfif ListingsPaidFor is "1000000">Unlimited<cfelse>#ListingsPaidFor#</cfif> Listings Paid For<br>
				#ListingsInPackage# Listing<cfif ListingsInPackage gt 1>s</cfif> Used | <cfif ListingsPaidFor is "1000000">Unlimited<cfelse>#VPackageListingsRemaining#</cfif> Listing<cfif VPackageListingsRemaining gt 1>s</cfif> Remaining<br>
				Package expires <cfif not Len(ExpirationDate)>1 year after payment is received.<cfelse>on: #DateFormat(ExpirationDate,'dd/mm/yyyy')#</cfif>
			</cfif>
		</cfloop>
	</div>
	<br clear="all">
	<hr class="red" /> <br />
<cfelseif not InCart>
	<div id="FSBO4Div">			
		Economically cross-market your vehicles on ZoomTanzania.com and have the ability to change your vehicle listing(s) info at any time 24/7.
		<p>
		<!--- 5 listings for #dollarFormat(getVListingPackageFees.FivePerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=V&Listings=5'" ><br />
		10 listings for #dollarFormat(getVListingPackageFees.TenPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=V&Listings=10'" ><br />
		20 listings for #dollarFormat(getVListingPackageFees.TwentyPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=V&Listings=20'" ><br /> --->
		Unlimited listings for #dollarFormat(getVListingPackageFees.UnlimitedPerYearFee)# <input type="button" value="Buy" class="btn" onClick="location.href='#lh_getPageLink(17,'buyalistingpackage')##AmpOrQuestion#ListingType=V&Listings=Unlimited'" ><br />
		</p>
	</div>
	<br clear="all">
	<hr class="red" /> <br />
</cfif>
</cfoutput>
