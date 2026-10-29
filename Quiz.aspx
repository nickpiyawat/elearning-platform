<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="ELearningPlatform.Quiz" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ทำแบบทดสอบ - E-Learning Platform</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; margin: 0; padding: 0; }
        .navbar { background: white; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .nav-brand { font-size: 18px; font-weight: 700; color: #0d6efd; text-decoration: none; }
        .nav-links { display: flex; align-items: center; gap: 15px; }
        .nav-link { text-decoration: none; color: #495057; font-weight: 600; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        
        .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
        .quiz-header { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 25px; border-left: 6px solid #0d6efd; }
        .quiz-title { font-size: 22px; color: #2c3e50; margin: 0 0 10px 0; font-weight: bold; }
        .quiz-info { font-size: 14px; color: #6c757d; display: flex; justify-content: space-between; margin-top: 10px; }
        
        .question-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 20px; border: 1px solid #e9ecef; }
        .question-text { font-size: 16px; font-weight: 600; color: #2c3e50; margin-bottom: 15px; line-height: 1.5; }
        .question-badge { background: #e7f1ff; color: #0d6efd; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; float: right; }
        
        .options-list label {
            display: block;
            padding: 12px 15px;
            margin-bottom: 10px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            color: #495057;
            transition: all 0.2s;
        }
        .options-list label:hover { background: #e9ecef; border-color: #adb5bd; }
        .options-list input[type="radio"] { margin-right: 10px; accent-color: #0d6efd; }

        .btn-submit { display: block; width: 100%; background: #198754; color: white; border: none; padding: 15px; font-size: 16px; font-weight: bold; border-radius: 8px; cursor: pointer; transition: background 0.2s; margin-top: 30px; }
        .btn-submit:hover { background: #157347; }

        .result-box { background: white; padding: 40px; border-radius: 12px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .result-pass { border-top: 6px solid #198754; }
        .result-fail { border-top: 6px solid #dc3545; }
        .btn-back { display: inline-block; background: #0d6efd; color: white; text-decoration: none; padding: 12px 25px; border-radius: 6px; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <a href="MyCourses.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <span class="nav-link"><asp:Literal ID="litNavUser" runat="server"></asp:Literal></span>
                <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" OnClick="btnLogout_Click" CssClass="nav-link" style="background:none; border:1px solid #ced4da; cursor:pointer;" />
            </div>
        </nav>

        <div class="container">
            <asp:Panel ID="pnlQuiz" runat="server">
                <div class="quiz-header">
                    <h2 class="quiz-title"><asp:Literal ID="litQuizTitle" runat="server">แบบทดสอบประจำบทเรียน</asp:Literal></h2>
                    <div class="quiz-info">
                        <span>🎯 เกณฑ์ผ่าน: <b><asp:Literal ID="litPassingScore" runat="server">60</asp:Literal>%</b></span>
                        <span style="color: #d63384;"><asp:Literal ID="litRemainingAttempts" runat="server"></asp:Literal></span>
                    </div>
                </div>

                <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                    <ItemTemplate>
                        <div class="question-card">
                            <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("question_id") %>' />
                            <span class="question-badge"><%# Eval("points") %> คะแนน</span>
                            <div class="question-text">
                                ข้อที่ <%# Container.ItemIndex + 1 %>: <%# Eval("question_text") %>
                            </div>
                            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="options-list" RepeatLayout="Flow"></asp:RadioButtonList>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Button ID="btnSubmit" runat="server" Text="📤 ส่งคำตอบและตรวจข้อสอบ" CssClass="btn-submit" OnClick="btnSubmit_Click" />
            </asp:Panel>

            <asp:Panel ID="pnlResult" runat="server" Visible="false">
                <div id="divResultBox" runat="server" class="result-box">
                    <h2 style="margin-top:0;">ผลการทดสอบของคุณ</h2>
                    <p style="font-size: 24px; font-weight: bold; margin: 20px 0;"><asp:Literal ID="litScore" runat="server"></asp:Literal></p>
                    <p style="font-size: 18px; margin-bottom: 25px;"><asp:Literal ID="litStatus" runat="server"></asp:Literal></p>
                    <a id="btnBackToLesson" runat="server" class="btn-back">กลับไปหน้าบทเรียน</a>
                    <asp:Button ID="btnResetAttempts" runat="server" Text="🔄 ทบทวนบทเรียนและขอสอบใหม่" CssClass="btn-submit" style="background:#ffc107; color:#000; margin-top:20px; width:auto; display:inline-block; padding:12px 25px;" Visible="false" OnClick="btnResetAttempts_Click" />
                </div>
            </asp:Panel>
        </div>
    </form>
</body>
</html>