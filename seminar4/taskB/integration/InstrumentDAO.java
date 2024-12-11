package integration;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstrumentDAO {
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "lana_lana67";

    private Connection connect() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    // Возвращаем фиксированный price_id = 1
    public int getPriceIdForInstrument(int instrumentId) {
        return 1; // Цена на аренду всегда фиксирована для всех инструментов
    }

    public List<Integer> getCurrentRentalsForInstrument(int instrumentId) {
        String query = "SELECT renting_id FROM renting_instruments " +
                "WHERE instrum_id = ? AND period_end >= CURRENT_DATE";
        List<Integer> rentals = new ArrayList<>();

        try (Connection conn = connect();
                PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, instrumentId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                rentals.add(rs.getInt("renting_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rentals;
    }

    public int getActiveRentalCountForStudent(int studentId) {
        String query = "SELECT COUNT(*) AS rental_count FROM renting_instruments " +
                "WHERE student_numb = ? AND period_end >= CURRENT_DATE";
        int rentalCount = 0;

        try (Connection conn = connect();
                PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, studentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                rentalCount = rs.getInt("rental_count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rentalCount;
    }

    public void createRental(int studentId, int instrumentId, Date startDate, Date endDate, int quantity) {
        String query = "INSERT INTO renting_instruments (student_numb, instrum_id, period_start, period_end, quantity_instruments, price_id) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        int priceId = getPriceIdForInstrument(instrumentId); // Всегда возвращает 1

        try (Connection conn = connect();
                PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, studentId);
            stmt.setInt(2, instrumentId);
            stmt.setDate(3, startDate);
            stmt.setDate(4, endDate);
            stmt.setInt(5, quantity);
            stmt.setInt(6, priceId); // Передаем price_id = 1
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Database error: " + e.getMessage());
        }
    }
}
