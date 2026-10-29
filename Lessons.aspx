<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Lessons.aspx.cs" Inherits="ELearningPlatform.Lessons" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>บทเรียน - E-Learning Platform</title>
    <style>
        * { box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); 
            margin: 0; padding: 0; min-height: 100vh; display: flex; flex-direction: column;
        }
        .navbar {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 15px 40px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }
        .nav-brand { font-size: 18px; font-weight: 700; color: #2c3e50; text-decoration: none; }
        .nav-links { display: flex; gap: 15px; align-items: center; }
        .nav-link { text-decoration: none; color: #495057; font-weight: 600; font-size: 14px; padding: 8px 16px; border-radius: 6px; transition: all 0.2s ease; }
        .nav-link:hover { background-color: #e9ecef; color: #0d6efd; }
        
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; flex: 1; width: 100%; }
        .course-header { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .course-title { font-size: 24px; color: #2c3e50; margin: 0 0 10px 0; }
        
        .lesson-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 20px; border-left: 5px solid #0d6efd; transition: transform 0.2s; }
        .lesson-card:hover { transform: translateX(5px); }
        .lesson-card h3 { margin: 0 0 15px 0; color: #2c3e50; font-size: 18px; }
        .lesson-content { color: #495057; font-size: 15px; line-height: 1.6; }
        
        .btn-quiz { display: inline-block; background: #198754; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; margin-top: 15px; transition: background 0.2s; font-size: 14px; }
        .btn-quiz:hover { background: #157347; color: white; }
        
        .btn-passed { display: inline-block; background: #e9ecef; color: #198754; padding: 10px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; margin-top: 15px; font-size: 14px; border: 1px solid #badbcc; cursor: default; }
        .btn-cert { display: inline-block; background: #0d6efd; color: white; padding: 8px 16px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 14px; transition: background 0.2s; }
        .btn-cert:hover { background: #0b5ed7; color: white; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <span style="font-size: 14px; font-weight: 600; color: #495057;">
                    <asp:Literal ID="litNavUser" runat="server"></asp:Literal>
                </span>
                <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" CssClass="nav-link" OnClick="btnLogout_Click" style="border: 1px solid #dee2e6; background:none; cursor:pointer;" />
            </div>
        </nav>

        <div class="container">
            <asp:Panel ID="pnlContent" runat="server">
                <div style="margin-bottom: 15px;">
                    <a href="Courses.aspx" style="text-decoration: none; color: #495057; font-weight: bold; font-size: 14px; background: white; padding: 8px 15px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: inline-block; transition: all 0.2s;" onmouseover="this.style.color='#0d6efd'" onmouseout="this.style.color='#495057'">
                        ⬅️ กลับไปหน้ารายการคอร์ส
                    </a>
                </div>
                <div class="course-header">
                    <h1 class="course-title"><asp:Literal ID="litCourseTitle" runat="server"></asp:Literal></h1>
                    <p style="color: #6c757d; margin: 0;"><asp:Literal ID="litCourseDesc" runat="server"></asp:Literal></p>
                </div>
                
                <!-- ส่วนความก้าวหน้า พร้อมปุ่มรับใบประกาศฯ ด้านบน -->
                <div style="margin-bottom: 30px; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 14px; font-weight: 600; color: #495057; margin-bottom: 10px;">
                        <span>📈 ความก้าวหน้าการเรียน (<span id="lblProgressText" runat="server" style="color: #198754;">0%</span>)</span>
                        <div>
                            <asp:Literal ID="litCertButton" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div style="background: #e9ecef; border-radius: 10px; overflow: hidden; height: 12px; box-shadow: inset 0 1px 3px rgba(0,0,0,.1);">
                        <div id="divProgressBar" runat="server" style="background: #198754; height: 100%; width: 0%; transition: width 0.5s ease; border-radius: 10px;"></div>
                    </div>
                </div>

                <asp:Repeater ID="rptLessons" runat="server">
                    <ItemTemplate>
                        <div class="lesson-card">
                            <h3>บทที่ <%# Eval("lesson_no") %>: <%# Eval("title") %></h3>
                            <div class="lesson-content">
                                เนื้อหาของบทเรียนนี้กำลังอยู่ในระหว่างการจัดทำ...
                            </div>
                            <!-- ตรวจสอบว่าถ้าสอบผ่านแล้วให้แสดงปุ่มผ่าน ถ้ายังให้แสดงปุ่มทำแบบทดสอบ -->
                            <%# Convert.ToBoolean(Eval("IsPassed")) ? 
                                "<span class='btn-passed'>✅ สอบผ่านบทเรียนนี้แล้ว</span>" : 
                                "<a href='Quiz.aspx?course_id=" + Request.QueryString["course_id"] + "&lesson_id=" + Eval("lesson_id") + "' class='btn-quiz'>📝 ทำแบบทดสอบท้ายบท</a>" 
                            %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false">
                <div style="text-align: center; background: white; padding: 50px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
                    <h2 style="color: #dc3545; margin-top: 0;">ไม่มีสิทธิ์เข้าถึง 🚫</h2>
                    <p style="color: #6c757d; font-size: 16px; margin-bottom: 25px;">คุณยังไม่ได้สมัครเรียนคอร์สนี้ หรือการชำระเงินยังไม่เสร็จสมบูรณ์</p>
                    <a href="Courses.aspx" style="background: #0d6efd; color: white; padding: 12px 25px; text-decoration: none; border-radius: 6px; font-weight: bold;">กลับไปหน้ารวมคอร์ส</a>
                </div>
            </asp:Panel>
        </div>
    </form>
</body>
</html>