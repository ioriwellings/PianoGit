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
    /// <summary>
    /// 作品集页面
    /// </summary>
    public partial class Work : System.Web.UI.Page
    {
        private static int SONG_MAX = 6;
        private string userPhotoPath = "";
        private string accessUser = "";


        protected void Page_Load(object sender, EventArgs e)
        {

            string userName = Request.Params["userName"];
            accessUser = Request.Params["accessUser"];

            //userName = "iori";
            if (userName != null)
            {
                lblUserName.Text = userName;

                Get_User_Info(userName);
                GetUserOpus(userName);

                //UpdateDB("you.mp3", "./iori/you.mp3", userName, "80");
            }
        }


        /// <summary>
        /// 取得用户信息
        /// </summary>
        /// <param name="userName">用户ID</param>
        private void Get_User_Info(string userName)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Users
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                DateTime d = Convert.ToDateTime(result[0].birthday);
                string s1 = PianoWeb.Common.Common.GetConstellation(d);
                string s2 = PianoWeb.Common.Common.GetOO(d);

                lblOtherInfo1.Text = s2 + " " + s1 + "  " + result[0].address;
                lblOtherInfo2.Text = result[0].memo;
                if (result[0].gender == 1)
                {
                    userPhotoPath = "images/nansheng-big.png";
                }
                else if (result[0].gender == 2)
                {
                    userPhotoPath = "images/nvhai-big.png";
                }
                else
                {
                    userPhotoPath = "images/user-photo.jpg";
                }


                userPhoto.ImageUrl = userPhotoPath;
                lblLevel.Text = GetUserLevel(Convert.ToUInt32(result[0].landingDays));
            }
        }

        /// <summary>
        /// 取得作品集
        /// </summary>
        /// <param name="userName"></param>
        private void GetUserOpus(string userName)
        {
            StringBuilder sb = new StringBuilder();
            int length = SONG_MAX;
            int totalClick = 0;
            int totalLike = 0;

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Opus
                    where item.userName.Equals(userName) orderby item.dCreate descending
                    select item;
            var result = t.ToList();
            if (result.Count < length)
            {
                length = result.Count;
            }

            for (int i = 0; i < length; i++)
            {
                string comment = getOpusComment(result[i].ID);

                totalClick += Convert.ToInt32(result[i].clickCount);
                totalLike += Convert.ToInt32(result[i].likeCount);

                string divMessage = CreateOneOpus(userName, 
                                                  result[i].mp3Path,
                                                  userPhotoPath,
                                                  Path.GetFileNameWithoutExtension(result[i].name),
                                                  Convert.ToInt32(result[i].clickCount),
                                                  Convert.ToInt32(result[i].likeCount),
                                                  comment,
                                                  Convert.ToString(result[i].ID));
                sb.Append(divMessage);
                sb.Append("  ");
            }

            opusList.InnerHtml = sb.ToString();

            lblLisnten.Text = Convert.ToString(totalClick) + "人听过";
            lblLike.Text = "收到" + Convert.ToString(totalLike) + "个赞";
        }

        /// <summary>
        /// 取得作品评论
        /// </summary>
        /// <param name="opusID"></param>
        /// <returns></returns>
        private string getOpusComment(Guid opusID)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.OpusComment
                    where item.opusID.Equals(opusID)
                    orderby item.dCreate descending
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                return result[0].comment;
            }
            else
            {
                return "";
            }
        }


        /// <summary>
        /// 取得级别信息
        /// </summary>
        /// <param name="level"></param>
        /// <returns></returns>
        private string GetUserLevel(uint level)
        {
            if (level != 0)
            {
                int j = (int)level / 3;
                return j + "级";
            }
            else
            {
                return "无级别";
            }

        }

        /// <summary>
        /// 创建曲目DIV
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="mp3Path"></param>
        /// <param name="userPhoto"></param>
        /// <param name="opusName"></param>
        /// <param name="clickCount"></param>
        /// <param name="likeCount"></param>
        /// <param name="comment"></param>
        /// <returns></returns>
        private string CreateOneOpus(string userName, string mp3Path, string userPhoto, 
            string opusName, int clickCount, int likeCount, string comment, string opusID)
        {

            StringBuilder sb = new StringBuilder();
            sb.Append("<div class=\"box\">");
            sb.Append("  <a href=\"WorkShow.aspx?userName=" + userName + "&accessUser=" + accessUser + "&opusID=" + opusID + "\">");
            sb.Append("  <div class=\"title\">" );
            sb.Append("    <div class=\"photo\"><img src=\"" + userPhoto + "\"></div>");
            sb.Append("      <div class=\"right\">" );
            sb.Append("        <h2>" + opusName + "</h2>");
            sb.Append("        <p>" + userName + "</p>");
            sb.Append("        <div class=\"dibu\"><img src=\"images/work-02.png\">" + 
                                Convert.ToString(clickCount) + "人听过&nbsp;&nbsp;&nbsp;&nbsp");
            sb.Append(";<img src=\"images/work-03.png\">收到" + Convert.ToString(likeCount) + "个赞</div>");
            sb.Append( "     </div>");
            sb.Append("    </div>");
            sb.Append("  </a>");
            sb.Append("</div>");
            return sb.ToString();
        }


        private void UpdateDB(String midiFileName, String path, String userName, String scroe)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Opus
                    where item.name.Equals(midiFileName) && item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count() > 0)
            {
                result[0].score = int.Parse(scroe);
                result[0].dCreate = DateTime.Now;

            }
            else
            {
                var newEnity = new Opus
                {
                    name = midiFileName,
                    mp3Path = path,
                    userName = userName,
                    score = int.Parse(scroe)
                };
                piano.Opus.InsertOnSubmit(newEnity);
            }
            piano.SubmitChanges();
        }
    }
}
