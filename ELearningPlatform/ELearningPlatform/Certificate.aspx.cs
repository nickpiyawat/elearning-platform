using System;
using System.Data.SqlClient;
using System.Configuration;

namespace ELearningPlatform
{
    public partial class Certificate : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["UserRole"]?.ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ValidateAndGenerateCertificate();
            }
        }

        private void ValidateAndGenerateCertificate()
        {
            if (Request.QueryString["course_id"] == null || !int.TryParse(Request.QueryString["course_id"], out int courseId))
            {
                Response.Redirect("Index.aspx");
                return;
            }

            int studentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // ตรวจสอบว่าระบบ (Stored Procedure) ได้ออก Certificate เก็บไว้ในตารางให้หรือยัง
                string sql = @"
                    SELECT c.title AS CourseTitle, cert.issued_at AS CompletionDate
                    FROM certificates cert
                    JOIN enrollments e ON cert.enrollment_id = e.enrollment_id
                    JOIN courses c ON e.course_id = c.course_id
                    WHERE e.student_id = @student_id AND e.course_id = @course_id;
                ";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@course_id", courseId);
                    cmd.Parameters.AddWithValue("@student_id", studentId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litStudentName.Text = Session["UserName"].ToString();
                            litCourseName.Text = reader["CourseTitle"].ToString();

                            DateTime compDate = reader["CompletionDate"] != DBNull.Value ? Convert.ToDateTime(reader["CompletionDate"]) : DateTime.Now;
                            litDate.Text = compDate.ToString("d MMMM yyyy", new System.Globalization.CultureInfo("th-TH"));
                        }
                        else
                        {
                            pnlCertificate.Visible = false;
                            pnlError.Visible = true;
                            litErrorMsg.Text = "คุณยังทำแบบทดสอบผ่านไม่ครบทุกบทเรียน หรือยังไม่ได้รับอนุมัติใบประกาศนียบัตร";
                        }
                    }
                }
            }
        }
    }
}