<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FriendManager.aspx.cs" Inherits="PianoWeb.FriendManager" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0" />
    <title>好友管理</title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <script language="javascript" src="./js/jquery-2.1.1.min.js"></script>
    <script language="javascript">

        function unselect() {

            var obj1 = document.getElementById("mf1");
            var obj2 = document.getElementById("mf2");
            var obj3 = document.getElementById("mf3");

            obj1.setAttribute("class", "");
            obj2.setAttribute("class", "");
            obj3.setAttribute("class", "");
        }

        function on_xuanze(type) {

            var obj;
            switch (type) {
                case 1:
                    obj = document.getElementById("mf1");
                    break;
                case 2:
                    obj = document.getElementById("mf2");
                    break;
                case 3:
                    obj = document.getElementById("mf3");
                    break;
            }
            unselect();
            obj.setAttribute("class", "active");

            if (type != 3) {
                document.getElementById("txtKey").style.display = "none";
                document.getElementById("btnSearch").style.display = "none";
                document.getElementById("a_add_friend").style.display = "none";

                var user = document.getElementById("hidenUser").value;
                var url1 = "./FriendManager.aspx?userName=" + user + "&option=" + type;
                window.location.href = url1;

            } else {
                document.getElementById("txtKey").style.display = "";
                document.getElementById("btnSearch").style.display = "";
                document.getElementById("a_add_friend").style.display = "";
                
                document.getElementById("commentList").style.display = "none";
            }
        }
        
        function on_search() {

            var key = document.getElementById("txtKey");
            if (key.value.length == 0) {
                alert("请输入关键字！！");
                key.focus();
                return false;
            }
            
            var user = document.getElementById("hidenUser").value;
            var url1 = "./FriendManager.aspx?userName=" + user + "&option=3&keyword="+key.value;
            window.location.href = url1;
 
        }

        function add_friend_check() {

            var cnt1 = document.getElementById("hidenCount").value;
            
            if (cnt1 == "") {
                alert("没有待添加好友的数据！！");
                return false;
            }

            var cnt = parseInt(cnt1);
            if (cnt == 0) {
                alert("没有待添加好友的数据！！");
                return false;
            }
            
            var i = 0;
            var check_count = 0;
            for (i = 0; i < cnt; i++) {
                var obj = document.getElementById("chk_" + i);
                if (obj.checked) {
                    check_count++;
                }
            }

            if (check_count == 0) {
                alert("请选择待添加的好友！！");
                return false;
            }

            if (check_count > 1) {
                alert("每次只能添加一个好友！！");
                return false;
            }

            return true;
        }

        function on_add_friend() {

            if (!add_friend_check()) {
                return;
            }
            
            var cnt = parseInt(document.getElementById("hidenCount").value);
            var i = 0;
            for (i = 0; i < cnt; i++) {
                var obj = document.getElementById("chk_" + i);
                if (obj.checked) {
                    break;
                }
            }


            var key = document.getElementById("txtKey");
            var attentionUser = document.getElementById("hid_aces_usr_" + i).value;
            var user = document.getElementById("hidenUser").value;
            var url1 = "./FriendManager.aspx?userName=" + user + "&attendtionUser=" + attentionUser + 
                "&option=4&keyword=" + key.value;
            window.location.href = url1;
        }
        
        function on_huitui() {
            var user = document.getElementById("hidenUser").value;
            var _url = "\Room.aspx?userName=" + user;
            window.location.href = _url;
        }
        
        function on_init() {

            var obj;
            var type = document.getElementById("hidenOption").value;
            unselect();
            if (type == "" || type == null) {
                obj = document.getElementById("mf1");

                document.getElementById("txtKey").style.display = "none";
                document.getElementById("btnSearch").style.display = "none";
                document.getElementById("a_add_friend").style.display = "none";
            } else {
                var t = parseInt(type);
                switch (t) {
                    case 1:
                        obj = document.getElementById("mf1");
                        document.getElementById("txtKey").style.display = "none";
                        document.getElementById("btnSearch").style.display = "none";
                        document.getElementById("a_add_friend").style.display = "none";
                        break;
                    case 2:
                        obj = document.getElementById("mf2");
                        document.getElementById("txtKey").style.display = "none";
                        document.getElementById("btnSearch").style.display = "none";
                        document.getElementById("a_add_friend").style.display = "none";
                        break;
                    case 3:
                    case 4:
                        obj = document.getElementById("mf3");

                        document.getElementById("txtKey").style.display = "";
                        document.getElementById("btnSearch").style.display = "";
                        document.getElementById("a_add_friend").style.display = "";
                        
                        break;
                }
            }

            obj.setAttribute("class", "active");
        }
        
    </script>
    
</head>
<body onload="on_init()">
    <form id="form1" runat="server">
        <div class="ww1">

          <div class="wrapper">
            <div class="left">
                <div id="content">
                    <div class="list">
                        <ul>
                            <li><a id="mf1" href="#" onclick="on_xuanze(1)">
                                <span><img src="images/list01.png"></span>我的好友</a></li>
                            <li><a id="mf2" href="#" onclick="on_xuanze(2)">
                                <span><img src="images/list02.png"></span>推荐的关注人</a></li>
                            <li><a id="mf3" href="#" onclick="on_xuanze(3)">
                                <span><img src="images/list03.png"></span>搜索账号</a></li>
                        </ul>
                    </div>
                </div>  
            </div>
            <div class="right">
            <div class="list2y"><div class="txt">
            
                                        <asp:TextBox ID="txtKey" class="newb02" runat="server"></asp:TextBox>
                                <input id="btnSearch" type="button" class="newb01"
                                value="搜索" onclick="on_search()" />
            
            <a id="a_add_friend" href="#" onclick="on_add_friend()">添加好友</a></div></div>
                <div id="content2">
                                
                    <div class="list2"  runat="server" id="commentList">
                    </div>
                </div>
            </div>
          </div>

        </div>

        <asp:HiddenField ID="hidenUser" runat="server" />
        <asp:HiddenField ID="hidenOption" runat="server" />
        <asp:HiddenField ID="hidenCount" runat="server" />
        
    </form>
</body>
</html>
