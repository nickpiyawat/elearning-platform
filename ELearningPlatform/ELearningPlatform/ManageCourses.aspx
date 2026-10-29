<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs" Inherits="ELearningPlatform.ManageCourses" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>จัดการคอร์สเรียน - Instructor Dashboard</title>
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
        .btn-manage { background: #198754; font-size: 12px; padding: 6px 12px; }
        .btn-manage:hover { background: #157347; }
        
        .course-list { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .course-list th, .course-list td { text-align: left; padding: 12px; border-bottom: 1px solid #dee2e6; }
        .course-list th { background: #f8f9fa; color: #495057; }
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
            <a href="InstructorIndex.aspx" class="btn btn-secondary">⬅️ กลับไปหน้า Dashboard ภาพรวม</a>

            <div class="card">
                <h2 style="margin-top:0; color:#2c3e50;">➕ สร้างคอร์สเรียนใหม่</h2>
                <div class="form-group">
                    <label>ชื่อคอร์สเรียน</label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" required="true"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>รายละเอียดคอร์ส</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>ราคา (บาท)</label>
                    <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" TextMode="Number" required="true"></asp:TextBox>
                </div>
                <asp:Button ID="btnSave" runat="server" Text="บันทึกคอร์สเรียน" CssClass="btn" OnClick="btnSave_Click" />
                <asp:Label ID="lblMessage" runat="server" style="display:block; margin-top:15px; font-weight:bold;"></asp:Label>
            </div>

            <div class="card">
                <h2 style="margin-top:0; color:#2c3e50;">📚 คอร์สเรียนของคุณ</h2>
                <table class="course-list">
                    <thead>
                        <tr>
                            <th>รหัส</th>
                            <th>ชื่อคอร์ส</th>
                            <th>ราคา</th>
                            <th style="text-align: center;">จัดการ</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptCourses" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("course_id") %></td>
                                    <td><strong><%# Eval("title") %></strong></td>
                                    <td>฿<%# Convert.ToDecimal(Eval("price")).ToString("N2") %></td>
                                    <td style="text-align: center;">
                                        <a href='ManageLessons.aspx?course_id=<%# Eval("course_id") %>' class="btn btn-manage">📝 จัดการเนื้อหา/บทเรียน</a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
                <asp:Label ID="lblNoCourse" runat="server" Visible="false" style="display:block; text-align:center; padding:20px; color:#6c757d;">ยังไม่มีคอร์สเรียนที่คุณสร้าง</asp:Label>
            </div>
        </div>
    </form>
</body>
</html>