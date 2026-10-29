<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ELearningPlatform.Login" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>เข้าสู่ระบบ - E-Learning Platform</title>
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
        .nav-brand {
            font-size: 18px;
            font-weight: 700;
            color: #2c3e50;
            text-decoration: none;
        }
        .nav-links {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        .nav-link {
            text-decoration: none;
            color: #495057;
            font-weight: 600;
            font-size: 14px;
            padding: 8px 16px;
            border-radius: 6px;
            transition: all 0.2s ease;
        }
        .nav-link:hover {
            background-color: #e9ecef;
            color: #0d6efd;
        }
        .nav-link.btn-primary {
            background-color: #0d6efd;
            color: white;
        }
        .nav-link.btn-primary:hover {
            background-color: #0b5ed7;
            color: white;
        }
        .nav-link.btn-success {
            background-color: #198754;
            color: white;
        }
        .nav-link.btn-success:hover {
            background-color: #157347;
            color: white;
        }

        /* Main Content Area */
        .main-container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .card { 
            background: rgba(255, 255, 255, 0.95); 
            backdrop-filter: blur(10px);
            padding: 40px 30px; 
            border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); 
            width: 100%; 
            max-width: 420px; 
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeIn 0.6s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
        h2 { text-align: center; color: #2c3e50; margin-top: 0; font-size: 24px; margin-bottom: 25px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; color: #495057; font-weight: 600; font-size: 14px; }
        input[type="email"], input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 8px; box-sizing: border-box; font-size: 14px; transition: border-color 0.2s; }
        input[type="email"]:focus, input[type="password"]:focus { border-color: #0d6efd; outline: none; box-shadow: 0 0 0 3px rgba(13,110,253,0.15); }
        .btn { width: 100%; padding: 12px; background-color: #198754; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 15px; font-weight: 600; margin-top: 10px; transition: all 0.2s; }
        .btn:hover { background-color: #157347; transform: translateY(-1px); }
        .message { display: block; text-align: center; margin-top: 15px; font-weight: 600; font-size: 14px; }
        .error { color: #dc3545; }
        .success { color: #198754; }
        .link { text-align: center; margin-top: 20px; font-size: 14px; color: #6c757d; }
        .link a { color: #0d6efd; text-decoration: none; font-weight: 600; }
        .link a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Top Navigation Bar -->
        <nav class="navbar">
            <a href="Index.aspx" class="nav-brand">🎓 E-Learning Platform</a>
            <div class="nav-links">
                <a href="Login.aspx" class="nav-link btn-success">เข้าสู่ระบบ</a>
                <a href="Register.aspx" class="nav-link btn-primary">สมัครสมาชิก</a>
            </div>
        </nav>

        <!-- Main Content -->
        <div class="main-container">
            <div class="card">
                <h2>🔐 เข้าสู่ระบบ</h2>
                <div class="form-group">
                    <label>อีเมล</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" required="true" placeholder="name@example.com"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>รหัสผ่าน</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" required="true" placeholder="••••••••"></asp:TextBox>
                </div>
                <asp:Button ID="btnLogin" runat="server" Text="เข้าสู่ระบบ" CssClass="btn" OnClick="btnLogin_Click" />
                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                <div class="link">
                    ยังไม่มีบัญชีใช่ไหม? <a href="Register.aspx">สมัครสมาชิกที่นี่</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>