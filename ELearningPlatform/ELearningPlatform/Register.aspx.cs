using System;
using System.Data.SqlClient;
using System.Configuration;

namespace ELearningPlatform 
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string role = ddlRole.SelectedValue;

            // ดึง Connection String จาก Web.config
            string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // เช็กอีเมลซ้ำจากทั้งสองตารางตามเอกสาร Backend (กฎ Disjoint ห้ามมีอีเมลซ้ำในทั้งระบบ)
                    string checkSql = @"
                        SELECT 1 FROM students WHERE email = @email
                        UNION ALL
                        SELECT 1 FROM instructors WHERE email = @email";

                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        var exists = checkCmd.ExecuteScalar();
                        if (exists != null)
                        {
                            lblMessage.Text = "อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น";
                            lblMessage.CssClass = "message error";
                            return;
                        }
                    }

                    // แฮชรหัสผ่านด้วยคลาสที่เราสร้างไว้
                    string hash = AuthHelper.HashPassword(password);

                    // เลือกตารางที่จะบันทึกตาม DropDownList
                    string insertSql = role == "Student"
                        ? "INSERT INTO students (full_name, email, password_hash) VALUES (@name, @email, @hash)"
                        : "INSERT INTO instructors (full_name, email, password_hash) VALUES (@name, @email, @hash)";

                    using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@name", name);
                        insertCmd.Parameters.AddWithValue("@email", email);
                        insertCmd.Parameters.AddWithValue("@hash", hash);
                        insertCmd.ExecuteNonQuery();
                    }

                    lblMessage.Text = "สมัครสมาชิกสำเร็จ! สามารถเข้าสู่ระบบได้เลย";
                    lblMessage.CssClass = "message success";

                    // เคลียร์ฟอร์ม
                    txtName.Text = "";
                    txtEmail.Text = "";
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