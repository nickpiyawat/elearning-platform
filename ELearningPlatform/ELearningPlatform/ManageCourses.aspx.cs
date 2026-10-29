using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace ELearningPlatform
{
    public partial class ManageCourses : System.Web.UI.Page
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
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            int instructorId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT course_id, title, price FROM courses WHERE instructor_id = @instructor_id ORDER BY course_id DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@instructor_id", instructorId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        if (dt.Rows.Count > 0)
                        {
                            rptCourses.DataSource = dt;
                            rptCourses.DataBind();
                            lblNoCourse.Visible = false;
                        }
                        else
                        {
                            rptCourses.DataSource = null;
                            rptCourses.DataBind();
                            lblNoCourse.Visible = true;
                        }
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int instructorId = Convert.ToInt32(Session["UserId"]);
            string title = txtTitle.Text.Trim();
            string desc = txtDescription.Text.Trim();
            decimal price = 0;
            decimal.TryParse(txtPrice.Text, out price);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // เอา instructor_name ออก เพราะตารางจริงไม่มีคอลัมน์นี้
                string sql = "INSERT INTO courses (title, description, price, instructor_id) VALUES (@title, @desc, @price, @instructor_id)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", desc);
                    cmd.Parameters.AddWithValue("@price", price);
                    cmd.Parameters.AddWithValue("@instructor_id", instructorId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            txtTitle.Text = "";
            txtDescription.Text = "";
            txtPrice.Text = "";
            lblMessage.Text = "✅ สร้างคอร์สเรียนสำเร็จ!";
            lblMessage.ForeColor = System.Drawing.Color.Green;
            LoadCourses();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Index.aspx");
        }
    }
}