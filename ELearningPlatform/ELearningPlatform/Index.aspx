<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="ELearningPlatform.Index" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>หน้าแรก - E-Learning Platform</title>
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
        /* Top Navigation Bar */
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

        /* Main Container */
        .container { 
            max-width: 1400px; 
            margin: 30px auto; 
            padding: 0 20px; 
            flex: 1;
            width: 100%;
        }

        /* Hero Banner */
        .hero-banner {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 14px;
            text-align: center;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .hero-banner h1 { color: #2c3e50; margin: 0 0 10px 0; font-size: 26px; }
        .hero-banner p { color: #6c757d; margin: 0 0 15px 0; font-size: 14px; }
        .view-all-btn {
            display: inline-block;
            padding: 8px 20px;
            background-color: #0d6efd;
            color: white;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: background 0.2s;
        }
        .view-all-btn:hover { background-color: #0b5ed7; }

        /* Section Title */
        .section-title {
            font-size: 18px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Grid Layout: แสดง 5 คอลัมน์สำหรับคอร์สแนะนำ */
        .grid { 
            display: grid; 
            grid-template-columns: repeat(5, 1fr); 
            gap: 18px; 
            margin-bottom: 40px;
        }
        @media (max-width: 1200px) { .grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 768px) { .grid { grid-template-columns: repeat(1, 1fr); } }

        /* Card Design */
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Top Navigation Bar -->
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <div id="pnlGuestNav" runat="server" style="display: flex; gap: 10px;">
                    <a href="Login.aspx" class="nav-link btn-success">เข้าสู่ระบบ</a>
                    <a href="Register.aspx" class="nav-link btn-primary">สมัครสมาชิก</a>
                </div>

                <div id="pnlUserNav" runat="server" visible="false" style="display: flex; gap: 10px; align-items: center;">
                    <span style="font-size: 14px; font-weight: 600; color: #495057;">
                        <asp:Literal ID="litNavUser" runat="server"></asp:Literal>
                    </span>
                    <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" CssClass="nav-link" OnClick="btnLogout_Click" style="border: 1px solid #dee2e6; background:none; cursor:pointer;" />
                </div>
            </div>
        </nav>

        <!-- Main Content Area -->
        <div class="container">
            <!-- Hero Banner -->
            <div class="hero-banner">
                <h1>ยินดีต้อนรับสู่แพลตฟอร์มการเรียนรู้ออนไลน์</h1>
                <p>พัฒนาทักษะของคุณกับคอร์สเรียนยอดนิยมที่มีผู้เรียนมากที่สุด</p>
                <a href="Courses.aspx" class="view-all-btn">ดูคอร์สเรียนทั้งหมดในแคตตาล็อก</a>
            </div>

            <div class="section-title">🔥 คอร์สแนะนำ (ยอดนิยมสูงสุด 5 อันดับแรก)</div>

            <!-- Top 5 Popular Courses Grid -->
            <div class="grid">
                <asp:Repeater ID="rptTopCourses" runat="server">
                    <ItemTemplate>
                        <div class="card">
                            <div>
                                <h3><%# Eval("title") %></h3>
                                <div class="meta">👨‍🏫 <%# Eval("instructor_name") %> | ผู้เรียน: <%# Eval("enrollment_count") %> คน</div>
                                <p><%# Eval("description") %></p>
                            </div>
                            <div class="card-footer">
                                <div class="price">฿<%# Convert.ToDecimal(Eval("price")).ToString("N2") %></div>
                                <a href='Enroll.aspx?course_id=<%# Eval("course_id") %>' class="btn">รายละเอียด</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </form>
</body>
</html>