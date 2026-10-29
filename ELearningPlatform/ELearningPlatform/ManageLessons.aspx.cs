using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class ManageLessons : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["UserRole"]?.ToString() != "Instructor")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Request.QueryString["course_id"] == null || !int.TryParse(Request.QueryString["course_id"], out int courseId))
            {
                Response.Redirect("ManageCourses.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseInfo(courseId);
                LoadLessons(courseId);
            }
        }

        private void LoadCourseInfo(int courseId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT title FROM courses WHERE course_id = @course_id AND instructor_id = @instructor_id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@course_id", courseId);
                    cmd.Parameters.AddWithValue("@instructor_id", Convert.ToInt32(Session["UserId"]));
                    conn.Open();
                    object title = cmd.ExecuteScalar();
                    if (title != null)
                    {
                        litCourseTitle.Text = title.ToString();
                    }
                    else
                    {
                        Response.Redirect("ManageCourses.aspx"); // ป้องกันแอบแก้ URL ไปดูคอร์สคนอื่น
                    }
                }
            }
        }

        private void LoadLessons(int courseId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT lesson_id, lesson_no, title FROM lessons WHERE course_id = @course_id ORDER BY lesson_no ASC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@course_id", courseId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        if (dt.Rows.Count > 0)
                        {
                            rptLessons.DataSource = dt;
                            rptLessons.DataBind();
                            lblNoLesson.Visible = false;
                        }
                        else
                        {
                            rptLessons.DataSource = null;
                            rptLessons.DataBind();
                            lblNoLesson.Visible = true;
                        }
                    }
                }
            }
        }

        protected void btnSaveLesson_Click(object sender, EventArgs e)
        {
            int courseId = Convert.ToInt32(Request.QueryString["course_id"]);
            int lessonNo = 1;
            int.TryParse(txtLessonNo.Text, out lessonNo);
            string title = txtTitle.Text.Trim();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                // 1. บันทึกบทเรียน
                string insertLessonSql = "INSERT INTO lessons (course_id, lesson_no, title) VALUES (@course_id, @lesson_no, @title); SELECT SCOPE_IDENTITY();";
                int lessonId = 0;
                using (SqlCommand cmd = new SqlCommand(insertLessonSql, conn))
                {
                    cmd.Parameters.AddWithValue("@course_id", courseId);
                    cmd.Parameters.AddWithValue("@lesson_no", lessonNo);
                    cmd.Parameters.AddWithValue("@title", title);
                    lessonId = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // 2. สร้าง Quiz (แบบทดสอบ) รองรับบทเรียนนี้แบบอัตโนมัติ 1 บทต่อ 1 Quiz ทันที
                string insertQuizSql = "INSERT INTO quizzes (lesson_id, title, passing_score, max_attempts) VALUES (@lesson_id, @title, 60.00, 3)";
                using (SqlCommand cmdQ = new SqlCommand(insertQuizSql, conn))
                {
                    cmdQ.Parameters.AddWithValue("@lesson_id", lessonId);
                    cmdQ.Parameters.AddWithValue("@title", "แบบทดสอบ: " + title);
                    cmdQ.ExecuteNonQuery();
                }
            }

            txtLessonNo.Text = "";
            txtTitle.Text = "";
            lblMessage.Text = "✅ เพิ่มบทเรียนและสร้างแบบทดสอบประจำบทสำเร็จ!";
            lblMessage.ForeColor = System.Drawing.Color.Green;
            LoadLessons(courseId);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}