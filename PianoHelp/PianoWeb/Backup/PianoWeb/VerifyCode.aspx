<%@ Import Namespace="System.Drawing.Drawing2D" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Page language="c#" %>
<script language="c#" runat="server">
Random rd = new Random();
void Page_Load(Object src,EventArgs e)
{
	Response.AppendHeader("Cache-Control","no-cache");
	Response.AppendHeader("Pragma","no-cache");
	Response.AppendHeader("Content-Type","image/jpeg");
	Response.Clear();

	string[] mCode = new string[4]{GetRandomChar(1),GetRandomChar(2),GetRandomChar(3),GetRandomChar(4)};
	PointF[] ps = new PointF[4]{new Point(5,2) , new Point(15,2) , new Point(25,2) , new Point(35,2)};
	Size offsetP = new Size(1,1);
	String sCode = String.Join("",mCode);
	Font ft = new Font("Tahoma",12,FontStyle.Regular,GraphicsUnit.Pixel);
	Session["VerifyCode"] = sCode;
	
	
	
	Pen blackPen = new Pen(Color.FromArgb(151,151,188),1);

	using(Bitmap image = new Bitmap(55,20))
	{
		using(Graphics g = Graphics.FromImage(image))
		{
			g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAlias;	
			g.Clear(Color.FromArgb(214,242,253));
			g.DrawRectangle(blackPen,0,0,54,19);
			g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAlias;		
			for(int i = 0; i < 4; i++)
			{
				g.DrawString(mCode[i].ToString(),ft,Brushes.Black,ps[i] + offsetP);
			}	
		}
		image.Save(Response.OutputStream,ImageFormat.Jpeg);
	}
	Response.End();	
}
string GetRandomChar(int i)
{
	return rd.Next(0,10).ToString();
}	
</script>