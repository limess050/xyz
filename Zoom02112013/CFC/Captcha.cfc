<cfcomponent hint="Adding captcha to forms" output="false">

	<cfsetting showdebugoutput="no">
	
	<cffunction name="Init" output="false">
		<cfargument name="id" type="string" default="">
		<cfargument name="autoload" type="boolean" default="true">
		<cfset this.id = arguments.id>
		<cfset this.autoload = arguments.autoload>
		<cfreturn this> 
	</cffunction>
	
	<cffunction name="GetCaptcha" output="false" returntype="string">	
		<cfset var CAPchars = "23456789ABCDEFGHJKMNPQRS">
		<cfset var CAPlength = 7>
		<cfset var CAPresult = "">
		<cfset var CAPi = "">
		<cfset var CAPchar = "">
		<cfscript>
			for(CAPi=1; CAPi <= CAPlength; CAPi++) {
				CAPchar = mid(CAPchars, randRange(1, len(CAPchars)),1);
				CAPresult&=CAPchar;
			}
		</cfscript>	
		
		<cfquery datasource="#request.dsn#">
			insert into captchas (captcha)
			values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#CAPresult#">)
		</cfquery>
		
	 	<cfreturn CAPresult>
	</cffunction>
	
	<cffunction name="CreateCaptcha" output=false access="remote" returntype="struct" displayname="Creates an image and a hashed form field">
		<cfset var cap = GetCaptcha()>
		<cfset var data = { "image" = "", "hash" = Hash(cap) }>	
		<cfsavecontent variable="data.image">
			<cfimage action="captcha" width="280" height="45" difficulty="medium" fonts="verdana,arial,times new roman,courier" fontsize="30" text="#cap#">
		</cfsavecontent>
	 	<cfreturn data>
	</cffunction>
	
	<cffunction name="RenderEntry" output="true">
		<input class="captcha-entry#this.id#" type="text" name="CaptchaEntry#this.id#" style="border:2px solid ##000">
		<input class="captcha-hash#this.id#" type="hidden" name="CaptchaHash#this.id#">
	</cffunction>
	
	<cffunction name="RenderImage" output="true">
		<span class="captcha-image#this.id#" style="width:280px;height:45"></span>
	</cffunction>

	<cffunction name="RenderRefreshButton" output="true">
		<cfargument name="text" type="string" required="true" >
		<span class="captcha-refresh#this.id#"><a href="javascript:void(0);">#arguments.text#</a></span>
	</cffunction>
	
	<cffunction name="RenderScripts" output="true">
		
		<script type="text/javascript">
			function captchaRefresh#this.id#() {
				var btn = this;
				$.ajax({
					type:"POST",
					dataType: "json",
					url:"#Request.HTTPSURL#/cfc/Captcha.cfc?method=CreateCaptcha&returnformat=json",
					success: function(data) {
						$(".captcha-image#this.id#").html(data.image);
						$(".captcha-hash#this.id#").val(data.hash);	
					}
				});	
			}	
			function captchaValidate#this.id#() {  
				var valid = true;     
				$.ajax({
					type:"POST",
					dataType: 'json',
					url:"#Request.HTTPSURL#/cfc/Captcha.cfc?method=Validate&returnformat=json",
					data:{
						CaptchaEntry: $(".captcha-entry#this.id#").val(),
						CaptchaHash: $(".captcha-hash#this.id#").val()
					},
					async: false,
					success: function(data){
						if (!data) {
							alert('The Match Text entered does not match the text  in the image. Please try again.');
							$(".captcha-entry#this.id#").focus();
							valid = false;
						}
					}
				});	
				return valid;
			}
			$(function(){
				$(".captcha-refresh#this.id#").click(captchaRefresh#this.id#)  
				<cfif this.autoload>
					captchaRefresh#this.id#();
				</cfif>
			})
		</script>
	</cffunction>

	<cffunction name="Use" output=false returntype="boolean">
		<!--- Delete used captcha and clear out old captchas --->
		<cfquery name="deleteCaptcha" datasource="#request.dsn#">
			delete from captchas 
			where captcha = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form['CaptchaEntry#this.id#']#">
				or  dateAdded < getdate()-1
		</cfquery>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="Validate" output=false access="remote" returntype="boolean" displayname="Takes entered text and hashed value and comparess them">
		<cfargument name="CaptchaEntry" type="string">
		<cfargument name="CaptchaHash" type="string">
		<cfif not structKeyExists(arguments,"CaptchaEntry")>
			<cfset arguments.CaptchaEntry = form['CaptchaEntry#this.id#']>
			<cfset arguments.CaptchaHash = form['CaptchaHash#this.id#']>
		</cfif>
		<cfif hash(ucase(arguments.CaptchaEntry)) is arguments.CaptchaHash>
			<cfquery name="getCap" datasource="#request.dsn#">
				select top 1 captcha from captchas 
				where captcha = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CaptchaEntry#"> 
			</cfquery>
			<cfif getCap.recordcount gt 0>
				<cfreturn true>
			</cfif>
		</cfif>    
		<cfreturn false>
	</cffunction>
	
</cfcomponent>