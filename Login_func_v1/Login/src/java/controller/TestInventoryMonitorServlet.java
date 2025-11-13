package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class TestInventoryMonitorServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Test Inventory Monitor</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Test Inventory Monitor Servlet Works!</h1>");
        out.println("<p>This is a test servlet to verify the mapping is working.</p>");
        out.println("</body>");
        out.println("</html>");
    }
}