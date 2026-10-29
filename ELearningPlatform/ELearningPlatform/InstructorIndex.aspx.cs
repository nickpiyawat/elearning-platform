using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class InstructorIndex : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["UserRole"]?.ToString() != "Instructor")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardAnalytics();
            }
        }

        private void LoadDashboardAnalytics()
        {
            int instructorId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT * FROM vw_course_engagement_analytics WHERE instructor_id = @instructor_id ORDER BY course_id DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@instructor_id", instructorId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptAnalytics.DataSource = dt;
                            rptAnalytics.DataBind();

                            int totalCourses = dt.Rows.Count;
                            int totalStudents = 0;
                            decimal sumAvgScore = 0;
                            int coursesWithScore = 0;

                            foreach (DataRow row in dt.Rows)
                            {
                                // ใช้ enrolled_count ให้ตรงกับ View ใน logic.sql
                                totalStudents += Convert.ToInt32(row["enrolled_count"]);
                                if (row["avg_score"] != DBNull.Value)
                                {
                                    decimal score = Convert.ToDecimal(row["avg_score"]);
                                    sumAvgScore += score;
                                    coursesWithScore++;
                                }
                            }

                            litTotalCourses.Text = totalCourses.ToString("N0");
                            litTotalStudents.Text = totalStudents.ToString("N0");

                            decimal finalAvgScore = coursesWithScore > 0 ? (sumAvgScore / coursesWithScore) : 0;
                            litAvgScore.Text = finalAvgScore.ToString("0.0");
                            lblNoData.Visible = false;
                        }
                        else
                        {
                            rptAnalytics.DataSource = null;
                            rptAnalytics.DataBind();
                            lblNoData.Visible = true;
                            litTotalCourses.Text = "0";
                            litTotalStudents.Text = "0";
                            litAvgScore.Text = "0";
                        }
                    }
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