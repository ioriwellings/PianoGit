using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.IO;

namespace PianoWeb
{
    /// <summary>
    /// UpLoadFileWebService 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。
    // [System.Web.Script.Services.ScriptService]
    public class UpLoadFileWebService : System.Web.Services.WebService
    {

        [WebMethod]
        //public string UpLoadFile(string midiFileName, string fileData, string userName, string scroe)
        public string UpLoadFile(string midiFileName, string fileData, string userName, string scroe, string coins)
        {
            String result = "OK";
            try
            {
                byte[] bytes = Convert.FromBase64String(fileData);

                string savePath = Server.MapPath("./") + userName;
                if (!Directory.Exists(savePath))//判断是否存在
                {
                    Directory.CreateDirectory(savePath);//创建新路径
                   
                }
                savePath += "\\" + midiFileName;

                //1.定义并实例化一个内存流，以存放提交上来的字节数组
                MemoryStream memoryStream = new MemoryStream(bytes);
                //MemoryStream memoryStream = new MemoryStream(fileData);

                //2.定义实际文件对象，保存上载的文件
                FileStream fileUpload = new FileStream(savePath, FileMode.Create);

                //3.把内存流里的数据写入物理文件
                memoryStream.WriteTo(fileUpload); 

                //4.关闭内存流
                memoryStream.Close();
                fileUpload.Close();
                fileUpload = null;
                memoryStream = null;

                String f = "./" + userName + "/" + midiFileName;
                //5.向Opus添加一条记录

                UpdateDB(midiFileName, f, userName, scroe, coins);
            }
            catch (Exception ex)
            {
                result = ex.Message;
            }

            return result;
        }



        /// <summary>
        /// 向Opus添加数据
        /// </summary>
        /// <param name="midiFileName">midi文件名</param>
        /// <param name="path">路径</param>
        /// <param name="userName">用户名</param>
        /// <param name="scroe">成绩</param>
        private void UpdateDB(string midiFileName, string path, string userName, string scroe, string coins)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Opus
                    where item.name.Equals(midiFileName) && item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (!scroe.Equals("") && !scroe.Equals("0"))
            {
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
            }


            var u = from item in piano.Users
                    where item.userName.Equals(userName)
                    select item;
            var r = u.ToList();
            if (r.Count() > 0)
            {
                r[0].scroe = Convert.ToInt32(r[0].scroe) + Convert.ToInt32(coins);
            }

            piano.SubmitChanges();
        }
    }
}
