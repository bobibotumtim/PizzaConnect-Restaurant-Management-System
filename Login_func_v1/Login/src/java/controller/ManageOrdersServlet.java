//package controller;
//
//import jakarta.servlet.*;
//import jakarta.servlet.http.*;
//import java.io.IOException;
//import java.io.PrintWriter;
//
//public class ManageOrdersServlet extends HttpServlet {
//    
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        response.setContentType("text/html;charset=UTF-8");
//        PrintWriter out = response.getWriter();
//        
//        out.println("<!DOCTYPE html>");
//        out.println("<html>");
//        out.println("<head>");
//        out.println("<meta charset='UTF-8'>");
//        out.println("<title>Pizza Order Manager</title>");
//        out.println("<style>");
//        out.println("body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }");
//        out.println(".container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
//        out.println(".header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }");
//        out.println(".logo { width: 60px; height: 60px; background: #ff6b6b; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 30px; color: white; }");
//        out.println(".title h1 { margin: 0; color: #333; }");
//        out.println(".title p { margin: 5px 0 0 0; color: #666; }");
//        out.println(".btn-add { background: #ff6b6b; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: 600; }");
//        out.println(".stats { display: flex; gap: 20px; margin-bottom: 30px; }");
//        out.println(".stat-card { background: white; padding: 20px; border-radius: 10px; text-align: center; flex: 1; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }");
//        out.println(".stat-value { font-size: 2em; font-weight: bold; margin-top: 10px; }");
//        out.println(".stat-card.completed .stat-value { color: #4caf50; }");
//        out.println(".stat-card.revenue .stat-value { color: #ff6b6b; }");
//        out.println("table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
//        out.println("th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }");
//        out.println("th { background: #f8f9fa; font-weight: 600; }");
//        out.println(".status-badge { padding: 5px 10px; border-radius: 15px; font-size: 0.8em; font-weight: 600; }");
//        out.println(".status-pending { background: #f39c12; color: white; }");
//        out.println(".status-completed { background: #27ae60; color: white; }");
//        out.println(".actions { display: flex; gap: 5px; }");
//        out.println(".btn { padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 14px; }");
//        out.println(".btn-info { background: #3498db; color: white; }");
//        out.println(".btn-danger { background: #e74c3c; color: white; }");
//        out.println("</style>");
//        out.println("</head>");
//        out.println("<body>");
//        out.println("<div class='container'>");
//        out.println("<div class='header'>");
//        out.println("<div style='display: flex; align-items: center; gap: 20px;'>");
//        out.println("<div class='logo'>PIZZA</div>");
//        out.println("<div class='title'>");
//        out.println("<h1>Pizza Order Manager</h1>");
//        out.println("<p>Quan ly don hang pizza</p>");
//        out.println("</div>");
//        out.println("</div>");
//        out.println("<a href='OrderController?action=new' class='btn-add'>+ Them don hang</a>");
//        out.println("</div>");
//        
//        out.println("<div class='stats'>");
//        out.println("<div class='stat-card'>");
//        out.println("<div>Tong don hang</div>");
//        out.println("<div class='stat-value'>2</div>");
//        out.println("</div>");
//        out.println("<div class='stat-card completed'>");
//        out.println("<div>Don hoan thanh</div>");
//        out.println("<div class='stat-value'>1</div>");
//        out.println("</div>");
//        out.println("<div class='stat-card revenue'>");
//        out.println("<div>Doanh thu</div>");
//        out.println("<div class='stat-value'>250.000VND</div>");
//        out.println("</div>");
//        out.println("</div>");
//        
//        out.println("<table>");
//        out.println("<thead>");
//        out.println("<tr>");
//        out.println("<th>ID</th>");
//        out.println("<th>Khach hang</th>");
//        out.println("<th>Loai pizza</th>");
//        out.println("<th>So luong</th>");
//        out.println("<th>Gia (VND)</th>");
//        out.println("<th>Tong tien</th>");
//        out.println("<th>Trang thai</th>");
//        out.println("<th>Thao tac</th>");
//        out.println("</tr>");
//        out.println("</thead>");
//        out.println("<tbody>");
//        out.println("<tr>");
//        out.println("<td><strong>#1</strong></td>");
//        out.println("<td>Nguyen Van A</td>");
//        out.println("<td>Pepperoni</td>");
//        out.println("<td>2</td>");
//        out.println("<td>400.000</td>");
//        out.println("<td><strong>800.000VND</strong></td>");
//        out.println("<td><span class='status-badge status-pending'>Cho xu ly</span></td>");
//        out.println("<td>");
//        out.println("<div class='actions'>");
//        out.println("<a href='#' class='btn btn-info'>Edit</a>");
//        out.println("<a href='#' class='btn btn-danger'>Delete</a>");
//        out.println("</div>");
//        out.println("</td>");
//        out.println("</tr>");
//        out.println("<tr>");
//        out.println("<td><strong>#2</strong></td>");
//        out.println("<td>Tran Thi B</td>");
//        out.println("<td>Hawaiian</td>");
//        out.println("<td>1</td>");
//        out.println("<td>250.000</td>");
//        out.println("<td><strong>250.000VND</strong></td>");
//        out.println("<td><span class='status-badge status-completed'>Hoan thanh</span></td>");
//        out.println("<td>");
//        out.println("<div class='actions'>");
//        out.println("<a href='#' class='btn btn-info'>Edit</a>");
//        out.println("<a href='#' class='btn btn-danger'>Delete</a>");
//        out.println("</div>");
//        out.println("</td>");
//        out.println("</tr>");
//        out.println("</tbody>");
//        out.println("</table>");
//        out.println("</div>");
//        out.println("</body>");
//        out.println("</html>");
//    }
//}