using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using JdSoft.Apple.AppStore;

namespace PianoWeb
{
    /// <summary>
    /// $codebehindclassname$ 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class VerfyIAP : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write(ReceiptVerification.GetReceipt(true, context.Request["receiptData"]));
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
