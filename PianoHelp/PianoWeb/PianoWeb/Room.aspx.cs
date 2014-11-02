using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Text;

namespace PianoWeb
{
    public partial class Room : System.Web.UI.Page
    {
        private ArrayList ids = new ArrayList();

        protected void Page_Load(object sender, EventArgs e)
        {
            string userName = Request.Params["userName"];
            hidenUser.Value = userName;

            string option = Request.Params["option"];

            getUserAllAdornments(userName);
            GetUserInfo(userName);
            if (option == null)
            {
                GetDefaultData();
                if (userName != null)
                {
                    GetUserHouseData(userName);
                    hidenType.Value = "0";
                }

                hidenGangqinIndex.Value = "0";
                hidenShafaIndex.Value = "0";
                hidenGuiziIndex.Value = "0";
                hidenBihuaIndex.Value = "0";
                hidenDengIndex.Value = "0";
            }
            else
            {
                string id = Request.Params["adornment_id"];
                int opt = Convert.ToInt32(option);
                int type = Convert.ToInt32(Request.Params["type"]);

                if (opt == 2)
                {
                    int coins = Convert.ToInt32(Request.Params["coins"]);

                    AddUserAdornment(userName, new System.Guid(id), coins);
                }
                UpdateHouseDB(userName, new System.Guid(id), type);
            }
        }


