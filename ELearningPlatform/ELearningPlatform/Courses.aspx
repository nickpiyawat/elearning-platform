<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="ELearningPlatform.Courses" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>คอร์สเรียนทั้งหมด - E-Learning Platform</title>
    <style>
        * { box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); 
            margin: 0; 
            padding: 0; 
            min-height: 100vh; 
            display: flex;
            flex-direction: column;
        }
        .navbar {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .nav-brand { font-size: 18px; font-weight: 700; color: #2c3e50; text-decoration: none; }
        .nav-links { display: flex; gap: 15px; align-items: center; }
        .nav-link { text-decoration: none; color: #495057; font-weight: 600; font-size: 14px; padding: 8px 16px; border-radius: 6px; transition: all 0.2s ease; }
        .nav-link:hover { background-color: #e9ecef; color: #0d6efd; }
        .nav-link.btn-primary { background-color: #0d6efd; color: white; }
        .nav-link.btn-success { background-color: #198754; color: white; }

        .container { 
            max-width: 1400px; 
            margin: 30px auto; 
            padding: 0 20px; 
            flex: 1;
            width: 100%;
        }
        
        .catalog-header {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 20px 25px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .catalog-header h2 { margin: 0; color: #2c3e50; font-size: 20px; }

        .search-bar-container {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
        }
        .search-input {
            flex: 1;
            padding: 10px 15px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
        }
        .search-input:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13,110,253,0.15); }
        .search-btn {
            padding: 10px 20px;
            background-color: #0d6efd;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .search-btn:hover { background-color: #0b5ed7; }

        /* Grid Layout: แถวละ 5 คอลัมน์ */
        .grid { 
            display: grid; 
            grid-template-columns: repeat(5, 1fr); 
            gap: 18px; 
            margin-bottom: 40px;
        }
        @media (max-width: 1200px) { .grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 768px) { .grid { grid-template-columns: repeat(1, 1fr); } }

        .card { 
            background: rgba(255, 255, 255, 0.95); 
            backdrop-filter: blur(10px);
            padding: 16px; 
            border-radius: 10px; 
            box-shadow: 0 6px 15px rgba(0,0,0,0.05); 
            display: flex; 
            flex-direction: column; 
            justify-content: space-between; 
            transition: transform 0.2s, box-shadow 0.2s;
            border: 1px solid rgba(255, 255, 255, 0.4);
        }
        .card:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); }
        .card h3 { margin-top: 0; color: #0d6efd; font-size: 15px; margin-bottom: 8px; line-height: 1.3; }
        .card p { color: #6c757d; font-size: 12px; line-height: 1.4; flex-grow: 1; margin-bottom: 12px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .meta { font-size: 11px; color: #adb5bd; margin-bottom: 10px; font-weight: 500; }
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #f1f3f5;
            padding-top: 10px;
        }
        .price { font-weight: 700; color: #198754; font-size: 14px; }
        .btn { 
            display: inline-block; 
            text-align: center; 
            padding: 6px 10px; 
            background-color: #0d6efd; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            text-decoration: none; 
            font-size: 12px; 
            font-weight: 600; 
            transition: background 0.2s; 
        }
        .btn:hover { background-color: #0b5ed7; }
        .no-result { grid-column: span 5; text-align: center; color: #6c757d; padding: 40px; font-size: 15px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <div id="pnlGuestNav" runat="server" style="display: flex; gap: 10px;">
                    <a href="Login.aspx" class="nav-link btn-success">เข้าสู่ระบบ</a>
                    <a href="Register.aspx" class="nav-link btn-primary">สมัครสมาชิก</a>
                </div>
                <div id="pnlUserNav" runat="server" visible="false" style="display: flex; gap: 15px; align-items: center;">
                    <a href="MyCourses.aspx" class="nav-link" style="text-decoration: none; color: #495057; font-weight: 600;">
                        📚 คอร์สเรียนของฉัน
                    </a>
                    <span style="font-size: 14px; font-weight: 600; color: #495057;"><asp:Literal ID="litNavUser" runat="server"></asp:Literal></span>
                    <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" CssClass="nav-link" OnClick="btnLogout_Click" style="border: 1px solid #dee2e6; background:none; cursor:pointer;" />
                </div>
            </div>
        </nav>

        <div class="container">
            <div class="catalog-header">
                <h2>📚 คอร์สเรียนทั้งหมด</h2>
            </div>

            <div class="search-bar-container">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="🔍 ค้นหาชื่อคอร์สเรียน..."></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="ค้นหา" CssClass="search-btn" OnClick="btnSearch_Click" />
            </div>

            <div class="grid">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class="card">
                            <div>
                                <h3><%# Eval("title") %></h3>
                                <div class="meta">👨‍🏫 <%# Eval("instructor_name") %></div>
                                <p><%# Eval("description") %></p>
                            </div>
                            <div class="card-footer">
                                <div class="price">฿<%# Convert.ToDecimal(Eval("price")).ToString("N2") %></div>
                                <a href='Enroll.aspx?course_id=<%# Eval("course_id") %>' class="btn">รายละเอียด</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Label ID="lblNoResult" runat="server" CssClass="no-result" Visible="false" Text="ไม่พบคอร์สเรียนที่คุณค้นหา"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>