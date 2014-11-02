using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;


namespace PianoWeb
{
    internal class JSONUserCoins
    {
        public int Coins
        {
            set;
            get;
        }
    }

    /// <summary>
    /// $codebehindclassname$ 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class getUserCoins : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Clear();
            string strUser = context.Request["userName"];
            if (strUser == null || strUser.Equals(""))
            {
                return;
            }


            using (PianoDataClassesDataContext piano = new PianoDataClassesDataContext())
            {
                var jserial = new JavaScriptSerializer();
                var result = piano.Users.Where(user => user.userName.Equals(strUser.Trim())).FirstOrDefault();
                if (result == null)
                {

                }
                else
                {
                    var u = new JSONUserCoins()
                    {
                        Coins = Convert.ToInt32(result.scroe),
                    };
                    context.Response.Write(jserial.Serialize(u));
                }
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
