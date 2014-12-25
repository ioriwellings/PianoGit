using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.IO;

namespace PianoWeb
{
    /// <summary>
    /// $codebehindclassname$ 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class checkForUpdate : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            System.Web.HttpResponse Response = context.Response;
            
            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.Buffer = true;
            Response.Charset = "utf-8";

            string strDir = context.Server.MapPath("/updateZIP");
            if (Directory.Exists(strDir) == false )
            {
                Response.End();
            }

            if (context.Request["update"] == null)
            {
                string strFileNme = System.Web.HttpUtility.UrlEncode("UPDATE.ZIP");
                Response.AddHeader("Content-Disposition", "attachment; filename=" + strFileNme);
                Response.ContentEncoding = System.Text.Encoding.GetEncoding("utf-8");
                Response.ContentType = "application/octet-stream";

                string[] files = Directory.GetFiles(strDir);
                using(FileStream file = new FileStream(files[0], FileMode.Open))
                {
                    byte[] buffer = new byte[4096];
                    while (file.Read(buffer, 0, buffer.Length) > 0)
                    {
                        Response.BinaryWrite(buffer);
                    }
                }
            }
            else
            {
                string strDate = context.Request["update"];
                string[] files = Directory.GetFiles(strDir);
                System.IO.FileInfo fileInfo = new FileInfo(files[0]);
                var strArray = Path.GetFileNameWithoutExtension(fileInfo.Name).Split(null);
                if (strArray.Length > 1) strArray[1] = strArray[1].Replace("-", ":");
                string strFileName = string.Join(" ", strArray);
                /*
                strArray = strDate.Split(null);
                if (strArray.Length > 1) strArray[1] = strArray[1].Replace("-", ":");
                strDate = string.Join(" ", strArray);
                 * */
                if(System.DateTime.Compare(DateTime.Parse(strDate) , DateTime.Parse(strFileName) ) < 0 )
                {
                    string strFileNme = System.Web.HttpUtility.UrlEncode("UPDATE.ZIP");
                    Response.AddHeader("Content-Disposition", "attachment; filename=" + strFileNme);
                    Response.ContentEncoding = System.Text.Encoding.GetEncoding("gb2312");
                    Response.ContentType = "application/octet-stream";
                    using (FileStream file = new FileStream(files[0], FileMode.Open))
                    {
                        byte[] buffer = new byte[4096];
                        while (file.Read(buffer, 0, buffer.Length) > 0)
                        {
                            Response.BinaryWrite(buffer);
                        }
                    }
                }
            }
            
            Response.Flush();
            Response.End();
            
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
