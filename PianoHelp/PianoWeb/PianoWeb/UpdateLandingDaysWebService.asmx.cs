using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace PianoWeb
{
    /// <summary>
    /// UpdateLandingDaysWebService 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。
    // [System.Web.Script.Services.ScriptService]
    public class UpdateLandingDaysWebService : System.Web.Services.WebService
    {

        [WebMethod]
        public string updateLandingDays(string userName, string days)
        {
            String result = "OK";
            try
            {
                if (days.Equals(""))
                {
                    return "days lenght is 0";
                }

                PianoDataClassesDataContext piano = new PianoDataClassesDataContext();

                var u = from item in piano.Users
                        where item.userName.Equals(userName)
                        select item;
                var r = u.ToList();
                if (r.Count() > 0)
                {
                    r[0].landingDays = Convert.ToInt32(days);
                }

                piano.SubmitChanges();
            }
            catch (Exception ex)
            {
                result = ex.Message;
            }

            return result;
        }
    }
}
