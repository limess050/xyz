<cfparam name="SubtotalAmount" default="0">
<cfparam name="SubtotalAmountIncludeELP" default="">

<!--- Calc VAT and round to cents --->
<cfset VAT=SubtotalAmount*0.18>
<cfset VAT=VAT*100>
<cfset VAT=Round(VAT)>
<cfset VAT=VAT/100>

<cfif Len(SubtotalAmountIncludeELP)>
	<cfset VATIncludeELP=SubtotalAmountIncludeELP*0.18>
	<cfset VATIncludeELP=VATIncludeELP*100>
	<cfset VATIncludeELP=Round(VATIncludeELP)>
	<cfset VATIncludeELP=VATIncludeELP/100>
</cfif>
