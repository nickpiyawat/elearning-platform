using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class Courses : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckUserSession();
                LoadCourses("");
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

        private void LoadCourses(string searchTerm)
        {
            string connString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            string query = @"
                SELECT c.course_id, c.title, c.description, c.price, i.full_name AS instructor_name
                FROM courses c 
                JOIN instructors i ON i.instructor_id = c.instructor_id
                WHERE (@Search = '' OR c.title LIKE '%' + @Search + '%')
                ORDER BY c.course_id DESC";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Search", searchTerm);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptCourses.DataSource = dt;
                        rptCourses.DataBind();

                        if (dt.Rows.Count == 0)
                        {
                            lblNoResult.Visible = true;
                        }
                        else
                        {
                            lblNoResult.Visible = false;
                        }
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string keyword = txtSearch.Text.Trim();
            LoadCourses(keyword);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}