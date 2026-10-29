<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Enroll.aspx.cs" Inherits="ELearningPlatform.Enroll" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>สมัครเรียนและชำระเงิน - E-Learning Platform</title>
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

        .container { max-width: 700px; margin: 40px auto; padding: 0 20px; flex: 1; width: 100%; }
        .card { 
            background: rgba(255, 255, 255, 0.95); 
            backdrop-filter: blur(10px);
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); 
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        h2 { color: #2c3e50; margin-top: 0; font-size: 24px; margin-bottom: 20px; }
        .course-info { margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
        .course-info p { color: #6c757d; line-height: 1.6; margin: 8px 0; }
        .price-tag { font-size: 22px; font-weight: 700; color: #198754; margin: 15px 0; }
        
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; color: #495057; font-weight: 600; font-size: 14px; }
        select { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 8px; font-size: 14px; background: white; outline: none; }
        select:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13,110,253,0.15); }
        
        .btn { width: 100%; padding: 14px; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 600; transition: all 0.2s; }
        .btn-enroll { background-color: #0d6efd; color: white; }
        .btn-enroll:hover { background-color: #0b5ed7; transform: translateY(-2px); }
        .btn-pay { background-color: #198754; color: white; margin-top: 15px; }
        .btn-pay:hover { background-color: #157347; transform: translateY(-2px); }
        
        .message { display: block; text-align: center; margin-top: 15px; font-weight: 600; font-size: 14px; padding: 10px; border-radius: 6px; }
        .error { color: #842029; background-color: #f8d7da; border: 1px solid #f5c2c7; }
        .success { color: #0f5132; background-color: #d1e7dd; border: 1px solid #badbcc; }
        
        .start-learning-btn { display: inline-block; width: 100%; text-align: center; padding: 14px; background-color: #0d6efd; color: white; border-radius: 8px; text-decoration: none; font-weight: 600; margin-top: 15px; transition: background 0.2s; }
        .start-learning-btn:hover { background-color: #0b5ed7; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Top Navigation Bar -->
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <a href="Courses.aspx" class="nav-link">📚 คอร์สเรียนทั้งหมด</a>
                <span style="font-size: 14px; font-weight: 600; color: #495057;">
                    <asp:Literal ID="litNavUser" runat="server"></asp:Literal>
                </span>
                <asp:Button ID="btnLogout" runat="server" Text="ออกจากระบบ" CssClass="nav-link" OnClick="btnLogout_Click" style="border: 1px solid #dee2e6; background:none; cursor:pointer;" />
            </div>
        </nav>

        <div class="container">
            <div class="card">
                <h2>📋 สมัครเรียนและชำระเงิน</h2>
                
                <div class="course-info">
                    <asp:Literal ID="litCourseDetails" runat="server"></asp:Literal>
                </div>

                <!-- ส่วนสำหรับกดสมัครเรียน (สร้าง Pending) -->
                <asp:Panel ID="pnlEnrollAction" runat="server">
                    <asp:Button ID="btnEnroll" runat="server" Text="ยืนยันการสมัครเรียนคอร์สนี้" CssClass="btn btn-enroll" OnClick="btnEnroll_Click" />
                </asp:Panel>

                <!-- ส่วนสำหรับชำระเงิน (เรียก sp_confirm_payment) -->
                <asp:Panel ID="pnlPaymentAction" runat="server" Visible="false">
                    <div class="form-group">
                        <label>เลือกช่องทางชำระเงิน</label>
                        <asp:DropDownList ID="ddlMethod" runat="server">
                            <asp:ListItem Text="PromptPay (สแกนจ่าย)" Value="PromptPay"></asp:ListItem>
                            <asp:ListItem Text="CreditCard (บัตรเครดิต/เดบิต)" Value="CreditCard"></asp:ListItem>
                            <asp:ListItem Text="BankTransfer (โอนเงินผ่านธนาคาร)" Value="BankTransfer"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Button ID="btnPay" runat="server" Text="💳 ยืนยันการชำระเงิน (จำลองจ่ายสำเร็จ)" CssClass="btn btn-pay" OnClick="btnPay_Click" />
                </asp:Panel>

                <!-- ปุ่มไปหน้าเรียน (แสดงเมื่อจ่ายเงินสำเร็จ) -->
                <asp:Panel ID="pnlSuccessAction" runat="server" Visible="false">
                    <asp:HyperLink ID="hlStartLearning" runat="server" CssClass="start-learning-btn">📚 เข้าสู่บทเรียนทันที</asp:HyperLink>
                </asp:Panel>

                <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>