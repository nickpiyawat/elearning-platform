using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class Enroll : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["UserRole"]?.ToString() != "Student")
            {
                // ถ้าเป็นผู้สอน (Instructor) ไม่ต้องสมัคร ให้ไปหน้าอื่น
                Response.Redirect("Index.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litNavUser.Text = $"สวัสดี, {Session["UserName"]}";
                LoadCourseInfo();
            }
        }

        private int GetCourseId()
        {
            if (Request.QueryString["course_id"] != null && int.TryParse(Request.QueryString["course_id"], out int id))
            {
                return id;
            }
            return 0;
        }

        private void LoadCourseInfo()
        {
            int courseId = GetCourseId();
            if (courseId == 0) { Response.Redirect("Courses.aspx"); return; }

            string query = "SELECT title, description, price FROM courses WHERE course_id = @course_id";

            // เปิดการเชื่อมต่อฐานข้อมูล (conn จะมีชีวิตอยู่ตั้งแต่ปีกกาเปิดนี้ ไปจนถึงปีกกาปิดล่างสุด)
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@course_id", courseId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litCourseDetails.Text = $@"
                                <h3>{reader["title"]}</h3>
                                <p>{reader["description"]}</p>
                                <div class='price-tag'>ราคา: ฿{Convert.ToDecimal(reader["price"]):N2}</div>";
                        }
                        else
                        {
                            Response.Redirect("Index.aspx");
                            return;
                        }
                    } // ปิด reader ตรงนี้ ทำให้เราสามารถใช้ conn ดึงข้อมูลต่อได้
                }

                // --- โค้ดตรวจสอบการสมัครเรียน ย้ายมาอยู่ตรงนี้ครับ (ยังอยู่ข้างในวงเล็บของ conn) ---
                string checkEnrollSql = "SELECT COUNT(1) FROM enrollments WHERE student_id = @student_id AND course_id = @course_id";
                using (SqlCommand cmdCheck = new SqlCommand(checkEnrollSql, conn))
                {
                    cmdCheck.Parameters.AddWithValue("@student_id", Convert.ToInt32(Session["UserId"]));
                    cmdCheck.Parameters.AddWithValue("@course_id", courseId);
                    int isEnrolled = Convert.ToInt32(cmdCheck.ExecuteScalar());

                    if (isEnrolled > 0)
                    {
                        pnlEnrollAction.Visible = false;
                        pnlPaymentAction.Visible = false;
                        pnlSuccessAction.Visible = true;
                        hlStartLearning.NavigateUrl = $"Lessons.aspx?course_id={courseId}";
                        hlStartLearning.Text = "📚 เข้าสู่บทเรียนเลย";
                        lblMessage.Visible = true;
                        lblMessage.Text = "คุณได้สมัครเรียนคอร์สนี้เรียบร้อยแล้ว";
                        lblMessage.CssClass = "message success";
                    }
                }

            } 
        }

        protected void btnEnroll_Click(object sender, EventArgs e)
        {
            int studentId = Convert.ToInt32(Session["UserId"]);
            int courseId = GetCourseId();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // ดึงราคาปัจจุบัน
                    decimal coursePrice = 0;
                    string priceQuery = "SELECT price FROM courses WHERE course_id = @course_id";
                    using (SqlCommand cmdPrice = new SqlCommand(priceQuery, conn))
                    {
                        cmdPrice.Parameters.AddWithValue("@course_id", courseId);
                        coursePrice = Convert.ToDecimal(cmdPrice.ExecuteScalar());
                    }

                    // บันทึกลงตาราง enrollments และ payments
                    string insertSql = @"
                        DECLARE @new TABLE (id INT);
                        
                        INSERT INTO enrollments (student_id, course_id, price_at_purchase)
                        OUTPUT INSERTED.enrollment_id INTO @new
                        VALUES (@student_id, @course_id, @price);
                        
                        INSERT INTO payments (enrollment_id, amount, method)
                        SELECT id, @price, 'CreditCard' FROM @new;
                        
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@student_id", studentId);
                        cmd.Parameters.AddWithValue("@course_id", courseId);
                        cmd.Parameters.AddWithValue("@price", coursePrice);

                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            Session["PendingPaymentId"] = result;
                            ShowMessage("สร้างคำขอสมัครเรียนสำเร็จ! กรุณากดยืนยันการชำระเงินด้านล่าง", true);
                            pnlEnrollAction.Visible = false;
                            pnlPaymentAction.Visible = true;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    // ดัก Error กรณี Unique Constraint (เคยสมัครไปแล้ว)
                    if (ex.Number == 2627 || ex.Number == 2601)
                    {
                        ShowMessage("คุณได้สมัครเรียนคอร์สนี้ไปแล้ว กรุณาไปที่หน้าบทเรียน", false);
                        pnlEnrollAction.Visible = false;
                        pnlSuccessAction.Visible = true;
                        hlStartLearning.NavigateUrl = $"Lessons.aspx?course_id={courseId}";
                    }
                    else
                    {
                        ShowMessage("เกิดข้อผิดพลาดจากฐานข้อมูล: " + ex.Message, false);
                    }
                }
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            if (Session["PendingPaymentId"] == null)
            {
                ShowMessage("ไม่พบรายการชำระเงินที่ต้องยืนยัน", false);
                return;
            }

            int paymentId = Convert.ToInt32(Session["PendingPaymentId"]);
            string method = ddlMethod.SelectedValue;
            int courseId = GetCourseId();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // อัปเดตช่องทางการชำระเงิน
                    string updateMethod = "UPDATE payments SET method = @method WHERE payment_id = @payment_id";
                    using (SqlCommand cmdM = new SqlCommand(updateMethod, conn))
                    {
                        cmdM.Parameters.AddWithValue("@method", method);
                        cmdM.Parameters.AddWithValue("@payment_id", paymentId);
                        cmdM.ExecuteNonQuery();
                    }

                    // เรียกใช้ Stored Procedure ตามสเปค
                    using (SqlCommand cmd = new SqlCommand("sp_confirm_payment", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@payment_id", paymentId);
                        cmd.ExecuteNonQuery();
                    }

                    ShowMessage("ชำระเงินสำเร็จ! คุณสามารถเข้าสู่บทเรียนได้ทันที", true);
                    pnlPaymentAction.Visible = false;
                    pnlSuccessAction.Visible = true;
                    hlStartLearning.NavigateUrl = $"Lessons.aspx?course_id={courseId}";

                    Session.Remove("PendingPaymentId");
                }
                catch (SqlException ex)
                {
                    string errorMsg = "เกิดข้อผิดพลาดในการชำระเงิน";
                    switch (ex.Number)
                    {
                        case 50011: errorMsg = "ไม่พบรายการชำระเงิน"; break;
                        case 50012: errorMsg = "รายการนี้ถูกชำระเงินหรือยกเลิกไปแล้ว"; break;
                        case 50013: errorMsg = "คุณชำระเงินสำหรับคอร์สนี้ไปแล้ว"; break;
                    }
                    ShowMessage(errorMsg, false);
                }
            }
        }

        private void ShowMessage(string msg, bool isSuccess)
        {
            lblMessage.Visible = true;
            lblMessage.Text = msg;
            lblMessage.CssClass = isSuccess ? "message success" : "message error";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}