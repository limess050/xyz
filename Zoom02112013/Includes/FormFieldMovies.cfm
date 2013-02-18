<cfparam name="attributes.Action" default="Form">
<cfset Action= attributes.Action>

			<cfparam name="ImgPathDir" default="#request.ListingImagesDir#">



<cfif Action is "Form">	
	
	
	<cfquery name="getMovies"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Select LM.ListingMovieID, LM.Title as MovieTitle, LM.Starring, LM.NowPlayingID, 
		LM.DailyShowTimes, LM.OtherShowTimes, LM.Saturdays, LM.Sundays, LM.Holidays,
		LM.DirectedBy, LM.Descr, LM.OfficialURL, LM.YahooURL, LM.IMDBURL, 
		LM.MovieImage, LM.OrderNum
		From ListingMovies LM
		Inner Join Listings L on LM.ListingID=L.ListingID
		Where L.LinkID = <cfif Len(LinkID)><cfqueryparam value="#LinkID#" cfsqltype="CF_SQL_VARCHAR"><cfelse>'0'</cfif>
		Order By LM.OrderNum
	</cfquery>
	<cfif not getMovies.RecordCount>
		<cfset MovieCount = "1">
	<cfelse>
		<cfset MovieCount = getMovies.RecordCount>
	</cfif>	
	<cfsavecontent variable="MovieSet">
	
		<tbody id="Movie_0">
			<tr>
				<td class="rightAtd">
					* Movie Name:
				</td>
				<td>
					<input name="MovieTitle_0" id="MovieTitle_0" value="">
					<input type="hidden" name="MovieOrderNum_0" id="MovieOrderNum_0" value="1">
					<button style="float:right" id="DeleteMovie_0" class="DeleteMovie redButton">Delete this movie listing</button>
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Starring:
				</td>
				<td>
					<input name="MovieStarring_0" id="MovieStarring_0" value="">
					<button style="float:right" id="MoveUpMovie_0" class="MoveUpMovie">Move Up</button>
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					* Now Playing:
				</td>
				<td>
					<input name="MovieNowPlaying_0" id="MovieNowPlaying_1_0" type="radio" value="1" class="NowPlayingOption">Now Playing&nbsp;&nbsp;&nbsp;
					<input name="MovieNowPlaying_0" id="MovieNowPlaying_2_0" type="radio" value="2" class="NowPlayingOption">Coming Soon
					<button style="float:right" id="MoveDownMovie_0" class="MoveDownMovie">Move Down</button>
				</td>
			</tr>
			<tr class="NowPlayingOnly_0">
				<td class="rightAtd">
					Daily Show Times:
				</td>
				<td>
					<input name="MovieDailyShowTimes_0" id="MovieDailyShowTimes_0" value="">
				</td>
			</tr>
			<tr class="NowPlayingOnly_0">
				<td class="rightAtd">
					Other Show Times:
				</td>
				<td>
					<input name="MovieOtherShowTimes_0" id="MovieOtherShowTimes_0" value=""><br><br>
					<input type="checkbox" name="MovieSaturdays_0" id="MovieSaturdays_0" value="1"> Saturdays &nbsp;&nbsp;&nbsp;
					<input type="checkbox" name="MovieSundays_0" id="MovieSundays_0" value="1"> Sundays &nbsp;&nbsp;&nbsp;
					<input type="checkbox" name="MovieHolidays_0" id="MovieHolidays_0" value="1"> Holidays
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Directed By:
				</td>
				<td>
					<input name="MovieDirectedBy_0" id="MovieDirectedBy_0" value="">
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Movie Description:
				</td>
				<td>
					<textarea name="MovieDescr_0" id="MovieDescr_0"></textarea>
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Movie Image:
				</td>
				<td>
					<input name="MovieImage_0" id="MovieImage_0" type="file">
					<input type="hidden" name="MovieImageExisting_0" id="MovieImageExisting_0" value="">
					<span id="MovieImageSpan_0" style="float:right;"></span>
				</td>
			</tr>
			<tr>
				<td class="rightAtd">
					Reviews/More Info:
				</td>
				<td valign="top">
					<table>
						<tr>
							<td style="padding-top: 0px;">
								Official Site:
							</td>
							<td style="padding-top: 0px;">
								<input name="MovieOfficialURL_0" id="MovieOfficialURL_0" value="">
							</td>
						</tr>
						<tr>
							<td>
								Yahoo! Movie Review:
							</td>
							<td>
								<input name="MovieYahooURL_0" id="MovieYahooURL_0" value="">
							</td>
						</tr>
						<tr>
							<td>
								IMDB Review:
							</td>
							<td>
								<input name="MovieIMDBURL_0" id="MovieIMDBURL_0" value="">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<hr>
				</td>
			</tr>
		</tbody>
	</cfsavecontent>
	<!--- <cfset MovieSetJS = JSStringFormat(REReplace(MovieSet ,"#chr(13)#|#chr(9)#|\n|\r","","ALL"))> --->
	
	<script>
		$(function(){	
			<cfoutput>
				var MovieCount=#MovieCount#;
				var MovieSetJS = '#JSStringFormat(REReplace(MovieSet ,"#chr(13)#|#chr(9)#|\n|\r","","ALL"))#';
				$("##AddMovie").click(function() {
					var NewMovieCount=MovieCount+1;
					var NewMovieSet=MovieSetJS.replace(/_0/g,"_" + NewMovieCount);
					$("##Movie_" + MovieCount).after(NewMovieSet);
					$("##MovieOrderNum_" + NewMovieCount).val(NewMovieCount);
					MovieCount=MovieCount + 1;
					$("##MovieCount").val(MovieCount);
					return false;
				});
				$(".DeleteMovie").live('click',function(){	
					if (confirm('Are you sure you want to delete this movie?')){	
						MovieCounter = $(this).attr('id').replace("DeleteMovie_","");
						$("##Movie_" + MovieCounter).remove();
					}
					return false;
				});
				$(".MoveUpMovie").live('click',function(){	
					MovieCounter = $(this).attr('id').replace("MoveUpMovie_","");
					MovieOrderVal = $("##MovieOrderNum_" + MovieCounter).val();
					prevBody = $(this).parent().parent().parent().prev().attr('id');
					if (prevBody!=''){
						prevCounter = prevBody.replace("Movie_","");
						prevOrderVal = $("##MovieOrderNum_" + prevCounter).val();
						$("##MovieOrderNum_" + prevCounter).val(MovieOrderVal);
						$("##MovieOrderNum_" + MovieCounter).val(prevOrderVal);
						$(this).parent().parent().parent().insertBefore($(this).parent().parent().parent().prev());
					}
					return false;
				});
				$(".MoveDownMovie").live('click',function(){	
					MovieCounter = $(this).attr('id').replace("MoveDownMovie_","");
					MovieOrderVal = $("##MovieOrderNum_" + MovieCounter).val();
					nextBody = $(this).parent().parent().parent().next().attr('id');
					if (nextBody!=''){
						nextCounter = nextBody.replace("Movie_","");
						nextOrderVal = $("##MovieOrderNum_" + nextCounter).val();
						$("##MovieOrderNum_" + nextCounter).val(MovieOrderVal);
						$("##MovieOrderNum_" + MovieCounter).val(nextOrderVal);
						$(this).parent().parent().parent().insertAfter($(this).parent().parent().parent().next());
					}
					return false;
				});
				$(".NowPlayingOption").live('click',function(){	
					MovieCounter = $(this).attr('name').replace("MovieNowPlaying_","");
					MovieNowPlayingVal = $(this).val();
					if (MovieNowPlayingVal==1) {
						//show fields	
						showNPFields(MovieCounter);	
					}
					else if (MovieNowPlayingVal==2) {
						//hide fields and clear them 
						hideNPFields(MovieCounter);
					}
				});
				function showNPFields(x){
					$(".NowPlayingOnly_" + x).show('slow');
				}
				function hideNPFields(x){
					$(".NowPlayingOnly_" + x).hide('slow');
					$("##MovieDailyShowTimes_" + x).val('');
					$("##MovieOtherShowTimes_" + x).val('');
					$("##MovieSaturdays_" + x).attr('checked',false);
					$("##MovieSundays_" + x).attr('checked',false);
					$("##MovieHolidays_" + x).attr('checked',false);
				}
			</cfoutput>
			<cfoutput query="getMovies">
					$("##MovieTitle_" + #CurrentRow#).val('#JSStringFormat(MovieTitle)#');
					$("##MovieStarring_" + #CurrentRow#).val('#JSStringFormat(Starring)#');
					<cfif NowPlayingID is "1">
						$("##MovieNowPlaying_1_" + #CurrentRow#).attr('checked','checked');
					<cfelse>
						$("##MovieNowPlaying_2_" + #CurrentRow#).attr('checked','checked');
						$(".NowPlayingOnly_" + #CurrentRow#).hide();
					</cfif>
					$("##MovieDailyShowTimes_" + #CurrentRow#).val('#JSStringFormat(DailyShowTimes)#');
					$("##MovieOtherShowTimes_" + #CurrentRow#).val('#JSStringFormat(OtherShowTimes)#');
					<cfif Saturdays is "1">
						$("##MovieSaturdays_" + #CurrentRow#).attr('checked','checked');
					</cfif>
					<cfif Sundays is "1">
						$("##MovieSundays_" + #CurrentRow#).attr('checked','checked');
					</cfif>
					<cfif Holidays is "1">
						$("##MovieHolidays_" + #CurrentRow#).attr('checked','checked');
					</cfif>
					$("##MovieDirectedBy_" + #CurrentRow#).val('#JSStringFormat(DirectedBy)#');
					$("##MovieDescr_" + #CurrentRow#).val('#JSStringFormat(Descr)#');
					$("##MovieOfficialURL_" + #CurrentRow#).val('#JSStringFormat(OfficialURL)#');
					$("##MovieYahooURL_" + #CurrentRow#).val('#JSStringFormat(YahooURL)#');
					$("##MovieIMDBURL_" + #CurrentRow#).val('#JSStringFormat(IMDBURL)#');
					$("##MovieOrderNum_" + #CurrentRow#).val('#JSStringFormat(OrderNum)#');
					$("##MovieImageExisting_" + #CurrentRow#).val('#JSStringFormat(MovieImage)#');
					<cfif Len(MovieImage)>
						$("##MovieImageSpan_" + #CurrentRow#).html('<img src="../ListingImages/#JSStringFormat(MovieImage)#" width="90">');
					</cfif>
			</cfoutput>
		});	
	</script>
		
	<tr>
		<td colspan="2">
			Movie Listing and Times:
			<cfoutput><input type="hidden" name="MovieCount" id="MovieCount" value="#MovieCount#"></cfoutput>
		</td>
	</tr>
	
	<cfif not getMovies.RecordCount>
		<cfoutput>#Replace(MovieSet,"_0","_1","ALL")#</cfoutput>
	<cfelse>
		<cfoutput query="getMovies">
			#Replace(MovieSet,"_0","_#CurrentRow#","ALL")#
		</cfoutput>
	</cfif>
	<tr>
		<td class="rightAtd">&nbsp;</td>
		<td>
			<button id="AddMovie">Add another movie</button>
		</td>
	</tr>
	
	
	
<cfelseif Action is "Process">
	<!--- Delete existing records --->
	<cfquery name="deleteListingMovies"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
		Delete From ListingMovies
		Where ListingID=<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<!--- Add new records --->
	<cfloop from="1" to="#Caller.MovieCount#" index="i">
		<cfif IsDefined('caller.MovieTitle_#i#')>
			<cfif Len('#Evaluate("MovieImage_" & i)#')><!--- New Image Uploaded ---><!--- <cfoutput>~#Evaluate("MovieImage_" & i)#~</cfoutput><cfabort> --->
				<cfif Len('MovieImageExisting_#i#') and FileExists("#ImgPathDir#\#Evaluate('MovieImageExisting_' & i)#")>
					<cffile action="Delete" file="#ImgPathDir#\#Evaluate('MovieImageExisting_' & i)#">
				</cfif>
				<cfset IsMovieImage = "1">
				<cfset FieldName="MovieImage_#i#">
				<cfinclude template="uploadImage.cfm">
			<cfelseif Len('MovieImageExisting_#i#')><!--- No new image uploaded, but already has existing image --->
				<cfset NewFileName = Evaluate('MovieImageExisting_' & i)>
			<cfelse><!--- No new image uploaded, and no existing image --->
				<cfset NewFileName = "">
			</cfif>
			<cfquery name="insertListingMovie"  datasource="#Request.dsn#" username="#Request.dbusername#" password="#Request.dbpassword#">
				Insert into ListingMovies
				(ListingID, Title, Starring, NowPlayingID, DailyShowTimes, OtherShowTimes, Saturdays, Sundays, Holidays, 
				DirectedBy, Descr, OfficialURL, YahooURL, IMDBURL, OrderNum, MovieImage)
				VALUES
				(<cfqueryparam value="#caller.ListingID#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#Evaluate('caller.MovieTitle_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieStarring_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieNowPlaying_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieDailyShowTimes_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieOtherShowTimes_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif IsDefined('MovieSaturdays_#i#')>1<cfelse>0</cfif>,
				<cfif IsDefined('MovieSundays_#i#')>1<cfelse>0</cfif>,
				<cfif IsDefined('MovieHolidays_#i#')>1<cfelse>0</cfif>,
				<cfqueryparam value="#Evaluate('caller.MovieDirectedBy_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieDescr_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieOfficialURL_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieYahooURL_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieIMDBURL_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#Evaluate('caller.MovieOrderNum_' & i)#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#newFileName#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		</cfif>
	</cfloop>
<cfelseif Action is "Validate">	
	for(var i=0; i<$("#MovieCount").val(); i++) {
		mvCounter=i+1;
		if ($("#MovieTitle_" + mvCounter).val()=='') {
			alert('Movie # ' + mvCounter + ' Title is required. Please enter a value now');
			$("#MovieTitle_" + mvCounter).focus();
			return false;
		}
		if ($("#MovieNowPlaying_1_" + mvCounter).attr('checked')==false && $("#MovieNowPlaying_2_" + mvCounter).attr('checked')==false) {
			alert('Movie # ' + mvCounter + ' Now Playing is required. Please select a value now.');
			$("#MovieNowPlaying_1_" + mvCounter).focus();
			return false;
		}
		if ($("#MovieNowPlaying_1_" + mvCounter).attr('checked')==true) {
			if (!$("#MovieDailyShowTimes_" + mvCounter).val() && !$("#MovieOtherShowTimes_" + mvCounter).val()){
				alert('Movie # ' + mvCounter + '  - Either Daily or Other Showtimes is required. Please enter a value now.');
				$("#MovieDailyShowTimes_" + mvCounter).focus();
				return false;
			}
		}
	}
</cfif>