        /// <summary>
        /// 取得用户信息
        /// </summary>
        /// <param name="userName">用户ID</param>
        private void GetUserInfo(string userName)
        {
            if (userName == null) return;

            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Users
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                lblMoney.Text = Convert.ToString(result[0].scroe);
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
                string name = "";
                int price = 0;
                short type = 0;
                string gq = "";
                GetUserAdornment(Convert.ToString(result[0].pianoID), ref type,ref name, ref gq, ref price);
                string gz = "";
                GetUserAdornment(Convert.ToString(result[0].floorID), ref type, ref name, ref gz, ref price);
                string sf = "";
                GetUserAdornment(Convert.ToString(result[0].sofaID), ref type, ref name, ref sf, ref price);
                string bh = "";
                GetUserAdornment(Convert.ToString(result[0].frescoID), ref type, ref name, ref bh, ref price);
                string dd = "";
                GetUserAdornment(Convert.ToString(result[0].pendantLampID), ref type, ref name, ref dd, ref price);

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
        private void GetUserAdornment(String id, ref short type, ref string name, ref string path, ref int price)
        {
            if (id.Equals("")) return;

            Guid key = new Guid(id);
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.Adornment
                    where item.ID.Equals(key)
                    select item;
            var result = t.ToList();
            if (result.Count > 0)
            {
                name = result[0].name;
                path = result[0].imagePath;
                price = Convert.ToInt32(result[0].price);
                type = Convert.ToInt16(result[0].type);
            }
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

                //result[0].dCreate = DateTime.Now;
            }
            else
            {
                var newEnity = new House
                {
                    userName = userName,
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



        private void getUserAllAdornments(string userName)
        {
            ArrayList sps_gangqin = new ArrayList();
            ArrayList paths_gangqin =new ArrayList();
            ArrayList jgs_gangqin = new ArrayList();
            ArrayList ids_gangqin = new ArrayList();

            ArrayList sps_guizi = new ArrayList();
            ArrayList paths_guizi = new ArrayList();
            ArrayList jgs_guizi = new ArrayList();
            ArrayList ids_guizi = new ArrayList();

            ArrayList sps_shafa = new ArrayList();
            ArrayList paths_shafa = new ArrayList();
            ArrayList jgs_shafa = new ArrayList();
            ArrayList ids_shafa = new ArrayList();

            ArrayList sps_bihua = new ArrayList();
            ArrayList paths_bihua = new ArrayList();
            ArrayList jgs_bihua = new ArrayList();
            ArrayList ids_bihua = new ArrayList();

            ArrayList sps_deng = new ArrayList();
            ArrayList paths_deng = new ArrayList();
            ArrayList jgs_deng = new ArrayList();
            ArrayList ids_deng = new ArrayList();

            #region 已购买的商品
            PianoDataClassesDataContext piano = new PianoDataClassesDataContext();
            var t = from item in piano.UsersAdornment
                    where item.userName.Equals(userName)
                    select item;
            var result = t.ToList();

            ids.Clear();
            for(int i = 0; i < result.Count(); i++)
            {
                short type = 0;
                string name = "", path = "";
                int price = 0;
                
                ids.Add(Convert.ToString(result[i].adornmentID));

                GetUserAdornment(Convert.ToString(result[i].adornmentID), ref type, ref name, ref path, ref price);
                switch (type)
                {
                    case 1:
                        sps_gangqin.Add(name);
                        paths_gangqin.Add(path);
                        jgs_gangqin.Add(0);
                        ids_gangqin.Add(Convert.ToString(result[i].adornmentID));
                        break;
                    case 2:
                        sps_guizi.Add(name);
                        paths_guizi.Add(path);
                        jgs_guizi.Add(0);
                        ids_guizi.Add(Convert.ToString(result[i].adornmentID));
                        break;
                    case 3:
                        sps_shafa.Add(name);
                        paths_shafa.Add(path);
                        jgs_shafa.Add(0);
                        ids_shafa.Add(Convert.ToString(result[i].adornmentID));
                        break;
                    case 4:
                        sps_bihua.Add(name);
                        paths_bihua.Add(path);
                        jgs_bihua.Add(0);
                        ids_bihua.Add(Convert.ToString(result[i].adornmentID));
                        break;
                    case 5:
                        sps_deng.Add(name);
                        paths_deng.Add(path);
                        jgs_deng.Add(0);
                        ids_deng.Add(Convert.ToString(result[i].adornmentID));
                        break;
                }
            }
            #endregion

           #region 未购买商品
            var t1 = from item in piano.Adornment
                    select item;
            var result1 = t1.ToList();
            for (int i = 0; i < result1.Count(); i++)
            {
                short type = Convert.ToInt16(result1[i].type) ;
                string name = result1[i].name;
                string path = result1[i].imagePath;
                int price = Convert.ToInt32(result1[i].price);
                string id = Convert.ToString(result1[i].ID);

                if (isBuy(Convert.ToString(result1[i].ID))) continue;


                switch (type)
                {
                    case 1:
                        sps_gangqin.Add(name);
                        paths_gangqin.Add(path);
                        jgs_gangqin.Add(price);
                        ids_gangqin.Add(id);
                        break;
                    case 2:
                        sps_guizi.Add(name);
                        paths_guizi.Add(path);
                        jgs_guizi.Add(price);
                        ids_guizi.Add(id);
                        break;
                    case 3:
                        sps_shafa.Add(name);
                        paths_shafa.Add(path);
                        jgs_shafa.Add(price);
                        ids_shafa.Add(id);
                        break;
                    case 4:
                        sps_bihua.Add(name);
                        paths_bihua.Add(path);
                        jgs_bihua.Add(price);
                        ids_bihua.Add(id);
                        break;
                    case 5:
                        sps_deng.Add(name);
                        paths_deng.Add(path);
                        jgs_deng.Add(price);
                        ids_deng.Add(id);
                        break;
                }
            }
            #endregion

            hidenGangqinCount.Value = Convert.ToString(sps_gangqin.Count);
            hidenShafaCount.Value = Convert.ToString(sps_shafa.Count);
            hidenGuiziCount.Value = Convert.ToString(sps_guizi.Count);
            hidenBihuaCount.Value = Convert.ToString(sps_bihua.Count);
            hidenDengCount.Value = Convert.ToString(sps_deng.Count);


            StringBuilder sbGangqin = new StringBuilder();
            StringBuilder sbShafa = new StringBuilder();
            StringBuilder sbGuizi = new StringBuilder();
            StringBuilder sbBihua = new StringBuilder();
            StringBuilder sbDeng = new StringBuilder();


            for(int i = 0; i < sps_gangqin.Count; i++)
            {
                string item = sps_gangqin[i].ToString() + "," +
                    paths_gangqin[i].ToString() + "," + jgs_gangqin[i].ToString() + "," + ids_gangqin[i].ToString();

                sbGangqin.Append(item);
                sbGangqin.Append("|");
            }


            for (int i = 0; i < sps_shafa.Count; i++)
            {
                string item = sps_shafa[i].ToString() + "," +
                    paths_shafa[i].ToString() + "," + jgs_shafa[i].ToString() + "," + ids_shafa[i].ToString();

                sbShafa.Append(item);
                sbShafa.Append("|");
            }

            for (int i = 0; i < sps_guizi.Count; i++)
            {
                string item = sps_guizi[i].ToString() + "," +
                    paths_guizi[i].ToString() + "," + jgs_guizi[i].ToString() + "," + ids_guizi[i].ToString();

                sbGuizi.Append(item);
                sbGuizi.Append("|");
            }

            for (int i = 0; i < sps_bihua.Count; i++)
            {
                string item = sps_bihua[i].ToString() + "," +
                    paths_bihua[i].ToString() + "," + jgs_bihua[i].ToString() + "," + ids_bihua[i].ToString();

                sbBihua.Append(item);
                sbBihua.Append("|");
            }

            for (int i = 0; i < sps_deng.Count; i++)
            {
                string item = sps_deng[i].ToString() + "," +
                    paths_deng[i].ToString() + "," + jgs_deng[i].ToString() + "," + ids_deng[i].ToString();

                sbDeng.Append(item);
                sbDeng.Append("|");
            }


            hidenGangqin.Value = sbGangqin.ToString();
            hidenShafa.Value = sbShafa.ToString();
            hidenGuizi.Value = sbGuizi.ToString();
            hidenBihua.Value = sbBihua.ToString();
            hidenDeng.Value = sbDeng.ToString();

        }

        /// <summary>
        /// 是否已经购买过
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        private bool isBuy(string id)
        {
            bool ret = false;

            foreach (string v in ids)
            {
                if(v.Equals(id)) 
                {
                    ret = true;
                    break;
                }
            }

            return ret;
        }

        #region 添加装饰品代码 
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
        #endregion
    }
}
