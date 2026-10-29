<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageLessons.aspx.cs" Inherits="ELearningPlatform.ManageLessons" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>จัดการบทเรียน - Instructor Dashboard</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f5f7fa; margin: 0; padding: 0; display: flex; flex-direction: column; min-height: 100vh; }
        .navbar { background: #2c3e50; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; color: white; }
        .nav-brand { font-size: 18px; font-weight: 700; color: white; text-decoration: none; }
        .nav-links a { color: #adb5bd; text-decoration: none; margin-left: 20px; font-weight: 600; }
        .nav-links a:hover { color: white; }
        
        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; width: 100%; }
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 30px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #495057; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ced4da; border-radius: 6px; font-size: 14px; }
        
        .btn { padding: 10px 20px; background: #0d6efd; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn:hover { background: #0b5ed7; }
        .btn-secondary { background: #6c757d; margin-bottom: 20px; }
        .btn-secondary:hover { background: #5c636a; }
        .btn-quiz { background: #6f42c1; font-size: 12px; padding: 6px 12px; }
        .btn-quiz:hover { background: #59359a; }
        
        .lesson-list { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .lesson-list th, .lesson-list td { text-align: left; padding: 12px; border-bottom: 1px solid #dee2e6; }
        .lesson-list th { background: #f8f9fa; color: #495057; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="InstructorIndex.aspx" class="nav-brand">👨‍🏫 Instructor Dashboard</a>
            <div class="nav-links">
                <span>สวัสดี, <%= Session["UserName"] %></span>
                <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" OnClick="btnLogout_Click" style="background:none; border:none; color:#adb5bd; font-weight:bold; cursor:pointer; margin-left:20px;" />
            </div>
        </nav>

        <div class="container">
            <a href="ManageCourses.aspx" class="btn btn-secondary">⬅️ กลับไปหน้าจัดการคอร์ส</a>
            
            <div class="card">
                <h2 style="margin-top:0; color:#2c3e50;">📚 จัดการบทเรียน: <asp:Literal ID="litCourseTitle" runat="server"></asp:Literal></h2>
                <hr style="border:0; border-top:1px solid #eee; margin:20px 0;" />
                
                <h3 style="color:#2c3e50; font-size:16px;">➕ เพิ่มบทเรียนใหม่</h3>
                <div class="form-group">
                    <label>ลำดับบทเรียน (เช่น 1, 2, 3)</label>
                    <asp:TextBox ID="txtLessonNo" runat="server" CssClass="form-control" TextMode="Number" required="true" style="width: 150px;"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>ชื่อบทเรียน</label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" required="true"></asp:TextBox>
                </div>
                <asp:Button ID="btnSaveLesson" runat="server" Text="บันทึกบทเรียน" CssClass="btn" OnClick="btnSaveLesson_Click" />
                <asp:Label ID="lblMessage" runat="server" style="display:block; margin-top:15px; font-weight:bold;"></asp:Label>
            </div>

            <div class="card">
                <h3 style="margin-top:0; color:#2c3e50;">📑 รายการบทเรียนทั้งหมดในคอร์สนี้</h3>
                <table class="lesson-list">
                    <thead>
                        <tr>
                            <th style="width: 80px;">บทที่</th>
                            <th>ชื่อบทเรียน</th>
                            <th style="width: 200px; text-align: center;">จัดการแบบทดสอบ</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptLessons" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong>บทที่ <%# Eval("lesson_no") %></strong></td>
                                    <td><%# Eval("title") %></td>
                                    <td style="text-align: center;">
                                        <a href='ManageQuizzes.aspx?lesson_id=<%# Eval("lesson_id") %>&course_id=<%= Request.QueryString["course_id"] %>' class="btn btn-quiz">📝 จัดการข้อสอบประจำบท</a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
                <asp:Label ID="lblNoLesson" runat="server" Visible="false" style="display:block; text-align:center; padding:20px; color:#6c757d;">ยังไม่มีบทเรียนในคอร์สนี้</asp:Label>
            </div>
        </div>
    </form>
</body>
</html>