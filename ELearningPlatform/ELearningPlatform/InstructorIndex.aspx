<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InstructorIndex.aspx.cs" Inherits="ELearningPlatform.InstructorIndex" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Instructor Dashboard - E-Learning Platform</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f4f6f9; margin: 0; padding: 0; }
        .navbar { background: #2c3e50; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; color: white; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .nav-brand { font-size: 20px; font-weight: 700; color: white; text-decoration: none; }
        .nav-links a { color: #adb5bd; text-decoration: none; margin-left: 20px; font-weight: 600; transition: 0.3s; }
        .nav-links a:hover { color: white; }
        .nav-links a.active { color: #0d6efd; }
        
        .container { max-width: 1200px; margin: 40px auto; padding: 0 20px; }
        .header-title { color: #2c3e50; margin-bottom: 30px; font-size: 28px; }
        
        .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #0d6efd; }
        .stat-card.green { border-left-color: #198754; }
        .stat-card.purple { border-left-color: #6f42c1; }
        .stat-title { font-size: 14px; color: #6c757d; font-weight: 600; margin-bottom: 10px; }
        .stat-value { font-size: 32px; font-weight: 700; color: #2c3e50; margin: 0; }
        
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .card-title { font-size: 18px; font-weight: 700; color: #2c3e50; margin: 0; }
        
        .table { width: 100%; border-collapse: collapse; }
        .table th, .table td { padding: 15px; text-align: left; border-bottom: 1px solid #e9ecef; }
        .table th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 14px; }
        .table td { color: #2c3e50; font-size: 15px; }
        .table tr:hover td { background: #f8f9fa; }
        
        .progress-bg { background: #e9ecef; border-radius: 10px; height: 8px; width: 100%; overflow: hidden; margin-top: 5px; }
        .progress-fill { background: #198754; height: 100%; }
        
        .btn-action { display: inline-block; padding: 8px 15px; background: #0d6efd; color: white; border-radius: 6px; text-decoration: none; font-size: 13px; font-weight: bold; }
        .btn-action:hover { background: #0b5ed7; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="InstructorIndex.aspx" class="nav-brand">👨‍🏫 Instructor Portal</a>
            <div class="nav-links">
                <a href="InstructorIndex.aspx" class="active">ภาพรวม (Dashboard)</a>
                <a href="ManageCourses.aspx">จัดการคอร์ส</a>
                <span>|</span>
                <span style="color: white; margin-left:20px;">อ. <%= Session["UserName"] %></span>
                <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" OnClick="btnLogout_Click" style="background:none; border:none; color:#adb5bd; font-weight:bold; cursor:pointer; margin-left:15px;" />
            </div>
        </nav>

        <div class="container">
            <h1 class="header-title">ภาพรวมการสอนของคุณ</h1>
            
            <div class="summary-grid">
                <div class="stat-card">
                    <div class="stat-title">คอร์สเรียนที่เปิดสอน</div>
                    <p class="stat-value"><asp:Literal ID="litTotalCourses" runat="server">0</asp:Literal></p>
                </div>
                <div class="stat-card green">
                    <div class="stat-title">จำนวนนักเรียนทั้งหมด (Enrollments)</div>
                    <p class="stat-value"><asp:Literal ID="litTotalStudents" runat="server">0</asp:Literal></p>
                </div>
                <div class="stat-card purple">
                    <div class="stat-title">คะแนนสอบเฉลี่ยรวม</div>
                    <p class="stat-value"><asp:Literal ID="litAvgScore" runat="server">0</asp:Literal>%</p>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">📊 วิเคราะห์การมีส่วนร่วมในหลักสูตร (Course Engagement Analytics)</h3>
                    <a href="ManageCourses.aspx" class="btn-action">+ จัดการคอร์สเรียน / เพิ่มคอร์ส</a>
                </div>
                
                <table class="table">
                    <thead>
                        <tr>
                            <th>ชื่อคอร์สเรียน</th>
                            <th>จำนวนผู้สมัคร</th>
                            <th>อัตราเรียนจบ (Completion Rate)</th>
                            <th>คะแนนสอบเฉลี่ย</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptAnalytics" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%# Eval("title") %></strong></td>
                                    <td><%# Eval("enrolled_count") %> คน</td>
                                    <td>
                                        <%# Eval("completion_rate", "{0:0.0}") %>%
                                        <div class="progress-bg">
                                            <div class="progress-fill" style='width: <%# Eval("completion_rate") %>%'></div>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="color: #6f42c1; font-weight:bold;"><%# Eval("avg_score", "{0:0.0}") %>%</span>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
                <asp:Label ID="lblNoData" runat="server" Visible="false" style="display:block; text-align:center; padding:30px; color:#6c757d;">ยังไม่มีข้อมูลวิเคราะห์ กรุณาสร้างคอร์สเรียนก่อน</asp:Label>
            </div>
        </div>
    </form>
</body>
</html>