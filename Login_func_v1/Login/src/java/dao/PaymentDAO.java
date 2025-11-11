package dao;

import models.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO extends DBContext{

    public boolean createPayment(Payment payment) {
        String sql = "INSERT INTO Payment (OrderID, PaymentMethod, Amount, PaymentStatus, PaymentDate, " +
                "TransactionID, QRCodeURL) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, payment.getOrderID());
            ps.setString(2, payment.getPaymentMethod());
            ps.setDouble(3, payment.getAmount());
            ps.setString(4, payment.getPaymentStatus());
            ps.setTimestamp(5, new Timestamp(payment.getPaymentDate().getTime()));
            ps.setString(6, payment.getTransactionID());
            ps.setString(7, payment.getQrCodeURL());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setPaymentID(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
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
                }
            }
        } catch (SQLException e) {
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

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePayment(Payment payment) {
        String sql = "UPDATE Payment SET PaymentMethod = ?, Amount = ?, PaymentStatus = ?, " +
                "TransactionID = ?, QRCodeURL = ? WHERE PaymentID = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, payment.getPaymentMethod());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getPaymentStatus());
            ps.setString(4, payment.getTransactionID());
            ps.setString(5, payment.getQrCodeURL());
            ps.setInt(6, payment.getPaymentID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }

    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentID(rs.getInt("PaymentID"));
        payment.setOrderID(rs.getInt("OrderID"));
        payment.setPaymentMethod(rs.getString("PaymentMethod"));
        payment.setAmount(rs.getDouble("Amount"));
        payment.setPaymentStatus(rs.getString("PaymentStatus"));
        payment.setPaymentDate(rs.getTimestamp("PaymentDate"));
        payment.setTransactionID(rs.getString("TransactionID"));
        payment.setQrCodeURL(rs.getString("QRCodeURL"));
        return payment;
    }
}