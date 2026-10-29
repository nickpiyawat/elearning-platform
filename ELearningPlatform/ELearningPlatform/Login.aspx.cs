using System;
using System.Data.SqlClient;
using System.Configuration;

namespace ELearningPlatform 
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // แฮชรหัสผ่านด้วยวิธีเดียวกับตอนสมัคร
            string hashedPassword = AuthHelper.HashPassword(password);
            string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // 1. ตรวจสอบในตาราง students ก่อน
                    string studentSql = "SELECT student_id, full_name FROM students WHERE email = @email AND password_hash = @hash";
                    using (SqlCommand cmd = new SqlCommand(studentSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@hash", hashedPassword);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["UserId"] = reader["student_id"];
                                Session["UserName"] = reader["full_name"];
                                Session["UserRole"] = "Student";

                                // เด้งไปหน้ารวมคอร์สทันที
                                Response.Redirect("Courses.aspx");
                                return;
                            }
                        }
                    }

                    // 2. ถ้าไม่พบใน students ให้ตรวจต่อในตาราง instructors
                    string instructorSql = "SELECT instructor_id, full_name FROM instructors WHERE email = @email AND password_hash = @hash";
                    using (SqlCommand cmd = new SqlCommand(instructorSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@hash", hashedPassword);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["UserId"] = reader["instructor_id"];
                                Session["UserName"] = reader["full_name"];
                                Session["UserRole"] = "Instructor";

                                // เด้งไปหน้ารวมคอร์สทันที
                                Response.Redirect("InstructorIndex.aspx");
                                return;
                            }
                        }
                    }

                    // หากไม่พบข้อมูลในทั้งสองตาราง
                    lblMessage.Text = "อีเมลหรือรหัสผ่านไม่ถูกต้อง";
                    lblMessage.CssClass = "message error";
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "เกิดข้อผิดพลาด: " + ex.Message;
                    lblMessage.CssClass = "message error";
                }
            }
        }
    }
}