<%@ Page Language="C#" CodeFile="MailEdit.aspx.cs" Inherits="MailTracking.MailEdit" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Mail Tracking System - Mail Edit</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR" />
    <meta content="C#" name="CODE_LANGUAGE" />
    <meta content="JavaScript" name="vs_defaultClientScript" />
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
    <link href="StyleSheet.css" type="text/css" rel="stylesheet" />
    <link type="text/css" href="styles/redmond/jquery-ui-1.8.18.custom.css" rel="stylesheet" />
    <link rel="Shortcut Icon" href="MailIcon.ico" type="application/x-icon"  />
    <script type="text/javascript"></script>
    
    <!--#include file="UpdateComboDatePickerDays.js" -->
    <!--#include file="UnambiguousDateFormat.js" -->

    
    <script src="scripts/jquery-1.7.1.min.js"></script>

    <script src="scripts/jquery-ui-1.8.18.custom.min.js"></script>

    <script language="javascript">
			function showPopupCalendar(form, dayCbo, monthCbo, yearCbo)
			{
				childWindow = window.open('PopupCalendar.aspx?Date=' + dayCbo.value + '-' + monthCbo.value + '-' + yearCbo.value + "&Form=" + form.name + "&DayCbo=" + dayCbo.name + "&MonthCbo=" + monthCbo.name + "&YearCbo=" + yearCbo.name, "PopupCalendar", "width=280, height=200, top=100, left=100, toolbars=no, scrollbars=no, status=no, resizable=no");
			}
			
	(function($){
    $.widget( "ui.combobox", $.ui.autocomplete, 
        {
        options: { 
            /* override default values here */
            minLength: 2,
            /* the argument to pass to ajax to get the complete list */
            ajaxGetAll: {get: "all"}
        },

        _create: function(){
            if (this.element.is("SELECT")){
                this._selectInit();
                return;
            }

            $.ui.autocomplete.prototype._create.call(this);
            var input = this.element;
            input.addClass( "ui-widget ui-widget-content ui-corner-left" );

            this.button = $( "<button type='button'>&nbsp;</button>" )
            .attr( "tabIndex", -1 )
            .attr( "title", "Show All Items" )
            .insertAfter( input )
            .button({
                icons: { primary: "ui-icon-triangle-1-s" },
                text: false
            })
            .removeClass( "ui-corner-all" )
            .addClass( "ui-corner-right ui-button-icon" )
            .click(function(event) {
                // close if already visible
                if ( input.combobox( "widget" ).is( ":visible" ) ) {
                    input.combobox( "close" );
                    return;
                }
                // when user clicks the show all button, we display the cached full menu
                var data = input.data("combobox");
                clearTimeout( data.closing );
                if (!input.isFullMenu){
                    data._swapMenu();
                    input.isFullMenu = true;
                }
                /* input/select that are initially hidden (display=none, i.e. second level menus), 
                   will not have position cordinates until they are visible. */
                input.combobox( "widget" ).css( "display", "block" )
                .position($.extend({ of: input },
                    data.options.position
                    ));
                input.focus();
                data._trigger( "open" );
            });

            /* to better handle large lists, put in a queue and process sequentially */
            $(document).queue(function(){
                var data = input.data("combobox");
                if ($.isArray(data.options.source)){ 
                    $.ui.combobox.prototype._renderFullMenu.call(data, data.options.source);
                }else if (typeof data.options.source === "string") {
                    $.getJSON(data.options.source, data.options.ajaxGetAll , function(source){
                        $.ui.combobox.prototype._renderFullMenu.call(data, source);
                    });
                }else {
                    $.ui.combobox.prototype._renderFullMenu.call(data, data.source());
                }
            });
        },

        /* initialize the full list of items, this menu will be reused whenever the user clicks the show all button */
        _renderFullMenu: function(source){
            var self = this,
                input = this.element,
                ul = input.data( "combobox" ).menu.element,
                lis = [];
            source = this._normalize(source); 
            input.data( "combobox" ).menuAll = input.data( "combobox" ).menu.element.clone(true).appendTo("body");
            for(var i=0; i<source.length; i++){
                lis[i] = "<li class=\"ui-menu-item\" role=\"menuitem\"><a class=\"ui-corner-all\" tabindex=\"-1\">"+source[i].label+"</a></li>";
            }
            ul.append(lis.join(""));
            this._resizeMenu();
            // setup the rest of the data, and event stuff
            setTimeout(function(){
                self._setupMenuItem.call(self, ul.children("li"), source );
            }, 0);
            input.isFullMenu = true;
        },

        /* incrementally setup the menu items, so the browser can remains responsive when processing thousands of items */
        _setupMenuItem: function( items, source ){
            var self = this,
                itemsChunk = items.splice(0, 500),
                sourceChunk = source.splice(0, 500);
            for(var i=0; i<itemsChunk.length; i++){
                $(itemsChunk[i])
                .data( "item.autocomplete", sourceChunk[i])
                .mouseenter(function( event ) {
                    self.menu.activate( event, $(this));
                })
                .mouseleave(function() {
                    self.menu.deactivate();
                });
            }
            if (items.length > 0){
                setTimeout(function(){
                    self._setupMenuItem.call(self, items, source );
                }, 0);
            }else { // renderFullMenu for the next combobox.
                $(document).dequeue();
            }
        },

        /* overwrite. make the matching string bold */
        _renderItem: function( ul, item ) {
            var label = item.label.replace( new RegExp(
                "(?![^&;]+;)(?!<[^<>]*)(" + $.ui.autocomplete.escapeRegex(this.term) + 
                ")(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>" );
            return $( "<li></li>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + label + "</a>" )
                .appendTo( ul );
        },

        /* overwrite. to cleanup additional stuff that was added */
        destroy: function() {
            if (this.element.is("SELECT")){
                this.input.remove();
                this.element.removeData().show();
                return;
            }
            // super()
            $.ui.autocomplete.prototype.destroy.call(this);
            // clean up new stuff
            this.element.removeClass( "ui-widget ui-widget-content ui-corner-left" );
            this.button.remove();
        },

        /* overwrite. to swap out and preserve the full menu */ 
        search: function( value, event){
            var input = this.element;
            if (input.isFullMenu){
                this._swapMenu();
                input.isFullMenu = false;
            }
            // super()
            $.ui.autocomplete.prototype.search.call(this, value, event);
        },

        _change: function( event ){
            abc = this;
            if ( !this.selectedItem ) {
                var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( this.element.val() ) + "$", "i" ),
                    match = $.grep( this.options.source, function(value) {
                        return matcher.test( value.label );
                    });
                if (match.length){
                    match[0].option.selected = true;
                }else {
                    // remove invalid value, as it didn't match anything
                    this.element.val( "" );
                    if (this.options.selectElement) {
                        this.options.selectElement.val( "" );
                    }
                }
            }                
            // super()
            $.ui.autocomplete.prototype._change.call(this, event);
        },

        _swapMenu: function(){
            var input = this.element, 
                data = input.data("combobox"),
                tmp = data.menuAll;
            data.menuAll = data.menu.element.hide();
            data.menu.element = tmp;
        },

        /* build the source array from the options of the select element */
        _selectInit: function(){
            var select = this.element.hide(),
            selected = select.children( ":selected" ),
            value = selected.val() ? selected.text() : "";
            this.options.source = select.children( "option[value!='']" ).map(function() {
                return { label: $.trim(this.text), option: this };
            }).toArray();
            var userSelectCallback = this.options.select;
            var userSelectedCallback = this.options.selected;
            this.options.select = function(event, ui){
                ui.item.option.selected = true;
                if (userSelectCallback) userSelectCallback(event, ui);
                // compatibility with jQuery UI's combobox.
                if (userSelectedCallback) userSelectedCallback(event, ui);
            };
            this.options.selectElement = select;
            this.input = $( "<input>" ).insertAfter( select )
                .val( value ).combobox(this.options);
        }
    }
);
})(jQuery);

	$(function() {
		$( "#addresseeDropDownList,#mailSenderDropDownList").combobox();
		$( "#toggle" ).click(function() {
			$( "#combobox" ).toggle();
		});
		//this or in chage event
		
		
	});		

	



    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="fullPage">
            <!--#include file="Header.html" -->
            <!--#include file="NavigationMenu.html" -->
            <div class="mainPage" style="border-right: silver thin solid; border-top: silver thin solid;
                border-left: silver thin solid; border-bottom: silver thin solid">
                <div class="titleRow">
                    <div class="titleRowLeft">
                        <asp:Label ID="pageTitle" runat="server">Title</asp:Label>
                    </div>
                </div>
                <asp:ValidationSummary ID="validationSummary" runat="server" Width="98%" CssClass="summary"
                    HeaderText="The operation could not be performed because:"></asp:ValidationSummary>
                <div id="mailPanel" runat="server">
                    <div>
                        <asp:CustomValidator ID="detailsChangedCustomValidator" runat="server" ErrorMessage='Please Save or Undo the changes before Viewing Referrals.'
                            OnServerValidate="detailsChangedCustomValidator_ServerValidate" Width="13px">&nbsp;</asp:CustomValidator>
                        <asp:CustomValidator ID="changesMadeByOtherUserCustomValidator" runat="server" ErrorMessage=" Changes have been made to this Mail Item by another user since you began working on it. If still wish to update this item Please press the Cancel Button and reselect from the list."
                            OnServerValidate="changesMadeByOtherUserCustomValidator_ServerValidate">&nbsp;</asp:CustomValidator>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="addresseeLabel" runat="server">*Addressee*:</asp:Label></div>
                            <div class="controlRowColumn2Of4 ui-widget">
                                <asp:DropDownList ID="addresseeDropDownList" runat="server" Width="80%">
                                    <asp:ListItem></asp:ListItem>
                                </asp:DropDownList>&nbsp;<asp:Button ID="showAddresseeDialog" runat="server" OnClick="showAddresseeDialog_Click"
                                    Text="..." CausesValidation="False" CssClass="button" />
                            </div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="fileReferenceLabel" runat="server">*File Reference*:</asp:Label></div>
                            <div class="controlRowColumn4Of4">
                                <asp:TextBox ID="fileReference" runat="server" Width="150px"></asp:TextBox></div>
                            <%--<div class="controlRowColumn3Of4"><asp:Label ID="fileReferenceLabel" runat="server">*File Reference*:</asp:Label></div>
                        <div class="controlRowColumn4Of4"><asp:TextBox ID="fileReference" runat="server" Width="150px"></asp:TextBox></div>--%>
                        </div>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="mailSenderLabel" runat="server">*Mail Sender*:</asp:Label><asp:RequiredFieldValidator
                                    ID="mailSenderRequiredFieldValidator" runat="server" ControlToValidate="mailSenderDropDownList"
                                    ErrorMessage="The *Mail Sender* cannot be blank.">*</asp:RequiredFieldValidator></div>
                            <div class="controlRowColumn2Of4 ui-widget">
                                <asp:DropDownList ID="mailSenderDropDownList" runat="server" Width="80%" AutoPostBack="true" OnSelectedIndexChanged="mailSenderDropDownList_SelectedIndexChanged">
                                    <asp:ListItem></asp:ListItem>
                                </asp:DropDownList>&nbsp;<asp:Button ID="showMailSenderDialog" runat="server" CausesValidation="False"
                                    CssClass="button" OnClick="showMailSenderDialog_Click" Text="..." />
                            </div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="reference1Label" runat="server">*Reference 1*:</asp:Label></div>
                            <div class="controlRowColumn4Of4">
                                <asp:TextBox ID="reference1" runat="server" Width="150px"></asp:TextBox></div>
                            <%--<div class="controlRowColumn3Of4"><asp:Label ID="reference1Label" runat="server">*Reference 1*:</asp:Label><asp:RequiredFieldValidator ID="reference1RequiredFieldValidator" runat="server" ControlToValidate="reference1" ErrorMessage="The *Reference 1* cannot be blank.">*</asp:RequiredFieldValidator></div>
                        <div class="controlRowColumn4Of4"><asp:TextBox ID="reference1" runat="server" BackColor="LightCyan" Width="150px"></asp:TextBox></div>--%>
                        </div>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="mailSenderAddressLabel" runat="server" Visible="false">*Mail Sender* Address:</asp:Label></div>
                            <div class="controlRowColumn2Of4">
                                <asp:Label ID="mailSenderOrganisation" runat="server" Text="Name"  Visible="false"></asp:Label><br>
                                <asp:Label ID="buildingName" runat="server" Text="Building"  Visible="false"></asp:Label><br>
                                <asp:Label ID="street" runat="server" Text="Street" Visible="false"></asp:Label><br>
                                <asp:Label ID="town" runat="server" Text="Town" Visible="false"></asp:Label><br>
                                <asp:Label ID="postcode" runat="server" Text="Post Code" Visible="false"></asp:Label></div>
                                <asp:Label ID="email" runat="server" Text="Email" Visible="false"></asp:Label>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="reference2Label" runat="server">*Reference 2*:</asp:Label>
                            </div>
                            <div class="controlRowColumn4Of4">
                                <asp:TextBox ID="reference2" runat="server" ReadOnly="True" BackColor="#FFFECE" Width="150px"
                                    ForeColor="Gray"></asp:TextBox>   
                            </div>
                        </div>
                        <br />
                        <div class="controlRow" id="DIV1" onclick="return DIV1_onclick()">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="queryTypeLabel" runat="server">*Query Type*:</asp:Label><asp:RequiredFieldValidator
                                    ID="queryTypeRequiredfieldvalidator" runat="server" ControlToValidate="queryTypeDropDownList"
                                    ErrorMessage="The *Query Type* cannot be blank.">*</asp:RequiredFieldValidator></div>
                            <div class="controlRowColumn2Of4">
                                <asp:DropDownList ID="queryTypeDropDownList" runat="server" OnSelectedIndexChanged="queryTypeDropDownList_SelectedIndexChanged"
                                    Width="80%" AutoPostBack="True" BackColor="LightCyan">
                                </asp:DropDownList></div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="subjectLabel" runat="server">*Subject*:</asp:Label><asp:RequiredFieldValidator
                                    ID="subjectRequiredFieldValidator" runat="server" ControlToValidate="subject"
                                    ErrorMessage="The *Subject* cannot be blank.">*</asp:RequiredFieldValidator></div>
                            <div class="controlRowColumn4Of4">
                                <asp:TextBox ID="subject" runat="server" TextMode="MultiLine" Width="100%" Rows="2"
                                    BackColor="LightCyan" Font-Names="Arial" Height="40px"></asp:TextBox></div>
                            &nbsp;
                        </div>
                        <div class="controlRow" id="Div2" onclick="return DIV1_onclick()">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="categorylabel" runat="server">Category:</asp:Label>
                                <asp:CustomValidator ID="cusValCategory" runat="server" ErrorMessage="Category Required"
                                    OnServerValidate="cusValCategory_ServerValidate">*</asp:CustomValidator>
                            </div>
                            <div class="controlRowColumn2Of4">
                                <asp:DropDownList ID="CategoryDropDown" runat="server" Width="80%" BackColor="LightCyan">
                                </asp:DropDownList></div>
                            &nbsp;
                        </div>
                        <br />
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="dateReceivedLabel" runat="server">*Date Received*:</asp:Label><asp:CustomValidator
                                    ID="dateReceivedCustomValidator" runat="server" ErrorMessage="The *Date Received* is not a valid date."
                                    OnServerValidate="dateReceivedCustomValidator_ServerValidate">*</asp:CustomValidator>
                                <asp:CustomValidator ID="dateRecChkToCalculateTargetsCustomValidator" runat="server"
                                    Enabled="False" ErrorMessage="The target dates cannot be calculated because the *Date Received* is an invalid date.  Please enter a valid date to continue.">*</asp:CustomValidator></div>
                            <div class="controlRowColumn2Of4">
                                <asp:DropDownList ID="dateReceivedDay" runat="server" BackColor="LightCyan" OnSelectedIndexChanged="dateReceived_SelectedIndexChanged" AutoPostBack="true">
                                </asp:DropDownList><asp:DropDownList ID="dateReceivedMonth" runat="server" BackColor="LightCyan" OnSelectedIndexChanged="dateReceived_SelectedIndexChanged" AutoPostBack="true">
                                </asp:DropDownList><asp:DropDownList ID="dateReceivedYear" runat="server" BackColor="LightCyan" OnSelectedIndexChanged="dateReceived_SelectedIndexChanged" AutoPostBack="true">
                                </asp:DropDownList>&nbsp;<a href="javascript:void(0);" onclick="Javascript:showPopupCalendar(document.Form1, document.Form1.dateReceivedDay, document.Form1.dateReceivedMonth, document.Form1.dateReceivedYear)"><img
                                    src="Images/calendar.gif" name="cal3" width="16" height="16" border="0" alt="Date Picker"
                                    id="dateReceivedCalendar" runat="server"></a></div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="statusLabel" runat="server">*Status*:</asp:Label><asp:RequiredFieldValidator
                                    ID="statusRequiredFieldValidator" runat="server" ControlToValidate="statusDropDownList"
                                    ErrorMessage="The Status field cannot be blank" Width="1px">*</asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvStatusSaveable" runat="server" 
                                    ErrorMessage="The Status should be marked complete if *Response Issued Date* is set" 
                                    OnServerValidate="cvResponseIssuedStatusSaveable_ServerValidate">*</asp:CustomValidator>
                            </div>
                            <div class="controlRowColumn4Of4">
                                <asp:DropDownList ID="statusDropDownList" runat="server" CssClass="mailViewTableValue"
                                    OnSelectedIndexChanged="statusDropDownList_SelectedIndexChanged" Width="100%"
                                    BackColor="LightCyan">
                                    <asp:ListItem></asp:ListItem>
                                </asp:DropDownList></div>
                        </div>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="externalTargetDateLabel" runat="server">*External Target Date*:</asp:Label><asp:CustomValidator
                                    ID="externalTargetDateCustomValidator" runat="server" ErrorMessage="The *External Target Date* must be a valid date and must be on or after the *Date Received*."
                                    OnServerValidate="externalTargetDateCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                            <div class="controlRowColumn2Of4">
                                <asp:DropDownList ID="externalTargetDateDay" runat="server" BackColor="#FFFECE">
                                </asp:DropDownList><asp:DropDownList ID="externalTargetDateMonth" runat="server"
                                    BackColor="#FFFECE">
                                </asp:DropDownList><asp:DropDownList ID="externalTargetDateYear" runat="server" BackColor="#FFFECE">
                                </asp:DropDownList>&nbsp;<a href="javascript:void(0);" onclick="Javascript:showPopupCalendar(document.Form1, document.Form1.externalTargetDateDay, document.Form1.externalTargetDateMonth, document.Form1.externalTargetDateYear)"><img
                                    src="Images/calendar.gif" name="cal3" width="16" height="16" border="0" alt="Date Picker"
                                    id="externalTargetDateCalendar" runat="server"></a></div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="dateStatusSetLabel" runat="server">Date *Status* Set:</asp:Label></div>
                            <div class="controlRowColumn4Of4">
                                <asp:TextBox ID="dateStatusSet" runat="server" BorderStyle="None" ReadOnly="True"
                                    BorderColor="Red" ForeColor="Gray">Not set</asp:TextBox></div>
                        </div>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="responseIssuedDateLabel" runat="server">*Response Issued Date*:</asp:Label><asp:CustomValidator
                                    ID="responseIssuedDateCustomValidator" runat="server" ErrorMessage="The *Response Issued Date* must be a complete and valid date and must be on or after the *Date Received*."
                                    OnServerValidate="responseIssuedDateCustomValidator_ServerValidate">*</asp:CustomValidator>
                                    <asp:CustomValidator ID="cvResponseIssuedSaveable" runat="server" 
                                    ErrorMessage="The *Response Issued Date* should be set if the status is marked complete" 
                                    OnServerValidate="cvResponseIssuedStatusSaveable_ServerValidate">*</asp:CustomValidator>
                            </div>
                            <div class="controlRowColumn2Of4">
                                <asp:DropDownList ID="responseIssuedDateDay" runat="server">
                                </asp:DropDownList><asp:DropDownList ID="responseIssuedDateMonth" runat="server">
                                </asp:DropDownList><asp:DropDownList ID="responseIssuedDateYear" runat="server">
                                </asp:DropDownList>&nbsp;<a href="javascript:void(0);" onclick="Javascript:showPopupCalendar(document.Form1, document.Form1.responseIssuedDateDay, document.Form1.responseIssuedDateMonth, document.Form1.responseIssuedDateYear)"><img
                                    src="Images/calendar.gif" name="cal3" width="16" height="16" border="0" alt="Date Picker"
                                    id="responseIssuedDateCalendar" runat="server"></a></div>
                            <div class="controlRowColumn3Of4">
                                <asp:Label ID="Label1" runat="server" Text="Public Rep: " ></asp:Label></div>
                            <div class="controlRowColumn4Of4">
                                <asp:DropDownList ID="PublicRepDropDownList" runat="server" >
                                </asp:DropDownList></div>
                        </div>
                        <div class="controlRow">
                            <div class="controlRowColumn1Of4">
                                <asp:Label ID="commentsLabel" runat="server">*Comments*:</asp:Label></div>
                            <div class="controlRowColumn1Only">
                                <asp:TextBox ID="comments" runat="server" Width="100%" TextMode="MultiLine" Rows="4"></asp:TextBox></div>
                        </div>
                    </div>
                    <div class="controlRowButtons">
                        <asp:Button ID="btnTransfer" runat="server" Text="Transfer" OnClick="btnTransfer_Click" />
                        <asp:Button ID="saveOverMoreRecentChanges" runat="server" CausesValidation="False"
                            OnClick="saveOverMoreRecentChanges_Click" Text="Save" Visible="False" Width="60px" />
                        <asp:Button ID="saveMailChanges" runat="server" Width="60px" Text="Save" OnClick="saveMailChanges_Click">
                        </asp:Button><asp:Button ID="saveNewMailItem" runat="server" Width="60px" Text="Save"
                            OnClick="saveNewMailItem_Click"></asp:Button>
                        <asp:Button ID="mailCancel" runat="server" Width="60px" Text="Cancel" CausesValidation="False"
                            OnClick="mailCancel_Click"></asp:Button>&nbsp;<asp:Button ID="mailUndo" runat="server"
                                CausesValidation="False" OnClick="mailUndo_Click" Text="Undo" Visible="False"
                                Width="60px" />&nbsp;&nbsp;&nbsp;
                        <asp:Button ID="viewReferrals" runat="server" Width="110px" Text="View Referrals"
                            OnClick="viewReferrals_Click"></asp:Button>
                        <asp:Button ID="viewMailList" runat="server" Width="149px" Text="View *Mail Item* List"
                            OnClick="viewMailList_Click" Enabled="False" Visible="False"></asp:Button>
                    </div>
                </div>
                <asp:Panel ID="pnlTransfer" runat="server">
                    <div>
                        <asp:Button ID="btnReturnTransfer" runat="server" Text="Return to Responsible Section"
                            OnClick="btnReturnTransfer_Click" />
                    </div>
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="lblTransferDivision" runat="server">Division :</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:DropDownList ID="ddlDivision" runat="server" BackColor="#FFFECE" OnSelectedIndexChanged="ddlDivision_SelectedIndexChanged"
                                AutoPostBack="true">
                            </asp:DropDownList></div>
                    </div>
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="lblTransferSection" runat="server">Section :</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:DropDownList ID="ddlSection" runat="server" BackColor="#FFFECE">
                            </asp:DropDownList></div>
                    </div>
                    <div class="controlRowButtons">
                        <asp:Button ID="btnSaveTranser" runat="server" Text="Save" OnClick="btnSaveTranser_Click" />
                        <asp:Button ID="btnCancelTransfer" runat="server" Text="Cancel" OnClick="btnCancelTransfer_Click" />
                    </div>
                </asp:Panel>
                <div id="addressPanel" runat="server">
                    <asp:CustomValidator ID="duplicateAddresseeCustomValidator" runat="server" ErrorMessage="This record already exists."
                        OnServerValidate="duplicateAddresseeCustomValidator_ServerValidate">*</asp:CustomValidator>
                    <asp:CustomValidator ID="duplicateMailSenderCustomValidator" runat="server" ErrorMessage="This record already exists."
                        OnServerValidate="duplicateMailSenderCustomValidator_ServerValidate">*</asp:CustomValidator>
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="titleFKLabel" runat="server">Title</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressTitleFK" runat="server" Width="10%" Visible="False"></asp:TextBox>
                            <asp:DropDownList ID="addressTitleDropDownList" runat="server" Width="100px">
                                <asp:ListItem Value=" "></asp:ListItem>
                            </asp:DropDownList></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="forenameLabel" runat="server">Forename</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressForename" runat="server" Width="40%" MaxLength="20"></asp:TextBox>
                            <asp:CustomValidator ID="addressforenameSurnameOrganisationValidator" runat="server"
                                ErrorMessage="You must provide a value for at least one of the following fields: Forename, Surname or Organisation"
                                OnServerValidate="forenameSurnameOrganisationValidator_ServerValidate">*</asp:CustomValidator>
                            <asp:CustomValidator ID="popupForenameCustomValidator" runat="server" ControlToValidate="addressForename"
                                ErrorMessage="The Forename contains invalid characters." OnServerValidate="popupForenameCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="surnameLabel" runat="server">Surname</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressSurname" runat="server" Width="40%" MaxLength="50"></asp:TextBox>
                            <asp:CustomValidator ID="popupSurnameCustomValidator" runat="server" ControlToValidate="addressSurname"
                                ErrorMessage="The Surname contains invalid characters." OnServerValidate="popupSurnameCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="fromOrganisationFKLabel" runat="server">Organisation</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressOrganisation" runat="server" Width="50%" MaxLength="100"></asp:TextBox>
                            <asp:CustomValidator ID="popupOrganisationCustomValidator" runat="server" ControlToValidate="addressOrganisation"
                                ErrorMessage="The Organisation contains invalid characters." OnServerValidate="popupOrganisationCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="buildingNameLabel" runat="server">Building Name</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressBuildingName" runat="server" Width="50%" MaxLength="30"></asp:TextBox>
                            <asp:CustomValidator ID="popupBuildingNameCustomValidator" runat="server" ControlToValidate="addressBuildingName"
                                ErrorMessage="The Building Name contains invalid characters." OnServerValidate="popupBuildingNameCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="streetLabel" runat="server">Street</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressStreet" runat="server" Width="50%" MaxLength="30"></asp:TextBox>
                            <asp:CustomValidator ID="popupStreetCustomValidator" runat="server" ControlToValidate="addressStreet"
                                ErrorMessage="The Street contains invalid characters." OnServerValidate="popupStreetCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="townLabel" runat="server">Town</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressTown" runat="server" Width="50%" MaxLength="30"></asp:TextBox>
                            <asp:CustomValidator ID="popupTownCustomValidator" runat="server" ControlToValidate="addressTown"
                                ErrorMessage="The Town contains invalid characters." OnServerValidate="popupTownCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="postcodeLabel" runat="server">Postcode</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="addressPostcode" runat="server" Width="15%" MaxLength="10"></asp:TextBox>
                            <asp:CustomValidator ID="popupPostcodeCustomValidator" runat="server" ControlToValidate="addressPostcode"
                                ErrorMessage="The Postcode is not in the correct format." OnServerValidate="popupPostcodeCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </div>
                    <br />
                    <asp:Panel ID="pnlEmail" CssClass="ControlRow" runat="server" Visible="false">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="lblEmail" runat="server">Email</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:TextBox ID="txtEmail" runat="server" Width="50%" MaxLength="50"></asp:TextBox>
                            <asp:CustomValidator ID="cusEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="The email address is not in a recognised format."
                                OnServerValidate="popupPostcodeCustomValidator_ServerValidate">*</asp:CustomValidator></div>
                    </asp:Panel>
                    <br />
                    <div class="controlRow">
                        <div class="controlRowColumn1Of4">
                            <asp:Label ID="inUseLabel" runat="server">In Use</asp:Label></div>
                        <div class="controlRowColumn234Of4">
                            <asp:CheckBox ID="addressInUse" runat="server" Checked="True"></asp:CheckBox></div>
                    </div>
                    <div id="duplicatesPanel" runat="server">
                        <b>WARNING!</b> The following records already on the system have a similar Name
                        / Organisation.
                        <br>
                        Are you sure you want to save these changes?
                        <br>
                        <br>
                        <asp:Table ID="itemTable" runat="server">
                            <asp:TableRow CssClass="TH">
                                <asp:TableCell CssClass="TH">Title</asp:TableCell>
                                <asp:TableCell CssClass="TH">Forename</asp:TableCell>
                                <asp:TableCell CssClass="TH">Surname</asp:TableCell>
                                <asp:TableCell CssClass="TH">Email</asp:TableCell>
                                <asp:TableCell CssClass="TH">Organisation</asp:TableCell>
                                <asp:TableCell CssClass="TH">Building&nbsp;Name</asp:TableCell>
                                <asp:TableCell CssClass="TH">Street</asp:TableCell>
                                <asp:TableCell CssClass="TH">Town</asp:TableCell>
                                <asp:TableCell CssClass="TH">Postcode</asp:TableCell>
                                <asp:TableCell CssClass="TH">In&nbsp;Use</asp:TableCell>
                            </asp:TableRow>
                        </asp:Table>
                    </div>
                    <div class="controlRowButtons">
                        <asp:Button ID="saveNewMailSenderConfirm" runat="server" OnClick="saveNewMailSenderConfirm_Click"
                            Text="Save" Width="60px" />
                        <asp:Button ID="saveNewAddresseeConfirm" runat="server" OnClick="saveNewAddresseeConfirm_Click"
                            Text="Save" Width="60px" />
                        <asp:Button ID="saveNewSender" runat="server" Width="60px" Text="Save" OnClick="saveNewSender_Click">
                        </asp:Button>
                        <asp:Button ID="saveNewAddressee" runat="server" OnClick="saveNewAddressee_Click"
                            Text="Save" Width="60px" />&nbsp;<asp:Button ID="addresseeCancel" runat="server"
                                CausesValidation="False" OnClick="addressCancel_Click" Text="Cancel" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
