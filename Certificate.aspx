<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Certificate.aspx.cs" Inherits="ELearningPlatform.Certificate" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ใบประกาศนียบัตร - E-Learning Platform</title>
    <!-- นำเข้าฟอนต์ภาษาไทยจาก Google Fonts ให้สวยงาม -->
    <link href="https://fonts.googleapis.com/css2?family=Sarabun:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { 
            font-family: 'Sarabun', sans-serif; 
            background: #e9ecef; 
            text-align: center; 
            margin: 0; padding: 0;
        }
        
        .no-print { padding: 20px; background: white; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .btn { padding: 10px 20px; font-size: 16px; border-radius: 6px; cursor: pointer; font-weight: bold; text-decoration: none; border: none; }
        .btn-print { background: #198754; color: white; margin-right: 15px; }
        .btn-print:hover { background: #157347; }
        .btn-back { background: #6c757d; color: white; }
        
        .cert-wrapper { display: flex; justify-content: center; }
        .cert-container { 
            width: 900px; height: 630px; background: white; 
            position: relative; border: 15px solid #0d6efd; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.15); 
            padding: 40px; box-sizing: border-box;
        }
        .cert-inner { 
            border: 2px solid #0d6efd; height: 100%; 
            padding: 50px 40px; box-sizing: border-box; 
            background-image: radial-gradient(#f8f9fa 20%, transparent 20%);
            background-size: 10px 10px;
        }
        
        .title { font-size: 45px; font-weight: 700; color: #0d6efd; margin-bottom: 25px; letter-spacing: 2px; }
        .subtitle { font-size: 22px; color: #495057; margin-bottom: 35px; }
        
        .student-name { 
            font-size: 40px; font-weight: 700; color: #2c3e50; 
            border-bottom: 2px solid #ced4da; display: inline-block; 
            padding: 0 50px 10px; margin-bottom: 35px; min-width: 400px;
        }
        
        .course-name { font-size: 32px; font-weight: 700; color: #198754; margin: 15px 0 50px; }
        
        .footer { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 40px; font-size: 18px; color: #495057; padding: 0 20px; }
        .signature-line { border-top: 1px solid #000; padding-top: 10px; width: 220px; margin: 0 auto; text-align: center; }
        
        /* ตั้งค่าซ่อนปุ่ม และปรับหน้ากระดาษเมื่อสั่ง Print */
        @media print {
            @page { size: landscape; margin: 0; }
            body { background: white; }
            .no-print { display: none; }
            .cert-container { margin: 0; box-shadow: none; border-width: 12px; width: 100%; height: 98vh; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Panel ID="pnlCertificate" runat="server">
            <div class="no-print">
                <button type="button" class="btn btn-print" onclick="window.print()">🖨️ พิมพ์ / บันทึกเป็น PDF</button>
                <a href="Lessons.aspx?course_id=<%= Request.QueryString["course_id"] %>" class="btn btn-back">กลับไปหน้าบทเรียน</a>
            </div>
            
            <div class="cert-wrapper">
                <div class="cert-container">
                    <div class="cert-inner">
                        <div class="title">ใบประกาศนียบัตร</div>
                        <div class="subtitle">ขอมอบใบประกาศนียบัตรนี้เพื่อแสดงว่า</div>
                        
                        <div class="student-name">
                            <asp:Literal ID="litStudentName" runat="server"></asp:Literal>
                        </div>
                        
                        <div class="subtitle">ได้สำเร็จการศึกษาและผ่านการทดสอบหลักสูตร</div>
                        <div class="course-name">
                            "<asp:Literal ID="litCourseName" runat="server"></asp:Literal>"
                        </div>
                        
                        <div class="footer">
                            <div>
                                <strong>ให้ไว้ ณ วันที่:</strong> <asp:Literal ID="litDate" runat="server"></asp:Literal>
                            </div>
                            <div>
                                <div class="signature-line">ผู้อำนวยการหลักสูตร</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- แสดงข้อความนี้ถ้านักเรียนยังเรียนไม่จบ -->
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div style="margin: 100px auto; padding: 40px; background: white; border-radius: 12px; max-width: 500px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
                <h2 style="color: #dc3545; margin-top: 0;">ยังไม่สามารถออกใบประกาศฯ ได้ 🚫</h2>
                <p style="color: #6c757d; font-size: 16px; margin-bottom: 25px;">
                    <asp:Literal ID="litErrorMsg" runat="server"></asp:Literal>
                </p>
                <a href="Lessons.aspx?course_id=<%= Request.QueryString["course_id"] %>" class="btn btn-back">กลับไปหน้าบทเรียนเพื่อทำแบบทดสอบให้ครบ</a>
            </div>
        </asp:Panel>
    </form>
</body>
</html>