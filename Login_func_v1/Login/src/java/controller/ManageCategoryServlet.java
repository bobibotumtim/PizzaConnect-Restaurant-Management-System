package controller;

import dao.CategoryDAO;
import models.Category;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/managecategory")
public class ManageCategoryServlet extends HttpServlet {
    private CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String search = request.getParameter("searchName");

        if (action == null) action = "";

        switch (action) {
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                Category category = categoryDAO.getCategoryById(id);
                request.setAttribute("editCategory", category);
                break;
            case "delete":
                int deleteId = Integer.parseInt(request.getParameter("id"));
                categoryDAO.deleteCategory(deleteId);
                response.sendRedirect("managecategory?message=deleted");
                return;
        }

        List<Category> list;
        if (search != null && !search.trim().isEmpty()) {
            list = categoryDAO.getAllCategories().stream()
                    .filter(c -> c.getCategoryName().toLowerCase().contains(search.toLowerCase()))
                    .toList();
        } else {
            list = categoryDAO.getAllCategories();
        }

        request.setAttribute("categories", list);
        request.getRequestDispatcher("/view/ManageCategory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("categoryId");
        String name = request.getParameter("categoryName");
        String desc = request.getParameter("description");

        HttpSession session = request.getSession();
        
        //Add
        if (idStr == null || idStr.isEmpty()) {
            // Add new category - Validate
            try {
                if (categoryDAO.isCategoryNameExists(name, null)) {
                    session.setAttribute("message", "Category name already exists");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("managecategory");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            Category c = new Category(name, desc);
            boolean success = categoryDAO.addCategory(c);
            
            if (success) {
                session.setAttribute("message", "Category added successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Error adding category.");
                session.setAttribute("messageType", "error");
            }
        //Update
        } else {
            // Update existing category - Validate
            int id = Integer.parseInt(idStr);
            
            Category existing = categoryDAO.getCategoryById(id);
            if (existing == null) {
                session.setAttribute("message", "Category not found");
                session.setAttribute("messageType", "error");
                response.sendRedirect("managecategory");
                return;
            }
            
            try {
                if (categoryDAO.isCategoryNameExists(name, id)) {
                    session.setAttribute("message", "Category name already exists");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("managecategory");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            Category c = new Category(id, name, desc);
            boolean success = categoryDAO.updateCategory(c);
            
            if (success) {
                session.setAttribute("message", "Category updated successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Error updating category.");
                session.setAttribute("messageType", "error");
            }
        }
        
        response.sendRedirect("managecategory");
    }
}
