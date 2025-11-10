package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.User;

@WebFilter("/*")
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        
        String path = req.getRequestURI();
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        // Admin-only pages (Role 1)
        if (isAdminOnlyPage(path)) {
            if (user == null || user.getRole() != 1) {
                resp.sendRedirect(req.getContextPath() + "/login?error=access_denied");
                return;
            }
        }
        
        // Waiter-only pages (Role 2 ONLY - Admin cannot access)
        if (isWaiterOnlyPage(path)) {
            if (user == null || user.getRole() != 2) {
                resp.sendRedirect(req.getContextPath() + "/login?error=access_denied");
                return;
            }
        }
        
        chain.doFilter(request, response);
    }
    
    private boolean isAdminOnlyPage(String path) {
        // Admin-only: Manage users, products, discount, dashboard, inventory
        return path.contains("/admin") ||
               path.contains("/adduser") ||
               path.contains("/edituser") ||
               path.contains("/manageproduct") ||
               path.contains("/AddProductServlet") ||
               path.contains("/EditProductFullServlet") ||
               path.contains("/DeleteProduct") ||
               path.contains("/discount") ||
               path.contains("/dashboard") ||
               path.contains("/inventory");
    }
    
    private boolean isWaiterOnlyPage(String path) {
        // Waiter-only (Role 2): POS, Order Management, Assign Table, Waiter Monitor, Waiter Dashboard
        // Admin (Role 1) CANNOT access these pages
        return path.contains("/pos") ||
               path.contains("/manage-orders") ||
               path.contains("/assign-table") ||
               path.contains("/waiter-monitor") ||
               path.contains("/WaiterMonitor") ||
               path.contains("/waiter-dashboard");
    }
}
