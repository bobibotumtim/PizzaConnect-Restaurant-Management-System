package dao;

import models.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO extends DBContext {

    public boolean createPayment(Payment payment) {
        // SỬA LỖI: Số lượng parameter không khớp (5 thay vì 7)
        String sql = "INSERT INTO Payment (OrderID, Amount, PaymentStatus, PaymentDate, QRCodeURL) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, payment.getOrderID());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getPaymentStatus());
            ps.setTimestamp(4, new Timestamp(payment.getPaymentDate().getTime()));
            ps.setString(5, payment.getQrCodeURL());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setPaymentID(rs.getInt(1));
                        System.out.println("✅ Payment created with ID: " + payment.getPaymentID());
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error creating payment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public Payment getPaymentByOrderId(int orderId) {
        String sql = "SELECT * FROM Payment WHERE OrderID = ? ORDER BY PaymentDate DESC";
        Payment payment = null;

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    payment = mapResultSetToPayment(rs);
                    System.out.println(
                            "✅ Found payment for Order #" + orderId + ": Payment ID=" + payment.getPaymentID());
                } else {
                    System.out.println("⚠️ No payment found for Order #" + orderId);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting payment by OrderID: " + e.getMessage());
            e.printStackTrace();
        }
        return payment;
    }

    public boolean updatePaymentStatus(int paymentId, String status) {
        String sql = "UPDATE Payment SET PaymentStatus = ? WHERE PaymentID = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, paymentId);

            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Payment status updated. Rows affected: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePayment(Payment payment) {
        String sql = "UPDATE Payment SET Amount = ?, PaymentStatus = ?, " +
                "PaymentDate = ?, QRCodeURL = ? WHERE PaymentID = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDouble(1, payment.getAmount());
            ps.setString(2, payment.getPaymentStatus());
            ps.setTimestamp(3, new Timestamp(payment.getPaymentDate().getTime()));
            ps.setString(4, payment.getQrCodeURL());
            ps.setInt(5, payment.getPaymentID());

            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Payment updated. Rows affected: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error updating payment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Payment> getPendingPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM Payment WHERE PaymentStatus = 'Pending' ORDER BY PaymentDate DESC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                payments.add(mapResultSetToPayment(rs));
            }
            System.out.println("✅ Found " + payments.size() + " pending payments");
        } catch (SQLException e) {
            System.err.println("❌ Error getting pending payments: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    public List<Payment> getPaymentsByDateRange(Date startDate, Date endDate) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM Payment WHERE PaymentDate BETWEEN ? AND ? ORDER BY PaymentDate DESC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, new Timestamp(startDate.getTime()));
            ps.setTimestamp(2, new Timestamp(endDate.getTime()));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
            System.out.println("✅ Found " + payments.size() + " payments in date range");
        } catch (SQLException e) {
            System.err.println("❌ Error getting payments by date range: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    public double getTotalRevenueByDateRange(Date startDate, Date endDate) {
        String sql = "SELECT SUM(Amount) as TotalRevenue FROM Payment WHERE PaymentStatus = 'Completed' AND PaymentDate BETWEEN ? AND ?";
        double totalRevenue = 0.0;

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, new Timestamp(startDate.getTime()));
            ps.setTimestamp(2, new Timestamp(endDate.getTime()));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalRevenue = rs.getDouble("TotalRevenue");
                }
            }
            System.out.println("✅ Total revenue: " + totalRevenue);
        } catch (SQLException e) {
            System.err.println("❌ Error getting total revenue: " + e.getMessage());
            e.printStackTrace();
        }
        return totalRevenue;
    }

    public boolean deletePayment(int paymentId) {
        String sql = "DELETE FROM Payment WHERE PaymentID = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, paymentId);

            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Payment deleted. Rows affected: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting payment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentID(rs.getInt("PaymentID"));
        payment.setOrderID(rs.getInt("OrderID"));
        payment.setAmount(rs.getDouble("Amount"));
        payment.setPaymentStatus(rs.getString("PaymentStatus"));
        payment.setPaymentDate(rs.getTimestamp("PaymentDate"));
        payment.setQrCodeURL(rs.getString("QRCodeURL"));
        return payment;
    }
}