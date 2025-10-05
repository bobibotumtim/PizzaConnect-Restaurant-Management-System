package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class TestConnection {
    public static void main(String[] args) {
        // Kết nối SQL Server
        String url = "jdbc:sqlserver://localhost:1433;databaseName=pizza_demo_DB;encrypt=false";
        String user = "sa"; // hoặc user bạn tạo
        String password = "123"; // thay bằng mật khẩu bạn đặt

        try {
            // Load driver SQL Server
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Tạo kết nối
            Connection conn = DriverManager.getConnection(url, user, password);

            if (conn != null) {
            System.out.println("Ket noi SQL Server thanh cong!");
            conn.close();
        }
    } catch (Exception e) {
        System.out.println("Ket noi that bai!");
            e.printStackTrace();
        }
    }
}
