<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="ELearningPlatform.MyCourses" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>คอร์สเรียนของฉัน - E-Learning Platform</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; margin: 0; padding: 0; }
        .navbar { background: white; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .nav-brand { font-size: 18px; font-weight: 700; color: #0d6efd; text-decoration: none; }
        .nav-links a { text-decoration: none; color: #495057; font-weight: 600; margin-left: 20px; }
        
        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
        .page-title { color: #2c3e50; margin-bottom: 30px; font-size: 28px; }
        
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 25px; }
        .course-card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); transition: transform 0.2s; display: flex; flex-direction: column; }
        .course-card:hover { transform: translateY(-5px); }
        .course-info { padding: 20px; flex: 1; display: flex; flex-direction: column; }
        .course-title { font-size: 18px; font-weight: bold; color: #2c3e50; margin: 0 0 10px 0; }
        .progress-bar-bg { background: #e9ecef; border-radius: 10px; height: 8px; width: 100%; margin: 15px 0 5px; overflow: hidden; }
        .progress-bar-fill { background: #198754; height: 100%; }
        .progress-text { font-size: 13px; color: #6c757d; text-align: right; }
        
        .btn-continue { display: block; text-align: center; background: #0d6efd; color: white; text-decoration: none; padding: 12px; font-weight: bold; border-radius: 6px; margin-top: auto; }
        .btn-continue:hover { background: #0b5ed7; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <a href="Index.aspx">หน้าแรก</a>
                <a href="Courses.aspx">หลักสูตรทั้งหมด</a>
                <span style="color: #495057; font-weight: bold; margin-left: 20px;">สวัสดี, <%= Session["UserName"] %></span>
            </div>
        </nav>

        <div class="container">
            <h1 class="page-title">📚 คอร์สเรียนของฉัน</h1>
            
            <div class="grid">
                <asp:Repeater ID="rptMyCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card">
                            <div class="course-info">
                                <h3 class="course-title"><%# Eval("title") %></h3>
                                <div class="progress-bar-bg">
                                    <div class="progress-bar-fill" style='width: <%# Eval("progress_percent") %>%'></div>
                                </div>
                                <div class="progress-text"><%# Eval("progress_percent", "{0:0}") %>% เรียนจบ</div>
                                <a href='Lessons.aspx?course_id=<%# Eval("course_id") %>' class="btn-continue" style="margin-top: 20px;">
                                    <%# Convert.ToDecimal(Eval("progress_percent")) == 100 ? "ทบทวนบทเรียน" : "เรียนต่อ" %>
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            
            <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" style="text-align: center; padding: 50px; background: white; border-radius: 10px;">
                <h3 style="color: #6c757d;">คุณยังไม่มีคอร์สเรียน</h3>
                <a href="Courses.aspx" class="btn-continue" style="display: inline-block; padding: 10px 20px; margin-top: 15px;">ดูหลักสูตรทั้งหมด</a>
            </asp:Panel>
        </div>
    </form>
</body>
</html>