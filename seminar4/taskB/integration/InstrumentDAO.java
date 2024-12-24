package integration;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstrumentDAO {
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "lana_lana67";

    private Connection conn;
    private PreparedStatement listAvailableStmt;
    private PreparedStatement getActiveRentalCountStmt;
    private PreparedStatement createRentalStmt;
    private PreparedStatement endRentalStmt;

    public InstrumentDAO() {
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false); // Disable auto-commit once
            prepareStatements();
        } catch (SQLException e) {
            throw new RuntimeException("Error initializing database connection: " + e.getMessage());
        }
    }

    private void prepareStatements() throws SQLException {
        String listAvailableQuery = "SELECT mi.instrument_id, ti.types_instrum, mi.brand_id, c.cost " +
                "FROM mus_instruments mi " +
                "JOIN conditions c ON mi.instrument_id = c.instrument_id " +
                "JOIN types_instruments ti ON mi.type_id = ti.type_id " +
                "WHERE mi.type_id = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 FROM renting_instruments ri " +
                "    WHERE ri.instrum_id = mi.instrument_id AND ri.period_end >= CURRENT_DATE)";
        listAvailableStmt = conn.prepareStatement(listAvailableQuery);

        String getActiveRentalCountQuery = "SELECT COUNT(*) AS rental_count FROM renting_instruments " +
                "WHERE student_numb = ? AND period_end >= CURRENT_DATE";
        getActiveRentalCountStmt = conn.prepareStatement(getActiveRentalCountQuery);

        String createRentalQuery = "INSERT INTO renting_instruments " +
                "(student_numb, instrum_id, period_start, period_end, quantity_instruments, price_id) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        createRentalStmt = conn.prepareStatement(createRentalQuery);

        String endRentalQuery = "UPDATE renting_instruments SET period_end = CURRENT_DATE WHERE renting_id = ?";
        endRentalStmt = conn.prepareStatement(endRentalQuery);
    }

    public void listAvailableInstruments(int instrumentType) {
        try {
            listAvailableStmt.setInt(1, instrumentType);
            ResultSet rs = listAvailableStmt.executeQuery();

            System.out.println("Available instruments:");
            boolean found = false;
            while (rs.next()) {
                found = true;
                int instrumentId = rs.getInt("instrument_id");
                String type = rs.getString("types_instrum");
                String brand = rs.getString("brand_id");
                double price = rs.getDouble("cost");
                System.out.println("Instrument ID: " + instrumentId + ", Type: " + type + ", Brand: " + brand
                        + ", Price: " + price);
            }
            if (!found) {
                System.out.println("No available instruments found for this type.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error listing available instruments: " + e.getMessage());
        }
    }

    public void endRental(int rentingId) {
        try {
            // Ensure the rental exists before attempting to end it
            String checkQuery = "SELECT renting_id, period_end FROM renting_instruments WHERE renting_id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                checkStmt.setInt(1, rentingId);
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    throw new RuntimeException("Rental with ID " + rentingId + " not found.");
                }
            }

            // Proceed with the rental end update
            endRentalStmt.setInt(1, rentingId);
            int rowsAffected = endRentalStmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Rental with ID " + rentingId + " has been successfully ended.");
            } else {
                System.out.println("No rental found with ID " + rentingId + ".");
            }

            // Commit the transaction
            conn.commit();
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            throw new RuntimeException("Error ending rental: " + e.getMessage());
        }
    }

    public int getActiveRentalCountForStudent(int studentId) {
        try {
            // Ensure the rentals considered are still active (i.e., not ended)
            getActiveRentalCountStmt.setInt(1, studentId);
            ResultSet rs = getActiveRentalCountStmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("rental_count");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error retrieving active rental count: " + e.getMessage());
        }
        return 0;
    }

    public void createRental(int studentId, int instrumentId, Date startDate, Date endDate, int quantity) {
        try {
            // Get the active rental count for the student (exclude rentals that have
            // already ended)
            int activeRentals = getActiveRentalCountForStudent(studentId);
            if (activeRentals >= 2) {
                throw new IllegalArgumentException(
                        "Student has already rented the maximum allowed number of instruments (" + activeRentals
                                + ").");
            }

            // Proceed to create the rental
            createRentalStmt.setInt(1, studentId);
            createRentalStmt.setInt(2, instrumentId);
            createRentalStmt.setDate(3, startDate);
            createRentalStmt.setDate(4, endDate);
            createRentalStmt.setInt(5, quantity);
            createRentalStmt.setInt(6, getValidPriceId(instrumentId));
            createRentalStmt.executeUpdate();
            conn.commit();
            System.out.println("Rental created successfully.");
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            throw new RuntimeException("Error creating rental: " + e.getMessage());
        }
    }

    private int getValidPriceId(int instrumentId) {
        String query = "SELECT price_id FROM price WHERE type_service = 'Rent instruments' " +
                "AND price_start <= CURRENT_DATE AND price_finish >= CURRENT_DATE";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("price_id");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error retrieving price ID: " + e.getMessage());
        }
        throw new RuntimeException("No valid price ID found.");
    }

    public List<Integer> getCurrentRentalsForInstrument(int instrumentId) {
        List<Integer> rentals = new ArrayList<>();
        String query = "SELECT renting_id FROM renting_instruments WHERE instrum_id = ? AND period_end >= CURRENT_DATE";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, instrumentId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                rentals.add(rs.getInt("renting_id"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error retrieving current rentals for instrument: " + e.getMessage());
        }
        return rentals;
    }

}
