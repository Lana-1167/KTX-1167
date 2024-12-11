import java.sql.*;
import java.util.Scanner;

public class RentalSystem {

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "lana_lana67";

    // JDBC connection
    private Connection connect() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    // List all available instruments for rent
   public void listAvailableInstruments(String instrumentType) {
    String query = "SELECT i.instrument_id, i.brand_id, c.cost, p.price_service " +
                   "FROM mus_instruments i " +
                   "JOIN conditions c ON i.instrument_id = c.instrument_id " +  // Связь с таблицей conditions для получения стоимости инструмента
                   "JOIN price p ON p.price_id = 1 " +  // Условие для выбора аренды с price_id = 1
                   "WHERE p.price_start <= CURRENT_DATE " +
                   "AND p.price_finish >= CURRENT_DATE " +
                   "AND i.type_id = ? " +  // Условие для типа инструмента
                   "AND NOT EXISTS (" +
                   "    SELECT 1 " +
                   "    FROM renting_instruments r " +
                   "    WHERE r.instrum_id = i.instrument_id " +
                   "    AND r.period_end >= CURRENT_DATE " +
                   "    AND r.period_start <= CURRENT_DATE" +
                   ")";
        
    try (Connection conn = connect();
         PreparedStatement stmt = conn.prepareStatement(query)) {
       stmt.setInt(1, Integer.parseInt(instrumentType)); 
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int instrumentId = rs.getInt("instrument_id");
            String brand = rs.getString("brand_id");
            double price = rs.getDouble("price_service");
            System.out.println("Instrument ID: " + instrumentId + ", Brand: " + brand + ", Price: " + price);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
}


    // Rent an instrument
    public void rentInstrument(int studentId, int instrumentId, String periodStart, String periodEnd) {
        String checkLimitQuery = "SELECT COUNT(*) FROM renting_instruments WHERE student_numb = ? AND period_end >= CURRENT_DATE";

String rentQuery = "INSERT INTO renting_instruments (student_numb, instrum_id, period_start, period_end, quantity_instruments, price_id) " +
                           "VALUES (?, ?, ?, ?, 1, (SELECT price_id FROM price WHERE price_id = 1 AND price_start <= CURRENT_DATE AND price_finish >= CURRENT_DATE))";
        

        String updateQuery = "UPDATE renting_instruments SET period_end = ? WHERE renting_id = ?";
        
        try (Connection conn = connect()) {
            conn.setAutoCommit(false); // Disable auto-commit to manage the transaction manually

            // Check if the student has already rented two instruments
            try (PreparedStatement stmt = conn.prepareStatement(checkLimitQuery)) {
                stmt.setInt(1, studentId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next() && rs.getInt(1) >= 2) {
                    System.out.println("Student has already rented the maximum allowed number of instruments.");
                    return;
                }
            }

            // Proceed with the rent operation
            try (PreparedStatement stmt = conn.prepareStatement(rentQuery)) {
                stmt.setInt(1, studentId);
                stmt.setInt(2, instrumentId);
                stmt.setDate(3, Date.valueOf(periodStart));
                stmt.setDate(4, Date.valueOf(periodEnd));
                stmt.executeUpdate();
                conn.commit(); // Commit the transaction
                System.out.println("Instrument rented successfully.");
            } catch (SQLException e) {
                conn.rollback(); // Rollback in case of an error
                e.printStackTrace();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // End rental
    public void endRental(int rentingId) {
        String updateQuery = "UPDATE renting_instruments SET period_end = CURRENT_DATE WHERE renting_id = ?";
        
        try (Connection conn = connect()) {
            conn.setAutoCommit(false); // Disable auto-commit

            try (PreparedStatement stmt = conn.prepareStatement(updateQuery)) {
                stmt.setInt(1, rentingId);
                stmt.executeUpdate();
                conn.commit(); // Commit the transaction
                System.out.println("Rental ended successfully.");
            } catch (SQLException e) {
                conn.rollback(); // Rollback in case of an error
                e.printStackTrace();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        RentalSystem system = new RentalSystem();
        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter instrument type to list available instruments:");
        String instrumentType = scanner.nextLine();
        system.listAvailableInstruments(instrumentType);

        System.out.println("Enter student ID to rent an instrument:");
        int studentId = scanner.nextInt();
        System.out.println("Enter instrument ID to rent:");
        int instrumentId = scanner.nextInt();
        System.out.println("Enter rental start date (yyyy-mm-dd):");
        String startDate = scanner.next();
        System.out.println("Enter rental end date (yyyy-mm-dd):");
        String endDate = scanner.next();
        system.rentInstrument(studentId, instrumentId, startDate, endDate);

        System.out.println("Enter rental ID to end rental:");
        int rentingId = scanner.nextInt();
        system.endRental(rentingId);
    }
}
