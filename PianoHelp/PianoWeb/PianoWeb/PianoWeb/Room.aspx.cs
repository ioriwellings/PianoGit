using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PianoWeb
{
    public partial class Room : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string userName = Request.Params["userName"];
            userName = "iori";
            hidenUser.Value = userName;

            string buy = Request.Params["buy"];
            if (buy == null)
            {
                GetDefaultData();
                if (userName != null)
                {
                    GetUserHouseData(userName);
                    hidenType.Value = "0";
                }
            }
            else
            {

            }
        }

        /// <summary>
        /// 加载大厅默认数据
        /// </summary>
        private void GetDefaultData()
        {
            deng1.ImageUrl = "images/room-deng.png";
            deng2.ImageUrl = "images/room-deng.png";
            deng3.ImageUrl = "images/room-deng2.png";
            gangqin.ImageUrl = "images/room-gangqin.png";
            bihua.ImageUrl = "images/room-bihua.png";
            guizi.ImageUrl = "images/room-guizi.png";
            shafa.ImageUrl = "images/room-shafa.png";
        }

        /// <summary>
        /// 取得大厅数据
        /// </summary>
        /// <param name="userName"></param>
        private void GetUserHouseData(string userName)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.House
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {

                string gq = GetUserAdornment(Convert.ToString(result[0].pianoID), 1);
                string gz = GetUserAdornment(Convert.ToString(result[0].floorID), 2);
                string sf = GetUserAdornment(Convert.ToString(result[0].sofaID), 3);
                string bh = GetUserAdornment(Convert.ToString(result[0].frescoID), 4);
                string dd = GetUserAdornment(Convert.ToString(result[0].pendantLampID), 5);

                if (!gq.Equals(""))
                {
                    gangqin.ImageUrl = gq;
                }

                if (!gz.Equals(""))
                {
                    guizi.ImageUrl = gz;
                }

                if (!sf.Equals(""))
                {
                    shafa.ImageUrl = sf;
                }

                if (!bh.Equals(""))
                {
                    bihua.ImageUrl = bh;
                }

                if (!dd.Equals(""))
                {
                    deng3.ImageUrl = dd;
                }
            }
        }

        /// <summary>
        /// 取得用户装饰
        /// </summary>
        /// <param name="id"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        private string GetUserAdornment(String id, int type)
        {
            string path = "";
            Guid key = new Guid(id);
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Adornment
                    where item.ID.Equals(key) && item.type.Equals(type)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                path = Convert.ToString(result[0].imagePath);
            }

            return path;
        }

        /// <summary>
        /// 添加购买商品信息
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="adormentID"></param>
        private void AddUserAdornment(string userName, Guid adormentID, int coins)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var newEnity = new UsersAdornment
            {
                userName = userName,
                adornmentID = adormentID,
                dCreate = DateTime.Now
            };

            piano.UsersAdornment.InsertOnSubmit(newEnity);



            var u = from item in piano.Users
                    where item.userName.Equals(userName)
                    select item;
            var r = u.ToList();
            if (r.Count() > 0)
            {
                r[0].scroe = Convert.ToInt32(r[0].scroe) - coins;
            }


            piano.SubmitChanges();
        }


        /// <summary>
        /// 更新大厅数据
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="id"></param>
        /// <param name="type"></param>
        private void UpdateHouseDB( String userName, Guid id, int type)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.House
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count() > 0)
            {
                switch (type)
                {
                    case 1:
                        result[0].pianoID = id;
                        break;
                    case 2:
                        result[0].floorID = id;
                        break;
                    case 3:
                        result[0].sofaID = id;
                        break;
                    case 4:
                        result[0].frescoID = id;
                        break;
                    case 5:
                        result[0].pendantLampID = id;
                        break;
                }

                result[0].dCreate = DateTime.Now;
            }
            else
            {
                var newEnity = new House
                {
                    userName = userName
                };

                switch (type)
                {
                    case 1:
                        newEnity.pianoID = id;
                        break;
                    case 2:
                        newEnity.floorID = id;
                        break;
                    case 3:
                        newEnity.sofaID = id;
                        break;
                    case 4:
                        newEnity.frescoID = id;
                        break;
                    case 5:
                        newEnity.pendantLampID = id;
                        break;
                }

                piano.House.InsertOnSubmit(newEnity);
            }
            piano.SubmitChanges();
        }



        private void getUserAdornment(string name)
        {
            

        }

        



        private void addAdornmentDatas()
        {
            short []types  = {1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 5, 5, 5, 5};

                                 
            string[] names = { "钢琴1", 
                               "钢琴2",
                               "钢琴3",
                               "钢琴4",
                               "钢琴5",

                               "柜子1",
                               "柜子2",
                               "柜子3",
                               "柜子4",                                 
                                 

                               "沙发1",
                               "沙发2",
                               "沙发3",
                               "沙发4",  
                                 
                               "壁画1",
                               "壁画2",                   
                               

                               "吊灯1",
                               "吊灯2",
                               "吊灯3",
                               "吊灯4"};


            string[] paths = { "images/adornments/gangqin/room-gangqin1.png", 
                               "images/adornments/gangqin/room-gangqin2.png",
                               "images/adornments/gangqin/room-gangqin3.png",
                               "images/adornments/gangqin/room-gangqin4.png",
                               "images/adornments/gangqin/room-gangqin5.png",

                               "images/adornments/guizi/room-guizi1.png",
                               "images/adornments/guizi/room-guizi2.png",
                               "images/adornments/guizi/room-guizi3.png",
                               "images/adornments/guizi/room-guizi4.png",                                 
                                 

                               "images/adornments/shafa/room-shafa1.png",
                               "images/adornments/shafa/room-shafa2.png",
                               "images/adornments/shafa/room-shafa3.png",
                               "images/adornments/shafa/room-shafa4.png",  
                                 
                               "images/adornments/bihua/room-bihua1.png",
                               "images/adornments/bihua/room-bihua2.png",                   
                               

                               "images/adornments/deng/room-deng1.png",
                               "images/adornments/deng/room-deng2.png",
                               "images/adornments/deng/room-deng3.png",
                               "images/adornments/deng/room-deng4.png"};

            int[] prices = { 8000, 9000, 10000, 11000, 12000, 
                             2000, 3000, 4000, 5000, 
                             3000, 4000, 5000, 6000, 
                             300, 400, 
                             600, 700, 800, 900 };

            for (int i = 0; i < types.Length; i++)
            {
                AddAdornment(types[i], names[i], paths[i], prices[i]);
            }

        }

        private void AddAdornment(short type, string name, string path, int price)
        {
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var newEnity = new Adornment
            {
                type = type,
                name = name,
                imagePath = path,
                price = price,
                dCreate = DateTime.Now
            };

            piano.Adornment.InsertOnSubmit(newEnity);
            piano.SubmitChanges();
        }

    }
}
