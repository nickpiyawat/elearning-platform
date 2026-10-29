using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class ManageQuizzes : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["UserRole"]?.ToString() != "Instructor")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Request.QueryString["lesson_id"] == null || Request.QueryString["course_id"] == null ||
                !int.TryParse(Request.QueryString["lesson_id"], out int lessonId) ||
                !int.TryParse(Request.QueryString["course_id"], out int courseId))
            {
                Response.Redirect("ManageCourses.aspx");
                return;
            }

            litBackLink.Text = $"<a href='ManageLessons.aspx?course_id={courseId}' class='btn btn-secondary'>⬅️ กลับไปหน้าจัดการบทเรียน</a>";

            if (!IsPostBack)
            {
                LoadLessonAndQuizInfo(lessonId);
                LoadQuestions(lessonId);
            }
        }

        private void LoadLessonAndQuizInfo(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string sql = "SELECT l.title AS lesson_title, q.passing_score FROM lessons l LEFT JOIN quizzes q ON l.lesson_id = q.lesson_id WHERE l.lesson_id = @lesson_id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@lesson_id", lessonId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litLessonTitle.Text = reader["lesson_title"].ToString();
                            if (reader["passing_score"] != DBNull.Value && !IsPostBack)
                            {
                                txtPassingScore.Text = Convert.ToDecimal(reader["passing_score"]).ToString("0");
                            }
                        }
                    }
                }
            }
        }

        private void LoadQuestions(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int quizId = GetOrCreateQuizId(conn, lessonId);

                string sql = "SELECT question_id, question_text, correct_option, points FROM questions WHERE quiz_id = @quiz_id ORDER BY question_id ASC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@quiz_id", quizId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        if (dt.Rows.Count > 0)
                        {
                            rptQuestions.DataSource = dt;
                            rptQuestions.DataBind();
                            lblNoQuestion.Visible = false;
                        }
                        else
                        {
                            rptQuestions.DataSource = null;
                            rptQuestions.DataBind();
                            lblNoQuestion.Visible = true;
                        }
                    }
                }
            }
        }

        private int GetOrCreateQuizId(SqlConnection conn, int lessonId)
        {
            string checkSql = "SELECT quiz_id FROM quizzes WHERE lesson_id = @lesson_id";
            using (SqlCommand cmd = new SqlCommand(checkSql, conn))
            {
                cmd.Parameters.AddWithValue("@lesson_id", lessonId);
                object res = cmd.ExecuteScalar();
                if (res != null)
                {
                    return Convert.ToInt32(res);
                }
                else
                {
                    string insertSql = "INSERT INTO quizzes (lesson_id, title, passing_score, max_attempts) VALUES (@lesson_id, 'แบบทดสอบประจำบท', 60.00, 3); SELECT SCOPE_IDENTITY();";
                    using (SqlCommand cmdIns = new SqlCommand(insertSql, conn))
                    {
                        cmdIns.Parameters.AddWithValue("@lesson_id", lessonId);
                        return Convert.ToInt32(cmdIns.ExecuteScalar());
                    }
                }
            }
        }

        protected void btnUpdatePassing_Click(object sender, EventArgs e)
        {
            int lessonId = Convert.ToInt32(Request.QueryString["lesson_id"]);
            decimal passingScore = 60;
            decimal.TryParse(txtPassingScore.Text, out passingScore);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int quizId = GetOrCreateQuizId(conn, lessonId);

                string sql = "UPDATE quizzes SET passing_score = @passing_score WHERE quiz_id = @quiz_id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@passing_score", passingScore);
                    cmd.Parameters.AddWithValue("@quiz_id", quizId);
                    cmd.ExecuteNonQuery();
                }
            }

            lblPassingMsg.Text = "✅ บันทึกเกณฑ์การสอบผ่านสำเร็จ!";
            lblPassingMsg.ForeColor = System.Drawing.Color.Green;
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            int lessonId = Convert.ToInt32(Request.QueryString["lesson_id"]);
            string qText = txtQuestionText.Text.Trim();
            string correctOpt = ddlCorrectOption.SelectedValue;
            int points = 1;
            int.TryParse(txtPoints.Text, out points);
            if (points < 1) points = 1;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int quizId = GetOrCreateQuizId(conn, lessonId);

                string sql = @"INSERT INTO questions (quiz_id, question_text, correct_option, points) 
                               VALUES (@quiz_id, @q_text, @correct_opt, @points)";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@quiz_id", quizId);
                    cmd.Parameters.AddWithValue("@q_text", qText);
                    cmd.Parameters.AddWithValue("@correct_opt", correctOpt);
                    cmd.Parameters.AddWithValue("@points", points);

                    cmd.ExecuteNonQuery();
                }
            }

            txtQuestionText.Text = "";
            txtPoints.Text = "1";
            lblMessage.Text = "✅ เพิ่มข้อสอบสำเร็จ!";
            lblMessage.ForeColor = System.Drawing.Color.Green;

            LoadQuestions(lessonId);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}