using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml.Linq;

namespace PianoWeb
{
    /// <summary>
    /// $codebehindclassname$ 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class PListCreater : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/xml";
            string strPath = context.Server.MapPath("dataList.csv");
            string[] strCSVData = System.IO.File.ReadAllLines(strPath);
            var arrayGroupByAuthor = from authorGroup in strCSVData
                                     let authorRow = authorGroup.Split(',')
                                     group authorRow by authorRow[4] into g
                                     select g;
            var query = arrayGroupByAuthor.Select((_groupRow, index) => new {index, _groupRow});          

                //let a = new XElement("key", groupItem.Key)
                //let b = (from item in groupItem
                //         select item).Select((ele, i) =>
                                            
                //                                new XElement("key", i+1),
                //                                new XElement("dict",
                //                                    new XElement("key", "作者"),
                //                                    new XElement("string", ele[0])
                //                                )
                //                                )
                //                            )
                //select b 
                //    );

            var rootDict = new XElement("dict");
            foreach (var groupItem in arrayGroupByAuthor)
            {
                var key = new XElement("key", groupItem.Key);
                rootDict.Add(key);

                var dict_childOf_key = new XElement("dict");
                rootDict.Add(dict_childOf_key);
                var iCount = 1;
                foreach (var melodyItem in groupItem)
                {
                    var key_number = new XElement("key", iCount);
                    dict_childOf_key.Add(key_number);
                    var dict_childOf_keyNumber = new XElement("dict",
                                    new XElement("key", "作者"),
                                    new XElement("string", melodyItem[0]),

                                    new XElement("key", "曲谱名称"),
                                    new XElement("string", melodyItem[1]),

                                    new XElement("key", "类别"),
                                    new XElement("string", melodyItem[2]),

                                    new XElement("key", "出版社"),
                                    new XElement("string", melodyItem[3]),

                                    new XElement("key", "作品集"),
                                    new XElement("string", melodyItem[4]),

                                    new XElement("key", "年份"),
                                    new XElement("string", melodyItem[5]),

                                    new XElement("key", "级别"),
                                    new XElement("string", melodyItem[6])
                                    );
                    dict_childOf_key.Add(dict_childOf_keyNumber);
                    iCount++;
                }
            }

            context.Response.Write(rootDict);

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
