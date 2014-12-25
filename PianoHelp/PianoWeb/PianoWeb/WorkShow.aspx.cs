using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.IO;

namespace PianoWeb
{
    public partial class WorkShow : System.Web.UI.Page
    {
        private string opusPath = "";
        private string userPhotoPath = "";
        private string accessUser = "";
        //appkey="3371543544"

        protected void Page_Load(object sender, EventArgs e)
        {
            string listen = Request.Params["listen"];
            string userName = Request.Params["userName"];
            Guid opusID = new Guid(Request.Params["opusID"]);
            accessUser = Request.Params["accessUser"];
            hidenAccUser.Value = accessUser;

            hidenUser.Value = userName;
            hidenOpusID.Value = Request.Params["opusID"];

            try
            {
                if (listen != null)
                {
                    if (listen.Equals("yes"))
                    {
                        LoveAndClick(opusID, 1);
                    }
                }
                else
                {
                    lblUserName.Text = userName;
                    GetUserInfo(userName);
                    GetOpusInfo(userName, opusID);
                    GetOpusComment(opusID);
                }

               
            }
            catch (Exception ex)
            {
            }
        }

        /// <summary>
        /// 取得用户信息
        /// </summary>
        /// <param name="userName">用户ID</param>
        private void GetUserInfo(string userName)
        {
            if (userName == null) return;

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Users
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                if (result[0].gender == 1)
                {
                    userPhotoPath = "images/nansheng-big.png";
                }
                else if (result[0].gender == 2)
                {
                    userPhotoPath = "images/nvhai-big.png";
                } else 
                {
                    userPhotoPath = "images/user-photo.jpg";
                }
                
                userPhoto.ImageUrl = userPhotoPath;
 
            }
        }

