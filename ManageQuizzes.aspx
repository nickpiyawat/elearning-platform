<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageQuizzes.aspx.cs" Inherits="ELearningPlatform.ManageQuizzes" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>จัดการข้อสอบ - Instructor Dashboard</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f5f7fa; margin: 0; padding: 0; display: flex; flex-direction: column; min-height: 100vh; }
        .navbar { background: #2c3e50; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; color: white; }
        .nav-brand { font-size: 18px; font-weight: 700; color: white; text-decoration: none; }
        .nav-links a { color: #adb5bd; text-decoration: none; margin-left: 20px; font-weight: 600; }
        .nav-links a:hover { color: white; }
        
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; width: 100%; }
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 30px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #495057; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ced4da; border-radius: 6px; font-size: 14px; }
        
        .row { display: flex; gap: 15px; }
        .col { flex: 1; }

        .btn { padding: 10px 20px; background: #6f42c1; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn:hover { background: #59359a; }
        .btn-secondary { background: #6c757d; margin-bottom: 20px; }
        .btn-secondary:hover { background: #5c636a; }
        
        .question-item { background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px solid #dee2e6; margin-bottom: 15px; }
        .question-title { font-weight: bold; color: #2c3e50; margin-bottom: 10px; font-size: 16px; }
        .correct-answer { color: #198754; font-weight: bold; }
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
            <asp:Literal ID="litBackLink" runat="server"></asp:Literal>
            
            <!-- การตั้งค่าเกณฑ์สอบผ่านประจำบท -->
            <div class="card" style="border-left: 5px solid #ffc107;">
                <h3 style="margin-top:0; color:#2c3e50;">⚙️ ตั้งค่าเกณฑ์การสอบผ่าน</h3>
                <div class="row">
                    <div class="col form-group">
                        <label>กำหนดเกณฑ์สอบผ่าน (%)</label>
                        <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control" TextMode="Number" Text="60" required="true"></asp:TextBox>
                    </div>
                    <div class="col form-group" style="display: flex; align-items: flex-end;">
                        <asp:Button ID="btnUpdatePassing" runat="server" Text="💾 บันทึกเกณฑ์ผ่าน" CssClass="btn" style="background:#ffc107; color:#000;" OnClick="btnUpdatePassing_Click" />
                    </div>
                </div>
                <asp:Label ID="lblPassingMsg" runat="server" style="font-weight:bold; font-size:14px;"></asp:Label>
            </div>

            <div class="card">
                <h2 style="margin-top:0; color:#2c3e50;">📝 จัดการข้อสอบ: <asp:Literal ID="litLessonTitle" runat="server"></asp:Literal></h2>
                <hr style="border:0; border-top:1px solid #eee; margin:20px 0;" />
                
                <h3 style="color:#2c3e50; font-size:16px;">➕ เพิ่มคำถามใหม่</h3>
                <div class="form-group">
                    <label>โจทย์คำถาม (รวมถึงตัวเลือกในโจทย์ เช่น A, B, C, D)</label>
                    <asp:TextBox ID="txtQuestionText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" required="true"></asp:TextBox>
                </div>

                <div class="row">
                    <div class="col form-group">
                        <label>เฉลยที่ถูกต้อง</label>
                        <asp:DropDownList ID="ddlCorrectOption" runat="server" CssClass="form-control">
                            <asp:ListItem Value="A">ข้อ A</asp:ListItem>
                            <asp:ListItem Value="B">ข้อ B</asp:ListItem>
                            <asp:ListItem Value="C">ข้อ C</asp:ListItem>
                            <asp:ListItem Value="D">ข้อ D</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col form-group">
                        <label>คะแนน (Points)</label>
                        <asp:TextBox ID="txtPoints" runat="server" CssClass="form-control" TextMode="Number" Text="1" min="1" required="true"></asp:TextBox>
                    </div>
                </div>

                <asp:Button ID="btnAddQuestion" runat="server" Text="บันทึกข้อสอบข้อนี้" CssClass="btn" OnClick="btnAddQuestion_Click" />
                <asp:Label ID="lblMessage" runat="server" style="display:block; margin-top:15px; font-weight:bold;"></asp:Label>
            </div>

            <div class="card">
                <h3 style="margin-top:0; color:#2c3e50;">📋 รายการคำถามในบทนี้</h3>
                <asp:Repeater ID="rptQuestions" runat="server">
                    <ItemTemplate>
                        <div class="question-item">
                            <div class="question-title">
                                ข้อที่ <%# Container.ItemIndex + 1 %>: <%# Eval("question_text") %> 
                                <span style="float:right; color:#0d6efd; font-size:14px;">(<%# Eval("points") %> คะแนน)</span>
                            </div>
                            <div style="margin-top: 10px;">
                                เฉลยที่ถูกต้อง: <span class="correct-answer">ข้อ <%# Eval("correct_option") %></span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoQuestion" runat="server" Visible="false" style="display:block; text-align:center; padding:20px; color:#6c757d;">ยังไม่มีคำถามในแบบทดสอบนี้</asp:Label>
            </div>
        </div>
    </form>
</body>
</html>