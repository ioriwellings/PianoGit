<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Work.aspx.cs" Inherits="PianoWeb.Work" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0" />
    <title>作品集</title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    
    
    <script language="javascript">

        function OnShuaXin() {
            window.location.reload();

        }
        
        function huitui() {
            window.history.go(-1);
        }
    
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="ww1">
        <div class="work">
            <div class="photo">
                <asp:Image ID="userPhoto" runat="server" onclick="OnShuaXin()"/>
            </div>
            <div class="right">
                <h2><asp:Label ID = "lblUserName" runat="server" /></h2>
                <p><asp:Label ID = "lblOtherInfo1" runat="server" /></p>
                <p><asp:Label ID = "lblOtherInfo2" runat="server" /></p>
            </div>
        </div>
        
        <div class="work2">
            <div class="jibie">
                <img src="images/work-01.png"><asp:Label ID = "lblLevel" runat="server" />&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/work-02.png"><asp:Label ID = "lblLisnten" runat="server" />&nbsp;&nbsp;&nbsp;&nbsp;<img
                    src="images/work-03.png"><asp:Label ID = "lblLike" runat="server" /></div>
        </div>
        
        <div class="work3" runat="server" id="opusList">
        </div>
        
      </div>
    </form>
</body>
</html>
