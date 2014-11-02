<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Userdata.aspx.cs" Inherits="PianoWeb2.Userdata" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:Label ID="Label1" runat="server" Height="23px" Text="User_data Page" 
            Width="813px"></asp:Label>
    
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
        DataKeyNames="userName" DataSourceID="SqlDataSource1" 
        onselectedindexchanged="GridView1_SelectedIndexChanged">
        <Columns>
            <asp:BoundField DataField="userName" HeaderText="userName" ReadOnly="True" 
                SortExpression="userName" />
            <asp:BoundField DataField="gender" HeaderText="gender" 
                SortExpression="gender" />
            <asp:BoundField DataField="address" HeaderText="address" 
                SortExpression="address" />
            <asp:BoundField DataField="birthday" HeaderText="birthday" 
                SortExpression="birthday" />
            <asp:BoundField DataField="constellation" HeaderText="constellation" 
                SortExpression="constellation" />
            <asp:BoundField DataField="scroe" HeaderText="scroe" SortExpression="scroe" />
            <asp:BoundField DataField="memo" HeaderText="memo" 
                SortExpression="memo" />
            <asp:BoundField DataField="pianoLevel" HeaderText="pianoLevel" 
                SortExpression="pianoLevel" />
            <asp:BoundField DataField="sinaWeiBo" HeaderText="sinaWeiBo" 
                SortExpression="sinaWeiBo" />
            <asp:BoundField DataField="qq" HeaderText="qq" SortExpression="qq" />
            <asp:BoundField DataField="tencentWeiBo" HeaderText="tencentWeiBo" 
                SortExpression="tencentWeiBo" />
            <asp:BoundField DataField="dModified" HeaderText="dModified" 
                SortExpression="dModified" />
            <asp:BoundField DataField="dCreate" HeaderText="dCreate" 
                SortExpression="dCreate" />
            <asp:BoundField DataField="email" HeaderText="email" SortExpression="email" />
        </Columns>
    </asp:GridView>
    
    </div>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:pianoWebConnectionString %>" 
        
        SelectCommand="SELECT [userName], [gender], [address], [birthday], [constellation], [scroe], [memo], [pianoLevel], [sinaWeiBo], [qq], [tencentWeiBo], [dModified], [dCreate], [email] FROM [Users]" 
        onselecting="SqlDataSource1_Selecting">
    </asp:SqlDataSource>
    </form>
</body>
</html>
