using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class MyCourses : System.Web.UI.Page
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
                LoadMyCourses();
            }
        }

        private void LoadMyCourses()
        {
            int studentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT c.course_id, c.title, ISNULL(e.progress_percent, 0) AS progress_percent 
                    FROM enrollments e
                    JOIN courses c ON e.course_id = c.course_id
                    WHERE e.student_id = @student_id
                    ORDER BY e.enrollment_id DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@student_id", studentId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptMyCourses.DataSource = dt;
                            rptMyCourses.DataBind();
                        }
                        else
                        {
                            pnlNoCourses.Visible = true;
                        }
                    }
                }
            }
        }
    }
}