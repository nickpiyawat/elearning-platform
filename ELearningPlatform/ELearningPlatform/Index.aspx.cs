using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class Index : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckUserSession();
                LoadTopCourses();
            }
        }

        private void CheckUserSession()
        {
            if (Session["UserName"] != null)
            {
                pnlGuestNav.Visible = false;
                pnlUserNav.Visible = true;
                litNavUser.Text = $"สวัสดี, {Session["UserName"]}";
            }
            else
            {
                pnlGuestNav.Visible = true;
                pnlUserNav.Visible = false;
            }
        }

        private void LoadTopCourses()
        {
            // Query จัดอันดับคอร์สที่มีผู้เรียนสมัครเรียนมากที่สุด 5 อันดับแรก
            string query = @"
                SELECT TOP 5 
                    c.course_id, 
                    c.title, 
                    c.description, 
                    c.price, 
                    i.full_name AS instructor_name,
                    ISNULL(e.enrollment_count, 0) AS enrollment_count
                FROM courses c
                JOIN instructors i ON i.instructor_id = c.instructor_id
                OUTER APPLY (
                    SELECT COUNT(*) AS enrollment_count 
                    FROM enrollments en 
                    WHERE en.course_id = c.course_id
                ) e
                ORDER BY enrollment_count DESC, c.course_id DESC";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptTopCourses.DataSource = dt;
                        rptTopCourses.DataBind();
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