        /// <summary>
        /// 曲目信息
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="opusID"></param>
        private void GetOpusInfo(string userName, Guid opusID)
        {
            if (userName == null || opusID == null) return;

            StringBuilder sb = new StringBuilder();
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Opus
                    where item.userName.Equals(userName) && item.ID.Equals(opusID)
                    orderby item.dCreate descending
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                lblClickInfo.Text = Convert.ToString(result[0].clickCount) + "人听过";
                hidenListen.Value = Convert.ToString(result[0].clickCount);
                lblLoveInfo.Text = "收到" + Convert.ToString(result[0].likeCount) + "个赞";
                hidenPath.Value = result[0].mp3Path;
            }
        }

        /// <summary>
        /// 取得曲目评论
        /// </summary>
        /// <param name="opusID"></param>
        private void GetOpusComment(Guid opusID)
        {
            if (opusID == null) return;

            StringBuilder sb = new StringBuilder();
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();

            var t = from item in piano.OpusComment join us in piano.Users
                on item.userName equals us.userName where item.opusID.Equals(opusID)
                 orderby item.dCreate descending
                 select new
                 {
                     us.userName,
                     us.gender,
                     item.comment,
                 };

            string userPhoto = "images/no-pic.jpg";
            var result = t.ToList();
            for(int i = 0; i < result.Count; i++)
            {
                if (result[i].gender == 1)
                {
                    userPhoto = "images/nansheng-small.png";
                }
                else if (result[i].gender == 2)
                {
                    userPhoto = "images/nvhai-small.png";
                }
                

                string value = GetListDataDiv(result[i].userName, userPhoto, result[i].comment);
                sb.Append(value);
            }

            lblMessageCount.Text = "共有" + result.Count.ToString() + "条评论";
            commentList.InnerHtml = sb.ToString();
        }


        /// <summary>
        /// 得到曲目评论list div字符串
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="userPhoto"></param>
        /// <param name="comment"></param>
        /// <returns></returns>
        private string GetListDataDiv(string userName, string userPhoto, string comment)
        {

            StringBuilder sb = new StringBuilder();
            sb.Append("<div class=\"tiao\"><a href=\"#\">");

            sb.Append("<div class=\"tt\"> <span> <img src=\"" + userPhoto
                + "\"></span>" + comment + "</div>");

            sb.Append("</a></div>");

            return sb.ToString();
        }


        /// <summary>
        /// 更新点赞和听过DB数据
        /// </summary>
        /// <param name="opusID"></param>
        /// <param name="type"></param>
        private void LoveAndClick(Guid opusID, int type)
        {

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Opus
                    where item.ID.Equals(opusID)
                    select item;
            var result = t.ToList();
            int value = 0;
            if (result.Count() > 0)
            {
                if (type == 1)
                {
                    if (result[0].clickCount == null)
                    {
                        value = 1;
                    }
                    else
                    {
                        value = Convert.ToInt32(result[0].clickCount) + 1;

                    }
                    result[0].clickCount = value;
                }
                else if (type == 2)
                {
                    if (result[0].likeCount == null)
                    {
                        value = 1;
                    }
                    else
                    {
                        value = Convert.ToInt32(result[0].likeCount) + 1;
                    }

                    result[0].likeCount = value;
                }
                
            }
            piano.SubmitChanges();
        }

        /// <summary>
        /// 取得曲目评论信息
        /// </summary>
        /// <param name="name"></param>
        /// <param name="id"></param>
        /// <param name="comments"></param>
        private void addComment(string name, Guid id,string comments)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var newEnity = new OpusComment
            {
                userName = name,
                opusID = id,
                comment = comments,
                dCreate = DateTime.Now
            };

            piano.OpusComment.InsertOnSubmit(newEnity);
            piano.SubmitChanges();
        }

        /// <summary>
        /// 添加关注DB数据
        /// </summary>
        /// <param name="name"></param>
        /// <param name="attentionUsers"></param>
        private void addAttention(string name, string attentionUsers)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var newEnity = new Attention
            {
                userName = name,
                attentionUser = attentionUsers,
                dCreate = DateTime.Now
            };

            piano.Attention.InsertOnSubmit(newEnity);
            piano.SubmitChanges();
        }


        /// <summary>
        /// 点赞按钮事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLove_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                string userName = Request.Params["userName"];
                Guid opusID = new Guid(Request.Params["opusID"]);
                LoveAndClick(opusID, 2);
                GetOpusInfo(userName, opusID);
            }
            catch (Exception ex)
            {
            }
        }

        /// <summary>
        /// 删除按钮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnDel_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                string userName = Request.Params["userName"];
                Guid opusID = new Guid(Request.Params["opusID"]);

                //删除作品
                PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
                var t = from item in piano.Opus
                        where item.ID.Equals(opusID)
                        select item;
                piano.Opus.DeleteAllOnSubmit(t);

                //删除作品评论
                var r = from item in piano.OpusComment
                        where item.opusID.Equals(opusID)
                        select item;
                piano.OpusComment.DeleteAllOnSubmit(r);


                piano.SubmitChanges();

                string url = "\\Work.aspx?userName=" + userName;
                Server.Transfer(url); 
            }
            catch (Exception ex)
            {
                
            }

        }

        /// <summary>
        /// 分享按钮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnShare_Click(object sender, ImageClickEventArgs e)
        {
   //            string username = "t@cnblogs.com";
   //string password = "cnblogs.com";
   //string usernamePassword = username + ":" + password;


   //         string url = "http://api.t.sina.com.cn/statuses/update.json";
   //         string news_title = "VS2010网剧合集：讲述程序员的爱情故事";
   //         int news_id = 62747;
   //         string t_news = string.Format("{0}，http://news.cnblogs.com/n/{1}/", news_title, news_id);
   //         string data = "source=123456&status=" + System.Web.HttpUtility.UrlEncode(t_news);

   //         System.Net.WebRequest webRequest = System.Net.WebRequest.Create(url);
   //         System.Net.HttpWebRequest httpRequest = webRequest as System.Net.HttpWebRequest;

   //         System.Net.CredentialCache myCache = new System.Net.CredentialCache();
   //         myCache.Add(new Uri(url), "Basic", new System.Net.NetworkCredential(username, password));
   //         httpRequest.Credentials = myCache;
   //         httpRequest.Headers.Add("Authorization", "Basic " +
   //      Convert.ToBase64String(new System.Text.ASCIIEncoding().GetBytes(usernamePassword)));


   //         httpRequest.Method = "POST";
   //         httpRequest.ContentType = "application/x-www-form-urlencoded";
   //         System.Text.Encoding encoding = System.Text.Encoding.ASCII;
   //         byte[] bytesToPost = encoding.GetBytes(data);
   //         httpRequest.ContentLength = bytesToPost.Length;
   //         System.IO.Stream requestStream = httpRequest.GetRequestStream();
   //         requestStream.Write(bytesToPost, 0, bytesToPost.Length);
   //         requestStream.Close();




   //          System.Net.WebResponse wr = httpRequest.GetResponse();
   // System.IO.Stream receiveStream = wr.GetResponseStream();
   // using (System.IO.StreamReader reader = new System.IO.StreamReader(receiveStream, System.Text.Encoding.UTF8)
   // {
   //     string responseContent = reader.ReadToEnd();
   // }    System.Net.WebResponse wr = httpRequest.GetResponse();
   // System.IO.Stream receiveStream = wr.GetResponseStream();
   // using (System.IO.StreamReader reader = new System.IO.StreamReader(receiveStream, System.Text.Encoding.UTF8)
   // {
   //     string responseContent = reader.ReadToEnd();
   // }
    
        }

        /// <summary>
        /// 发送评论按钮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSend_Click(object sender, ImageClickEventArgs e)
        {
            Guid opusID = new Guid(Request.Params["opusID"]);
            string comment = txtMessage.Text;

            if (comment.Length == 0)
            {
                return;
            }

            try
            {
                if (accessUser == null || accessUser == "")
                {
                    accessUser = Request.Params["userName"];
                }

                addComment(accessUser, opusID, comment);
                GetOpusComment(opusID);
            }
            catch (Exception ex)
            {
            }
        }
    }
}
