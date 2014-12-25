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

    function on_init() {
        var value = document.getElementById("hidenUser").value;
        document.getElementById("work").href = "Work.aspx?username=" + value;
        document.getElementById("friend").href = "FriendManager.aspx?username=" + value;


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

        document.getElementById("div_adornment").style.display = "";
        document.getElementById("hidenAdornmentType").value = type;
        goto_data(0);
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
        
    }

    function goto_data(flag) {

        var str = new Array();
        var type = parseInt(document.getElementById("hidenAdornmentType").value);
        var index = 0;
        var max = 0;

        
        switch (type) {
            case 1:
                index = document.getElementById("hidenGangqinIndex").value;
                str = document.getElementById("hidenGangqin").value.split("|");
                max = document.getElementById("hidenGangqinCount").value;
                break;
            case 2:
                index = document.getElementById("hidenGuiziIndex").value;
                str = document.getElementById("hidenGuizi").value.split("|");
                max = document.getElementById("hidenGuiziCount").value;
                break;
            case 3:
                index = document.getElementById("hidenShafaIndex").value;
                str = document.getElementById("hidenShafa").value.split("|");
                max = document.getElementById("hidenShafaCount").value;
                break;
            case 4:
                index = document.getElementById("hidenBihuaIndex").value;
                str = document.getElementById("hidenBihua").value.split("|");
                max = document.getElementById("hidenBihuaCount").value;
                break;
            case 5:
                index = document.getElementById("hidenDengIndex").value;
                str = document.getElementById("hidenDeng").value.split("|");
                max = document.getElementById("hidenDengCount").value;
                break;
        }

        if (str == null ) return;
        
        if (flag == 1) {//up
            if (parseInt(index) == 0) return;
            index = parseInt(index) - 1;
        } else if (flag == 2) {//next
            if ( parseInt(max) - parseInt(index) == 1 ) return;
            index = parseInt(index) + 1;
        } else {
        }

        var str1 = new Array();
        str1 = str[index].split(",");

        var p = parseInt(str1[2]);
        if (p == 0) {
            document.getElementById("btnOption").value = "设置";
        } else {
            document.getElementById("btnOption").value = str1[2];
        }
        document.getElementById("adornment_name").innerText = str1[0];
        document.getElementById("hidenAdornmentID").value = str1[3];
        
        switch (type) {
            case 1:
                document.getElementById("hidenGangqinIndex").value = index;
                break;
            case 2:
                document.getElementById("hidenGuiziIndex").value = index;
                break;
            case 3:
                document.getElementById("hidenShafaIndex").value = index;
                break;
            case 4:
                document.getElementById("hidenBihuaIndex").value = index;
                break;
            case 5:
                document.getElementById("hidenDengIndex").value = index;
                break;
        }
    }

    function adornment_change() {

        var str = new Array();
        var type = parseInt(document.getElementById("hidenAdornmentType").value);
        var index = 0;

        switch (type) {
            case 1:
                index = document.getElementById("hidenGangqinIndex").value;
                str = document.getElementById("hidenGangqin").value.split("|");
                max = document.getElementById("hidenGangqinCount").value;
                break;
            case 2:
                index = document.getElementById("hidenGuiziIndex").value;
                str = document.getElementById("hidenGuizi").value.split("|");
                max = document.getElementById("hidenGuiziCount").value;
                break;
            case 3:
                index = document.getElementById("hidenShafaIndex").value;
                str = document.getElementById("hidenShafa").value.split("|");
                max = document.getElementById("hidenShafaCount").value;
                break;
            case 4:
                index = document.getElementById("hidenBihuaIndex").value;
                str = document.getElementById("hidenBihua").value.split("|");
                max = document.getElementById("hidenBihuaCount").value;
                break;
            case 5:
                index = document.getElementById("hidenDengIndex").value;
                str = document.getElementById("hidenDeng").value.split("|");
                max = document.getElementById("hidenDengCount").value;
                break;
        }

        if (str == null) return;


        var str1 = new Array();
        str1 = str[index].split(",");
        switch (type) {
            case 1:
                document.getElementById("gangqin").src = str1[1];
                break;
            case 2:
                document.getElementById("guizi").src = str1[1];
                break;
            case 3:
                document.getElementById("shafa").src = str1[1];
                break;
            case 4:
                document.getElementById("bihua").src = str1[1];
                break;
            case 5:
                document.getElementById("deng3").src = str1[1];
                break;
        }
    }
    
    function on_option(flag) {

        if (flag == 0) {//预览
            adornment_change();
        } else {//购买
            var opt = 1;
            var c = 0;
            var t = document.getElementById("btnOption").value;
            if (t == "设置") {
                opt = 1;

                adornment_change();
            } else {
                opt = 2;

                var m = parseInt(document.getElementById("<%=lblMoney.ClientID%>").innerText);
                c = parseInt(t);
                if (c > m) {
                    alert("您的余额不足!");
                    return;
                }

                document.getElementById("btnOption").value = "设置";
                document.getElementById("<%=lblMoney.ClientID%>").innerText = m - c;

                adornment_change();
            }

            var id = document.getElementById("hidenAdornmentID").value;
            var type = document.getElementById("hidenAdornmentType").value;
            var user = document.getElementById("hidenUser").value;
            var url1 = "./Room.aspx?option=" + opt + "&userName=" + user + "&coins=" + c +
                "&adornment_id=" + id + "&type=" + type;
            $.ajax({ url: url1, async: false });
        }
    }
    
