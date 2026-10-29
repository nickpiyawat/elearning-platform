using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class Lessons : System.Web.UI.Page
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
                litNavUser.Text = $"สวัสดี, {Session["UserName"]}";
                ValidateAccessAndLoad();
            }
        }

        private void ValidateAccessAndLoad()
        {
            if (Request.QueryString["course_id"] == null || !int.TryParse(Request.QueryString["course_id"], out int courseId))
            {
                Response.Redirect("Index.aspx");
                return;
            }

            int studentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string checkSql = @"
                    SELECT COUNT(1) FROM enrollments e
                    LEFT JOIN payments p ON e.enrollment_id = p.enrollment_id
                    WHERE e.student_id = @student_id AND e.course_id = @course_id 
                    AND (p.payment_id IS NOT NULL OR e.price_at_purchase = 0)";

                using (SqlCommand cmdCheck = new SqlCommand(checkSql, conn))
                {
                    cmdCheck.Parameters.AddWithValue("@student_id", studentId);
                    cmdCheck.Parameters.AddWithValue("@course_id", courseId);
                    conn.Open();

                    int hasAccess = Convert.ToInt32(cmdCheck.ExecuteScalar());

                    if (hasAccess > 0)
                    {
                        LoadCourseContent(conn, courseId, studentId);
                    }
                    else
                    {
                        pnlContent.Visible = false;
                        pnlAccessDenied.Visible = true;
                    }
                }
            }
        }

        private void LoadCourseContent(SqlConnection conn, int courseId, int studentId)
        {
            using (SqlCommand cmdCourse = new SqlCommand("SELECT title, description FROM courses WHERE course_id = @course_id", conn))
            {
                cmdCourse.Parameters.AddWithValue("@course_id", courseId);
                using (SqlDataReader reader = cmdCourse.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        litCourseTitle.Text = reader["title"].ToString();
                        litCourseDesc.Text = reader["description"].ToString();
                    }
                }
            }

            // คำนวณความก้าวหน้าการเรียน: ดึงจากตาราง enrollments ได้เลย (Trigger ทำให้แล้ว)
            string progressSql = "SELECT ISNULL(progress_percent, 0) FROM enrollments WHERE student_id = @student_id AND course_id = @course_id";
            decimal progress = 0;
            using (SqlCommand cmdProg = new SqlCommand(progressSql, conn))
            {
                cmdProg.Parameters.AddWithValue("@course_id", courseId);
                cmdProg.Parameters.AddWithValue("@student_id", studentId);
                object progRes = cmdProg.ExecuteScalar();
                if (progRes != DBNull.Value && progRes != null)
                {
                    progress = Convert.ToDecimal(progRes);
                }

                divProgressBar.Style["width"] = $"{progress}%";
                lblProgressText.InnerText = $"{progress:0}%";

                if (progress >= 100)
                {
                    litCertButton.Text = $"<a href='Certificate.aspx?course_id={courseId}' class='btn-cert'>🎓 รับใบประกาศนียบัตร</a>";
                }
                else
                {
                    litCertButton.Text = "";
                }
            }

            // ดึงรายการบทเรียน เช็กสถานะว่าบทนี้สอบผ่านหรือยัง
            string lessonSql = @"
                SELECT l.lesson_id, l.lesson_no, l.title,
                    ISNULL((
                        SELECT TOP 1 qs.passed 
                        FROM quizzes q 
                        JOIN quiz_submissions qs ON q.quiz_id = qs.quiz_id 
                        WHERE q.lesson_id = l.lesson_id 
                        AND qs.enrollment_id = (SELECT enrollment_id FROM enrollments WHERE student_id = @student_id AND course_id = @course_id)
                        ORDER BY qs.submitted_at DESC
                    ), 0) AS IsPassed
                FROM lessons l 
                WHERE l.course_id = @course_id 
                ORDER BY l.lesson_no ASC";

            using (SqlCommand cmd = new SqlCommand(lessonSql, conn))
            {
                cmd.Parameters.AddWithValue("@course_id", courseId);
                cmd.Parameters.AddWithValue("@student_id", studentId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptLessons.DataSource = dt;
                    rptLessons.DataBind();
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}