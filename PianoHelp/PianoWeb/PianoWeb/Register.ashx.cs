using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace PianoWeb
{
    /// <summary>
    /// $codebehindclassname$ 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class Register : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            string strUser = context.Request["userName"];
            if (strUser != null)
            {
                strUser = strUser.Trim();
            }
            string strPwd = context.Request["pwd"];
            string strSex = context.Request["sex"];
            string strEMail = context.Request["email"];
            string strAddr = context.Request["address"];
            string strBirthday = context.Request["birthday"];
            string strVerifyCode = context.Request["verifycode"];
            string strSessionVerifyCode = (string)context.Session["VerifyCode"];


            var jserial = new JavaScriptSerializer();
            var info = new RegisterInfo();
            if (!strSessionVerifyCode.Equals(strVerifyCode))
            {
                info.success = false;
                info.error = new RegisterError();
                info.error.message = "验证码无效!";
                info.error.errorCode = 2;
                context.Response.Write(jserial.Serialize(info));
                return;
            }
            using (PianoDataClassesDataContext piano = new PianoDataClassesDataContext())
            {
                if(piano.Users.Where(user => user.userName.Equals(strUser)).Count()>0)
                {          
                    info.error = new RegisterError();
                    info.error.errorCode = 1;
                    info.error.message = "该用户已经存在!";
                    string strResult = jserial.Serialize(info);
                    context.Response.Write(strResult);
                    //context.Response.Write("{\"success\":\"NO\", \"error\":{\"errorCode\":1, \"message\":\"该用户已经存在!\"}}");
                    return;
                }
                DateTime birthday;
                DateTime.TryParse(strBirthday, out birthday);
                piano.Users.InsertOnSubmit(new Users{
                    userName=strUser, 
                    password=strPwd,
                    email = strEMail,
                    address = strAddr,
                    birthday = birthday,
                    gender = Byte.Parse(strSex)
                });
                piano.SubmitChanges();
            }
            info.success = true;
            context.Response.Write(jserial.Serialize(info));
            //context.Response.Write(context.Server.HtmlDecode(jserial.Serialize("<p><a href=\"http://www.google.com\">google</a></p>")));
            //context.Response.Write("{\"success\":\"YES\"}");
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }

    internal class RegisterError
    {
        public int errorCode
        {
            set;
            get;
        }

        public string message
        {
            get;
            set;
        }
    }

    internal class RegisterInfo
    {
        public bool success
        {
            get;
            set;
        }

        public RegisterError error
        {
            get;
            set;
        }
    }
}