</script>
</head>
<body onload="on_init()">
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
                
                <div id="div_adornment" class="drl0">


                    <div class="t"></div>
                    
                    <div  class="drl">
                        <div class="l"><a href="javascript://" onclick="goto_data(1);on_option(0)">
                            <img src="images/drl01.png"  width="24" height="44"></a>
                        </div>
                        <div style="vertical-align: middle;	text-align: center;	float: left;width:200px;margin:0 auto;">

                        <label id="adornment_name">aaaaaaaaaaa</label><br/>
                        <input id="btnOption" type="button" onclick="on_option(1)" class="but"/>
                        </div>
                        <div class="r"><a href="javascript://" onclick="goto_data(2);on_option(0)"><img src="images/drl02.png"  width="24" height="44"></a></div>
                    </div>

                </div>
                
                <div id="div_back" class="back"><a href=# onclick="on_back()">返回</a></div>
                <div id="div1" class="top_right-jf">拥有金币：<asp:Label ID="lblMoney" runat="server" Text=""></asp:Label></div>
            </div>
        </div>
        
        <asp:HiddenField ID="hidenUser" runat="server" />
        <asp:HiddenField ID="hidenType" runat="server" />
        <asp:HiddenField ID="hidenAdornmentType" runat="server" />

        
        
        <asp:HiddenField ID="hidenGangqin" runat="server" />
        <asp:HiddenField ID="hidenShafa" runat="server" />
        <asp:HiddenField ID="hidenGuizi" runat="server" />
        <asp:HiddenField ID="hidenBihua" runat="server" />
        <asp:HiddenField ID="hidenDeng" runat="server" />
        
        
        
        <asp:HiddenField ID="hidenGangqinCount" runat="server" />
        <asp:HiddenField ID="hidenShafaCount" runat="server" />
        <asp:HiddenField ID="hidenGuiziCount" runat="server" />
        <asp:HiddenField ID="hidenBihuaCount" runat="server" />
        <asp:HiddenField ID="hidenDengCount" runat="server" />
        
        
        <asp:HiddenField ID="hidenGangqinIndex" runat="server" />
        <asp:HiddenField ID="hidenShafaIndex" runat="server" />
        <asp:HiddenField ID="hidenGuiziIndex" runat="server" />
        <asp:HiddenField ID="hidenBihuaIndex" runat="server" />
        <asp:HiddenField ID="hidenDengIndex" runat="server" />
        
        <asp:HiddenField ID="hidenAdornmentID" runat="server" />
    </form>
</body>
</html>
