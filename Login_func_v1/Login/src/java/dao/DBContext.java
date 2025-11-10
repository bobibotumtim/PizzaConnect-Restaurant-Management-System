package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    private static final String USER = "duongbui";
    private static final String PASSWORD = "123";
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=pizza_demo_DB_FinalModel;encrypt=true;trustServerCertificate=true";

    // Load the SQL Server JDBC driver
    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Failed to load SQL Server JDBC Driver", ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    // Get a connection to the database
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Utility method to close connection
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                Logger.getLogger(DBContext.class.getName()).log(Level.WARNING, "Error closing connection", e);
            }
        }
    }
}