<cfparam name="ShowSaveForLater" default="1">
<cfparam name="ShowAddToCart" default="0">
<cfparam name="ShowListingPackageText" default="0">


<cfquery name="getPaymentMethods" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select PaymentMethodID as SelectValue, Title as SelectText
	From PaymentMethods
	Where PaymentMethodID <> 3
	Order By OrderNum
</cfquery>
<cfquery name="getCCExpireMonths" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select CCExpireMonth as SelectValue, Title as SelectText
	From CCExpireMonths
	Order By CCExpireMonth
</cfquery>
<cfquery name="getCCExpireYears" datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
	Select CCExpireYear as SelectValue, CCExpireYear as SelectText
	From CCExpireYears
	Order By CCExpireYear
</cfquery>
<cfoutput>
	<table width="650" border="0" cellspacing="0" cellpadding="0" class="datatable">
		<tr>
			<td colspan="2">
				<p>To finalize your listing submission, please hit "Submit" below.  If your fee is $0, you may disregard the payment method.</p>
			</td>
		</tr>
	  <tr>
	    <td width="60%" valign="top"><p><strong>Complete Payment Information</strong></p>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="datatable">
	        <tr>
	          <td>Fees Subtotal:</td>
	          <td>
			  	<span id="SubtotalAmountSpan">#DollarFormat(SubtotalAmount)#</span>
				<input type="hidden" name="SubtotalAmount" value="#SubtotalAmount#" ID="SubtotalAmount">
			  </td>
	        </tr>
	        <tr>
	          <td>VAT (18%):</td>
	          <td>
			  	<span id="VATAmountSpan">#DollarFormat(VAT)#</span>
				<input type="hidden" name="VAT" value="#VAT#" ID="VAT">
			  </td>
	        </tr>
	        <tr>
	          <td>Total Fees:</td>
	          <td>
			  	<span id="PaymentAmountSpan">#DollarFormat(PaymentAmount)#</span>
				<input type="hidden" name="PaymentAmount" value="#PaymentAmount#" ID="PaymentAmount">
			  </td>
	        </tr>
	        <tr>
	          <td>Payment Method:</td>
	          <td><label>
	            <select name="PaymentMethodID" id="PaymentMethodID" onChange="toggleCCRows();">
					<cfloop query="getPaymentMethods">
						<option value="#SelectValue#">#SelectText#
					</cfloop>
	            </select>
	          </label></td>
	        </tr>
	        <!--- <tr ID="CCardTR">
	          <td>Credit Card ##:</td>
	          <td><label>
	            <input name="CCNumber" type="text" id="CCNumber" size="25" maxlength="50" />
	          </label></td>
	        </tr>
	        <tr ID="CCardTR2">
	          <td>Credit Card Expiration Date:</td>
	          <td >
	            <select name="CCExpireMonth" id="CCExpireMonth">
					<cfloop query="getCCExpireMonths">
						<option value="#SelectValue#">#SelectText#
					</cfloop>
	            </select>
	            <select name="CCExpireYear" id="CCExpireYear">
					<cfloop query="getCCExpireYears">
						<option value="#SelectValue#">#SelectText#
					</cfloop>
	            </select>
	          </td>
	        </tr>
	        <tr ID="CCardTR3">
	          <td>CSV:<br />
	            <a href="#lh_getPageLink(13,'whatsacsv')#" target="_blank">What's a CSV?</a></td>
	          <td><input name="CSV" type="text" id="CSV" size="4" maxlength="5" /></td>
	        </tr> --->
	        <tr>
	          <!--- <td valign="top">&nbsp;</td> --->
	          <td valign="top" colspan="2" align="center"><label>
			  	<cfif ShowSaveForLater><input type="submit" name="SaveForLater" value="Save for Later" class="btn"></cfif>
	            		<cfif ShowAddToCart><input type="submit" name="SaveForLater" value="Add To Cart" class="btn"></cfif>
				<input type="submit" name="button" id="button" value="Submit" class="btn" />
	          </label></td>
	        </tr>
	      </table>
		  <!--- <script>
		  	function toggleCCRows() {
				if (document.f1.PaymentMethodID.selectedIndex==2) {
					$("##CCardTR").show();
					$("##CCardTR2").show();
					$("##CCardTR3").show();
				}
				else {					
					$("##CCardTR").hide();
					$("##CCardTR2").hide();
					$("##CCardTR3").hide();
				}
			}
			
			toggleCCRows()
		  </script> --->
	    </td>
	    <td width="40%" valign="top"><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>
	      <a href="howtopay" target="_blank">How To Pay</a>
	      <p>&nbsp;</p>
		</td>
	  </tr>
	</table>
</cfoutput>
