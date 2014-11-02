<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Room.aspx.cs" Inherits="PianoWeb.Room" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >

<head runat="server">
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0" />
<link href="css/index.css" rel="stylesheet" type="text/css" />
    <title>展厅</title>
<script language="javascript" src="./js/jquery-2.1.1.min.js"></script>
<script language="javascript">

    function OnInit() {
        var value = document.getElementById("hidenUser").value;
        document.getElementById("work").href = "Work.aspx?username=" + value;
        document.getElementById("friend").href = "list.aspx?username=" + value;


        var t = document.getElementById("hidenType").value;
        if (t == 1) {
            document.getElementById("div_deng3").style.display = "";
            document.getElementById("div_gangqin").style.display = "";
            document.getElementById("div_shafa").style.display = "";
            document.getElementById("div_bihua").style.display = "";
            document.getElementById("div_guizi").style.display = "";

            document.getElementById("div_control").style.display = "none";

            document.getElementById("div_back").style.display = "";
            document.getElementById("div_adornment").style.display = "";
            
        } else {
            document.getElementById("div_deng3").style.display = "none";
            document.getElementById("div_gangqin").style.display = "none";
            document.getElementById("div_shafa").style.display = "none";
            document.getElementById("div_bihua").style.display = "none";
            document.getElementById("div_guizi").style.display = "none";

            document.getElementById("div_control").style.display = "";

            document.getElementById("div_back").style.display = "none";
            document.getElementById("div_adornment").style.display = "none";
        }
    }

    function on_adornment(type) {


        var user = document.getElementById("hidenUser").value;
        var url1 = "./Room.aspx?buy=yes&userName=" + user;
        $.ajax({ url: url1, async: false });
    }


    function on_back() {
        document.getElementById("div_deng3").style.display = "none";
        document.getElementById("div_gangqin").style.display = "none";
        document.getElementById("div_shafa").style.display = "none";
        document.getElementById("div_bihua").style.display = "none";
        document.getElementById("div_guizi").style.display = "none";
        document.getElementById("div_control").style.display = "";
        document.getElementById("div_back").style.display = "none";
        document.getElementById("div_adornment").style.display = "none";

        document.getElementById("hidenType").value = 0;
    }

    function on_setting() {
        document.getElementById("hidenType").value = 1;


        document.getElementById("div_deng3").style.display = "";
        document.getElementById("div_gangqin").style.display = "";
        document.getElementById("div_shafa").style.display = "";
        document.getElementById("div_bihua").style.display = "";
        document.getElementById("div_guizi").style.display = "";
        document.getElementById("div_control").style.display = "none";
        document.getElementById("div_back").style.display = "";
        document.getElementById("div_adornment").style.display = "";
    }
</script>
</head>
<body onload="OnInit()">
    <form id="form1" runat="server">


        <div class="ww">

            <div class="room">
                <div class="deng1"><asp:Image ID="deng1" runat="server"/></div>
                <div class="deng2"><asp:Image ID="deng2" runat="server"/></div>
                <div class="deng3"><div id="div_deng3" class="ico"><a href="#" onclick="on_adornment(5)"></a></div>
                    <asp:Image ID="deng3" runat="server" width="200" height="200"/></div>
                <div class="gangqin"><div id="div_gangqin" class="ico"><a href="#" onclick="on_adornment(1)"></a></div>
                    <asp:Image ID="gangqin" runat="server"  width="294" height="278"/></div>
                <div class="bihua"><div id="div_bihua" class="ico"><a href="#" onclick="on_adornment(4)"></a></div>
                    <asp:Image ID="bihua" runat="server" width="76" height="85"/></div>
                <div class="guizi"><div id="div_guizi" class="ico"><a href="#" onclick="on_adornment(2)"></a></div>
                    <asp:Image ID="guizi" runat="server" width="148" height="262"/></div>
                <div class="shafa"><div id="div_shafa" class="ico"><a href="#" onclick="on_adornment(3)"></a></div>
                    <asp:Image ID="shafa" runat="server" width="324" height="163"/></div>

                <div id="div_control" class="dr">
                    <ul>
                        <li><a id="work" href=#><img src="images/dr03.png"  width="50" height="40">
                            <br/>作品集</a></li>
                        <li><a id="setting" href=# onclick="on_setting()"><img src="images/dr01.png"  width="50" height="40">
                            <br/>装饰设置</a></li>
                        <li><a id="friend" href=#><img src="images/dr02.png"  width="50" height="40">
                            <br/>好友管理</a></li>
                    </ul>
                </div>
                
                <div id="div_adornment" class="drl">

                    <div class="l"><a href="#"><img src="images/drl01.png"  width="24" height="44"></a></div>
                    <div class="t">家庭红色沙发<br/>0000</div>
                    <div class="r"><a href="#"><img src="images/drl02.png"  width="24" height="44"></a></div>

                </div>
                
                <div id="div_back" class="back"><a href=# onclick="on_back()">返回</a></div>
                
            </div>
        </div>
        
        <asp:HiddenField ID="hidenUser" runat="server" />
        <asp:HiddenField ID="hidenType" runat="server" />
        <asp:HiddenField ID="hidenAdornmentType" runat="server" />
        <asp:HiddenField ID="hidenMoney" runat="server" />
        
        
        <asp:HiddenField ID="hidenGangqin" runat="server" />
        <asp:HiddenField ID="hidenShafa" runat="server" />
        <asp:HiddenField ID="hidenGuizi" runat="server" />
        <asp:HiddenField ID="hidenBihua" runat="server" />
        <asp:HiddenField ID="hidenDeng" runat="server" />
    </form>
</body>
</html>
