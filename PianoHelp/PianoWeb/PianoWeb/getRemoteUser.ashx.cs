using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PianoWeb
{

    internal class JSONUser
    {
        public string userName
        {
            set;
            get;
        }

        public string pwd
        {
            set;
            get;
        }

        public string days
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
    public class getRemoteUser : IHttpHandler
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
            string strPwd = context.Request["pwd"];
            if (strPwd == null || strPwd.Equals(""))
            {
                return;
            }

            using (PianoDataClassesDataContext piano = new PianoDataClassesDataContext())
            {
                var jserial = new JavaScriptSerializer();
                var result = piano.Users.Where(user => user.userName.Equals(strUser.Trim()) && user.password.Equals(strPwd.Trim())).FirstOrDefault();
                if (result == null)
                {

                }
                else
                {
                    var u = new JSONUser()
                    {
                        userName = result.userName,
                        pwd = result.password,
                        days = Convert.ToString(result.landingDays)
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
