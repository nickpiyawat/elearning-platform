using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace ELearningPlatform
{
    public partial class Quiz : System.Web.UI.Page
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
                ValidateAndLoadQuiz();
            }
        }

        private void ValidateAndLoadQuiz()
        {
            if (Request.QueryString["course_id"] == null || Request.QueryString["lesson_id"] == null ||
                !int.TryParse(Request.QueryString["course_id"], out int courseId) ||
                !int.TryParse(Request.QueryString["lesson_id"], out int lessonId))
            {
                Response.Redirect("Index.aspx");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                using (SqlCommand cmdQuizInfo = new SqlCommand("SELECT title FROM quizzes WHERE lesson_id = @lesson_id", conn))
                {
                    cmdQuizInfo.Parameters.AddWithValue("@lesson_id", lessonId);
                    object quizTitle = cmdQuizInfo.ExecuteScalar();
                    if (quizTitle != null) litQuizTitle.Text = quizTitle.ToString();
                }

                int enrollmentId = 0, quizId = 0, maxAttempts = 3, usedAttempts = 0;

                using (SqlCommand cmdE = new SqlCommand("SELECT enrollment_id FROM enrollments WHERE student_id = @student_id AND course_id = @course_id", conn))
                {
                    cmdE.Parameters.AddWithValue("@student_id", Convert.ToInt32(Session["UserId"]));
                    cmdE.Parameters.AddWithValue("@course_id", courseId);
                    object res = cmdE.ExecuteScalar();
                    if (res != null) enrollmentId = Convert.ToInt32(res);
                }

                using (SqlCommand cmdQ = new SqlCommand("SELECT quiz_id, max_attempts, passing_score FROM quizzes WHERE lesson_id = @lesson_id", conn))
                {
                    cmdQ.Parameters.AddWithValue("@lesson_id", lessonId);
                    using (SqlDataReader reader = cmdQ.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            quizId = Convert.ToInt32(reader["quiz_id"]);
                            if (reader["max_attempts"] != DBNull.Value) maxAttempts = Convert.ToInt32(reader["max_attempts"]);
                            if (reader["passing_score"] != DBNull.Value) litPassingScore.Text = Convert.ToDecimal(reader["passing_score"]).ToString("0");
                        }
                    }
                }

                using (SqlCommand cmdA = new SqlCommand("SELECT COUNT(*) FROM quiz_submissions WHERE enrollment_id = @enrollment_id AND quiz_id = @quiz_id", conn))
                {
                    cmdA.Parameters.AddWithValue("@enrollment_id", enrollmentId);
                    cmdA.Parameters.AddWithValue("@quiz_id", quizId);
                    usedAttempts = Convert.ToInt32(cmdA.ExecuteScalar());
                }

                int remaining = maxAttempts - usedAttempts;

                if (remaining <= 0)
                {
                    pnlQuiz.Visible = false;
                    pnlResult.Visible = true;
                    litScore.Text = $"คุณใช้สิทธิ์ทำแบบทดสอบครบ {maxAttempts} ครั้งแล้ว";
                    divResultBox.Attributes["class"] = "result-box result-fail";
                    btnBackToLesson.Visible = false;
                    btnResetAttempts.Visible = true;
                    Session["ResetQuizId"] = quizId;
                    Session["ResetCourseId"] = courseId;
                    return;
                }
                else
                {
                    litRemainingAttempts.Text = $"⚠️ เหลือสิทธิ์ {remaining}/{maxAttempts} ครั้ง";
                }

                string query = "SELECT q.question_id, q.question_text, ISNULL(q.points, 1) AS points FROM questions q JOIN quizzes qz ON q.quiz_id = qz.quiz_id WHERE qz.lesson_id = @lesson_id";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@lesson_id", lessonId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        if (dt.Rows.Count > 0)
                        {
                            rptQuestions.DataSource = dt;
                            rptQuestions.DataBind();
                        }
                        else
                        {
                            pnlQuiz.Visible = false; pnlResult.Visible = true;
                            litScore.Text = "ยังไม่มีคำถามสำหรับแบบทดสอบบทนี้"; divResultBox.Attributes["class"] = "result-box";
                        }
                    }
                }
            }
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");
                rbl.Items.Add(new ListItem(" A. ตัวเลือกที่หนึ่ง", "A"));
                rbl.Items.Add(new ListItem(" B. ตัวเลือกที่สอง", "B"));
                rbl.Items.Add(new ListItem(" C. ตัวเลือกที่สาม", "C"));
                rbl.Items.Add(new ListItem(" D. ตัวเลือกที่สี่", "D"));
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int courseId = Convert.ToInt32(Request.QueryString["course_id"]);
            int lessonId = Convert.ToInt32(Request.QueryString["lesson_id"]);
            int studentId = Convert.ToInt32(Session["UserId"]);

            List<string> answerList = new List<string>();
            foreach (RepeaterItem item in rptQuestions.Items)
            {
                HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                RadioButtonList rblOptions = (RadioButtonList)item.FindControl("rblOptions");

                string qId = hfQuestionId.Value;
                string ans = string.IsNullOrEmpty(rblOptions.SelectedValue) ? "X" : rblOptions.SelectedValue;
                answerList.Add($"{{\"q\":{qId},\"a\":\"{ans}\"}}");
            }
            string jsonAnswers = "[" + string.Join(",", answerList) + "]";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                int enrollmentId = 0, quizId = 0;
                using (SqlCommand cmdE = new SqlCommand("SELECT enrollment_id FROM enrollments WHERE student_id = @student_id AND course_id = @course_id", conn))
                {
                    cmdE.Parameters.AddWithValue("@student_id", studentId);
                    cmdE.Parameters.AddWithValue("@course_id", courseId);
                    object res = cmdE.ExecuteScalar();
                    if (res != null) enrollmentId = Convert.ToInt32(res);
                }

                using (SqlCommand cmdQ = new SqlCommand("SELECT quiz_id FROM quizzes WHERE lesson_id = @lesson_id", conn))
                {
                    cmdQ.Parameters.AddWithValue("@lesson_id", lessonId);
                    object res = cmdQ.ExecuteScalar();
                    if (res != null) quizId = Convert.ToInt32(res);
                }

                if (enrollmentId > 0 && quizId > 0)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("sp_submit_quiz_and_grade", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@enrollment_id", enrollmentId);
                            cmd.Parameters.AddWithValue("@quiz_id", quizId);
                            cmd.Parameters.AddWithValue("@answers", jsonAnswers);

                            SqlParameter pScore = new SqlParameter("@score_percent", SqlDbType.Decimal) { Direction = ParameterDirection.Output, Precision = 5, Scale = 2 };
                            SqlParameter pPassed = new SqlParameter("@passed", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                            SqlParameter pSubId = new SqlParameter("@submission_id", SqlDbType.Int) { Direction = ParameterDirection.Output };
                            SqlParameter pCertId = new SqlParameter("@certificate_id", SqlDbType.Int) { Direction = ParameterDirection.Output };

                            cmd.Parameters.Add(pScore);
                            cmd.Parameters.Add(pPassed);
                            cmd.Parameters.Add(pSubId);
                            cmd.Parameters.Add(pCertId);

                            cmd.ExecuteNonQuery();

                            decimal scorePercent = Convert.ToDecimal(pScore.Value);
                            bool isPassed = Convert.ToBoolean(pPassed.Value);

                            pnlQuiz.Visible = false;
                            pnlResult.Visible = true;
                            btnBackToLesson.HRef = $"Lessons.aspx?course_id={courseId}";
                            litScore.Text = $"คุณทำคะแนนได้ {scorePercent:0.00}%";

                            if (isPassed)
                            {
                                litStatus.Text = "🎉 ยินดีด้วย! คุณสอบผ่านบทเรียนนี้";
                                divResultBox.Attributes["class"] = "result-box result-pass";
                            }
                            else
                            {
                                litStatus.Text = "❌ เสียใจด้วย คุณสอบไม่ผ่าน (ต้องได้คะแนนตามเกณฑ์ที่กำหนด)";
                                divResultBox.Attributes["class"] = "result-box result-fail";
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        pnlQuiz.Visible = false;
                        pnlResult.Visible = true;
                        litScore.Text = "เกิดข้อผิดพลาดในการส่งข้อสอบ";
                        litStatus.Text = ex.Message;
                        divResultBox.Attributes["class"] = "result-box result-fail";
                        btnBackToLesson.HRef = $"Lessons.aspx?course_id={courseId}";
                    }
                }
            }
        }

        protected void btnResetAttempts_Click(object sender, EventArgs e)
        {
            if (Session["ResetQuizId"] == null || Session["ResetCourseId"] == null) return;

            int quizId = Convert.ToInt32(Session["ResetQuizId"]);
            int courseId = Convert.ToInt32(Session["ResetCourseId"]);
            int studentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int enrollmentId = 0;
                using (SqlCommand cmdE = new SqlCommand("SELECT enrollment_id FROM enrollments WHERE student_id = @student_id AND course_id = @course_id", conn))
                {
                    cmdE.Parameters.AddWithValue("@student_id", studentId);
                    cmdE.Parameters.AddWithValue("@course_id", courseId);
                    object res = cmdE.ExecuteScalar();
                    if (res != null) enrollmentId = Convert.ToInt32(res);
                }

                if (enrollmentId > 0)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("sp_reset_quiz_attempts", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@enrollment_id", enrollmentId);
                            cmd.Parameters.AddWithValue("@quiz_id", quizId);
                            cmd.Parameters.Add(new SqlParameter("@deleted_count", SqlDbType.Int) { Direction = ParameterDirection.Output });
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch (SqlException ex)
                    {
                        string msg = "ขอสอบใหม่ไม่สำเร็จ";
                        switch (ex.Number)
                        {
                            case 50005: msg = "คุณผ่านแบบทดสอบนี้แล้ว ไม่ต้องขอสอบใหม่"; break;
                            case 50006: msg = "คุณยังมีสิทธิ์สอบเหลืออยู่"; break;
                            case 50001: msg = "คุณยังไม่ได้ชำระเงินสำหรับคอร์สนี้"; break;
                        }
                        litStatus.Text = msg;
                        return;   // ไม่ redirect ผู้เรียนจะเห็นข้อความ
                    }
                }
            }

            Session.Remove("ResetQuizId");
            Session.Remove("ResetCourseId");
            Response.Redirect($"Lessons.aspx?course_id={courseId}");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}