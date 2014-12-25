using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

namespace PianoWeb
{
    public partial class FriendManager : System.Web.UI.Page
    {
        private int option = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            option = 1;
            string userName = Request.Params["userName"];
            hidenUser.Value = userName;

            string v = Request.Params["option"];
            if (v != "" && v != null)
            {
                option = Convert.ToInt32(v);
                hidenOption.Value = v;
            }

            Do_Action(userName);
        }

        private void Do_Action(string user)
        {
            switch (option)
            {
                case 1://我的好友
                    Get_MyFriend(user);
                    break;
                case 2://推荐的好友
                    Get_MyTopUser(user);
                    break;
                case 3://搜索的好友
                    string key = Request.Params["keyword"];
                    Get_MySearchUsers(user, key);
                    txtKey.Text = key;
                    break;
                case 4://添加好友
                    string attendtion = Request.Params["attendtionUser"];
                    Add_Friends(user, attendtion);

                    string key1 = Request.Params["keyword"];
                    Get_MySearchUsers(user, key1);
                    txtKey.Text = key1;
                    break;
            }
        }

        private void Get_MyFriend(string userName)
        {
            StringBuilder sb = new StringBuilder();

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from c in piano.Users 
                    join fr in piano.Attention on c.userName equals fr.attentionUser
                    where fr.userName.Equals(userName)
                    select new
                    {
                        c.userName,
                        c.gender,
                    };

            var result = t.ToList();
            string userPhoto = "images/no-pic.jpg";
            for (int i = 0; i < result.Count; i++)
            {
                if (result[i].gender == 1)
                {
                    userPhoto = "images/nansheng-small.png";
                }
                else if (result[i].gender == 2)
                {
                    userPhoto = "images/nvhai-small.png";
                }


                string value = GetListItemDiv(result[i].userName, userName, userPhoto);
                sb.Append(value);
            }
            commentList.InnerHtml = sb.ToString();

        }

        private void Get_MyTopUser(string userName)
        {
            StringBuilder sb = new StringBuilder();

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from c in piano.Users
                    where !c.userName.Equals(userName) 
                    && !(from o in piano.Attention 
                            where o.userName.Equals(userName) select o.attentionUser).Contains(c.userName)
                          
                    select new
                    {
                        c.userName,
                        c.gender,
                    };

            var result = t.ToList();
            string userPhoto = "images/no-pic.jpg";


            int cnt = 10;//max 10
            if (result.Count < cnt)
            {
                cnt = result.Count;
            }


            for (int i = 0; i < cnt; i++)
            {
                if (result[i].gender == 1)
                {
                    userPhoto = "images/nansheng-small.png";
                }
                else if (result[i].gender == 2)
                {
                    userPhoto = "images/nvhai-small.png";
                }


                string value = GetListItemDiv(result[i].userName, userName, userPhoto);
                sb.Append(value);
            }
            commentList.InnerHtml = sb.ToString();

        }

        private void Get_MySearchUsers(string userName, string key)
        {
            StringBuilder sb = new StringBuilder();

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from c in piano.Users
                    where !c.userName.Equals(userName) 
                    && !(from o in piano.Attention
                             where o.userName.Equals(userName)
                             select o.attentionUser).Contains(c.userName)

                    && c.userName.Contains(key)
                    select new
                    {
                        c.userName,
                        c.gender,
                    };

            var result = t.ToList();
            string userPhoto = "images/no-pic.jpg";

            for (int i = 0; i < result.Count; i++)
            {
                if (result[i].gender == 1)
                {
                    userPhoto = "images/nansheng-small.png";
                }
                else if (result[i].gender == 2)
                {
                    userPhoto = "images/nvhai-small.png";
                }


                string value = GetListItemDivEx(i, result[i].userName, userName, userPhoto);
                sb.Append(value);
            }
            commentList.InnerHtml = sb.ToString();
            hidenCount.Value = Convert.ToString(result.Count);
        }

        /// <summary>
        /// 添加好友
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="attentionUser"></param>
        private void Add_Friends(string userName, string attentionUser)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var newEnity = new Attention
            {
                userName = userName,
                attentionUser = attentionUser,
                dCreate = DateTime.Now
            };

            piano.Attention.InsertOnSubmit(newEnity);
            piano.SubmitChanges();
        }

        private string GetListItemDiv(string accessUser, string userName, string userPhoto) 
        {
            string result = "<div class=\"tiao\"><a href=\"Work.aspx?username=" + accessUser +
                "&accessUser=" + userName + "\"><div class=\"tt\"> <span> <img src=\"" + userPhoto +
                    "\"></span>" + accessUser +
                    "</div><div class=\"ok2\"><img src=\"images/youfuhao-01.png\"></div></a></div>";
            return result;
        }

        private string GetListItemDivEx(int i, string accessUser, string userName, string userPhoto)
        {
            string result = "<div class=\"tiao\"><a href=\"Work.aspx?username=" + accessUser +
                "&accessUser=" + userName + "\"><div class=\"tt\"><input type=\"checkbox\" id=\"chk_" +
                i + "\"> <input type=\"hidden\" id=\"hid_aces_usr_" + i + "\" value=\"" + accessUser  + "\">" +
                "<span> <img src=\"" + userPhoto +
                    "\"></span>" + accessUser +
                    "</div><div class=\"ok2\"><img src=\"images/youfuhao-01.png\"></div></a></div>";
            return result;
        }
    }
}
