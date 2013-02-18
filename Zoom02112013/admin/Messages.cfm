<cfimport prefix="lh" taglib="../Lighthouse/Tags">
<cfset pg_title = "Messages">
<cfinclude template="../Lighthouse/Admin/Header.cfm">

<script type="text/javascript" src="/js/jquery-1.5.1.min.js"></script>
<script type="text/javascript">
function markAllReviewed(){
	$("input[type=checkbox][id^=Reviewed_]").attr("checked",true);
}
</script>


<cfif structKeyExists(url,"SendMessage") and structKeyExists(url,"MessageID")>
	<!--- Send Message --->
	<cfset message = createObject("component","cfc.Message").Init(url.MessageID)>
	<cfset message.Send()>
	<cflocation url="messages.cfm?action=Edit&pk=#url.MessageID#&statusMessage=Message+sent." addtoken="false">
</cfif>
	
<cfset persistentparams = "">
<cfset whereClause = "">
<cfset OrderBy = "Messages.DateAdded desc">
<cfset DefaultAction="Search">
<cfset IsReviewingSent = StructKeyExists(url,"ReviewingSent")>	
<cfset IsReviewingUnsent = StructKeyExists(url,"ReviewingUnsent") or StructKeyExists(url,"Reviewing")>
<cfset IsReviewing = IsReviewingSent or IsReviewingUnsent>
<cfif IsReviewingUnsent>
	<cfset persistentparams = "ReviewingUnsent=1">
	<cfset whereClause = "Reviewed = 0 AND IsSent = 0">
<cfelseif IsReviewingSent>
	<cfset persistentparams = "ReviewingSent=1">
	<cfset whereClause = "Reviewed = 0 AND IsSent = 1">
</cfif>
<cfif IsReviewing>
	<cfset OrderBy = "Messages.DateAdded">
	<cfset url.Reviewed_editCol = "1">
	<cfset DefaultAction="View">
</cfif>

<p>
	<cfif Not IsReviewing>
		Manage Messages
	<cfelse>
		<a href="messages.cfm">Manage Messages</a>
	</cfif>
	|
	<cfif IsReviewingSent>
		Review Sent Messages
	<cfelse>
		<a href="messages.cfm?ReviewingSent=1">Review Sent Messages</a>
	</cfif>
	|
	<cfif IsReviewingUnsent>
		Review Unsent Messages
	<cfelse>
		<a href="messages.cfm?ReviewingUnsent=1">Review Unsent Messages</a>
	</cfif>
</p>

<cfparam name="action" default="#defaultAction#">

<lh:MS_Table table="Messages" title="#pg_title#" OrderBy="#orderby#" persistentparams = "#persistentparams#"
	disallowedactions="Add" whereClause="#whereclause#" defaultAction=#defaultAction#>

	<lh:MS_TableColumn ColName="MessageID" DispName="ID" type="integer"	PrimaryKey="true" Identity="true" />
	<lh:MS_TableColumn ColName="Listing" type="pseudo" showonedit=true
		expression="(select '<a href=""Listings.cfm?action=Edit&pk=' + convert(varchar,listingID) + '"" target=_blank>' + title + '</a>' from listings where listingID = Messages.ListingID)" />
	<lh:MS_TableColumn ColName="FromAddress" DispName="From Address" type="text" editable=false />
	<lh:MS_TableColumn ColName="ToAddress" DispName="To Address" type="text" editable=false />
	<lh:MS_TableColumn ColName="Subject" type="text" editable=false />
	<lh:MS_TableColumn ColName="Message" type="text" editable=false />
	<lh:MS_TableColumn ColName="Attachments" type="text" editable=false view=false />
	<lh:MS_TableColumn ColName="DateAdded" DispName="Date Added" type="date" 
		showtime=true editable=false />
	<lh:MS_TableColumn ColName="IsSpam" DispName="Is Spam" type="checkbox" 
		onvalue=1 offvalue=0 />
	<cfif action is not "Edit">
		<lh:MS_TableColumn ColName="Reviewed" type="checkbox" 
			onvalue=1 offvalue=0 allowcolumnedit="#IsReviewing#" />
	</cfif>
	<lh:MS_TableColumn ColName="CFFormProtectPass" DispName="Passed CFFormProtect" type="checkbox" 
		view=false onvalue=1 offvalue=0 editable=false />
	<lh:MS_TableColumn ColName="DefensioPass" DispName="Passed Defensio" type="checkbox" 
		view=false onvalue=1 offvalue=0 editable=false />
	<lh:MS_TableColumn ColName="DefensioSpaminess" DispName="Defensio ""Spaminess""" type="float" 
		view=false editable=false />
	<lh:MS_TableColumn ColName="IsSent" DispName="Email Sent" type="checkbox" 
		onvalue=1 offvalue=0 editable=false />

	<lh:MS_TableEvent EventName="OnBeforeUpdate" Include="../../admin/Messages_onBeforeUpdate.cfm" />
	<lh:MS_TableEvent EventName="OnAfterUpdate" Include="../../admin/Messages_onAfterUpdate.cfm" />
	
	<cfif IsReviewing and action is "View">
		<lh:MS_TableAction ActionName="Mark All as Reviewed" Type="Custom" Href="javascript:markAllReviewed()" />
	</cfif>
	<lh:MS_TableRowAction ActionName="Send Message" Type="Custom" 
		Href="messages.cfm?SendMessage=1&MessageID=##pk##"
		Onclick="return confirm('Are you sure you want to send this message?')" />
</lh:MS_Table>

<cfinclude template="../Lighthouse/Admin/Footer.cfm">
