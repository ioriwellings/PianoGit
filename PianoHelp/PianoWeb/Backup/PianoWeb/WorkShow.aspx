<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkShow.aspx.cs" Inherits="PianoWeb.WorkShow" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<html xmlns:wb="http://open.weibo.com/wb">
<head runat="server">
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0" />
<title>作品集-详情</title>
<link href="css/index.css" rel="stylesheet" type="text/css" />
<script src="http://tjs.sjs.sinajs.cn/open/api/js/wb.js" type="text/javascript" charset="utf-8"></script>
<script language="javascript" src="./js/jquery-2.1.1.min.js"></script>
<script language="javascript">

    function OnPlayers() {
        var user = document.getElementById("hidenUser").value;
        var opusID = document.getElementById("hidenOpusID").value;

        var v = document.getElementById("hidenListen").value;
        var cnt = parseInt(v) + 1;
        $("#lblClickInfo").text( cnt + "人听过");

        var u = document.getElementById("hidenAccUser").value;

        var url1 = "./WorkShow.aspx?listen=yes&userName=" + user + "&opusID=" + opusID + "&attendtionUser=" + u;
        $.ajax({ url: url1, async: false });
    }


    function OnInit() {
        var path = document.getElementById("hidenPath").value;
        document.getElementById("opus").src = path;

        var u = document.getElementById("hidenAccUser").value;
        if (u != "") {

            document.getElementById("ldel").style.display = "none";
            document.getElementById("lshare").style.display = "none";
        }
    }

    function messageCheck() {
        var message = document.getElementById("txtMessage");
        if (message.value.length == 0) {
            alert("请输入评论内容！！");
            message.focus(); 
            return false;
        }

        return true;
    }

    function delete_configure() {
        var r = window.confirm('你确定删除此作品吗？');
        if (r) {
            return true;
        } else {
            return false;
        }
    }

    function postToWb() {

        var _t = encodeURI(document.title);
        var _url = encodeURI(document.location);
        var _appkey = encodeURI("123"); //你从腾讯获得的appkey
        var _pic = encodeURI(''); //（列如：var _pic='图片url1|图片url2|图片url3....）
        var _site = ''; //你的网站地址
        var _u = 'http://v.t.qq.com/share/share.php?title=' + _t + '&url=' + _url + '&appkey=' + _appkey 
                + '&site=' + _site + '&pic=' + _pic;

        window.open(_u, '转播到腾讯微博', 
                 'width=700, height=680, top=0, left=0, toolbar=no, menubar=no, scrollbars=no, location=yes, resizable=no, status=no');

    }

    function sleep(milliSeconds) {
        var startTime = new Date().getTime();  // get the current time   
        while (new Date().getTime() < startTime + milliSeconds);  // hog cpu
    }


    function huitui() {
        var user = document.getElementById("hidenUser").value;
        var _url = "\Work.aspx?userName=" + user;
        window.location.href = _url;
    }

</script>

</head>
<body onload="OnInit()">
    <form id="form1" runat="server">
      <div class="ww1">
      
      
       <div class="list2y">
           <div class="txt_t"><asp:Label ID="lblMessageCount" runat="server" ></asp:Label></div>   
           <div class="txt"></div>
       </div>
	  
	   <div class="list2yb">
	       <div class="inp"><asp:TextBox ID="txtMessage" runat="server"></asp:TextBox></div>
           <div class="txt">
               <asp:ImageButton ID="btnSend" runat="server" src="images/fasong@x2-01.png" 
               width="58" height="24" onclick="btnSend_Click" onclientclick="return messageCheck()"/></div>
      </div>
      
      
      
      
        <div class="wrapper">
        
          <div class="left">
            
            <div class="workshow">
              <div class="show">
                <div class="photo"><asp:Image ID="userPhoto" runat="server" /></div>
                <div class="right">
                    <h2><asp:Label ID="lblOpusName" runat="server" ></asp:Label></h2>
                    <p><asp:Label ID="lblUserName" runat="server" ></asp:Label></p>
                    <div class="dibu"><img src="images/work-02.png">
                          <asp:Label ID="lblClickInfo" runat="server"></asp:Label>&nbsp;&nbsp;&nbsp;&nbsp;
                      <img src="images/work-03.png"><asp:Label ID="lblLoveInfo" runat="server" ></asp:Label></div>
                </div>
              </div>
            </div>
            <div class="workshow2">

              <div class="box"><img src="images/mv.gif" width="420" height="372"></div>
                <div class="box2">

                    <audio id="opus" controls="controls" onplay="OnPlayers()" style="width:420px">
                        Your browser does not support the audio element.
                    </audio>
                </div>
            </div>
      
      
	        <div class="workshow3" id="other1">
              <div class="workshow3d">
                <ul>
                
                <li id="ldel" ><asp:ImageButton ID="btnDel" runat="server" src="images/workshow3d-04.png" 
                        width="70" height="70" onclick="btnDel_Click" onclientclick="return delete_configure()"/>                                         <br />删除</li>
                
                <li id="lshare" ><a href="#" onclick="postToWb()"><img src="images/workshow3d-03.png"  width="70" height="70">
                        <br />分享</a></li>
                
                
                 <li><asp:ImageButton ID="btnGuanZhu" runat="server" src="images/workshow3d-01.png"
                       Visible="False"/><br/></li>
                    
                 <li><asp:ImageButton ID="btnLove" runat="server" src="images/workshow3d-02.png" 
                            onclick="btnLove_Click" Visible="False"/><br/></li>

                </ul>
              </div>
            </div>
          </div>
          
          
          <div class="right">
              <div id="content2">
                <div class="list2"  runat="server" id="commentList">
                

                </div>
            </div>
            
          </div>
        </div>
        <div class="back"><a href=# onclick="huitui()">返回</a></div>
      </div>
    <asp:HiddenField ID="hidenType" runat="server" />
    <asp:HiddenField ID="hidenUser" runat="server" />
    <asp:HiddenField ID="hidenOpusID" runat="server" />
    <asp:HiddenField ID="hidenListen" runat="server" />
    <asp:HiddenField ID="hidenPath" runat="server" />
    
    <asp:HiddenField ID="hidenAccUser" runat="server" />
    
    </form>
</body>
</html>
