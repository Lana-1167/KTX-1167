import java.sql.*;
import java.util.Scanner;

public class RentalSystem {

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "lana_lana67";

    private Connection conn;
    private PreparedStatement listAvailableStmt;
    private PreparedStatement checkLimitStmt;
    private PreparedStatement rentStmt;
    private PreparedStatement endRentalStmt;

    public RentalSystem() {
        try {
            // Установление соединения с базой данных
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false); // Устанавливаем AutoCommit на false один раз
            prepareStatements();
        } catch (SQLException e) {
            e.printStackTrace();
            closeConnection();
        }
    }

    private void prepareStatements() throws SQLException {
        // Подготовка запросов один раз при запуске программы
        String listAvailableQuery = "SELECT i.instrument_id, i.brand_id, c.cost, p.price_service " +
                "FROM mus_instruments i " +
                "JOIN conditions c ON i.instrument_id = c.instrument_id " +
                "JOIN price p ON p.price_id = 1 " +
                "WHERE p.price_start <= CURRENT_DATE " +
                "AND p.price_finish >= CURRENT_DATE " +
                "AND i.type_id = ? " +
                "AND NOT EXISTS (" +
                "    SELECT 1 " +
                "    FROM renting_instruments r " +
                "    WHERE r.instrum_id = i.instrument_id " +
                "    AND r.period_end >= CURRENT_DATE " +
                "    AND r.period_start <= CURRENT_DATE" +
                ")";
        listAvailableStmt = conn.prepareStatement(listAvailableQuery);

        String checkLimitQuery = "SELECT renting_id FROM renting_instruments " +
                "WHERE student_numb = ? AND period_end >= CURRENT_DATE FOR UPDATE";
        checkLimitStmt = conn.prepareStatement(checkLimitQuery);

        String rentQuery = "INSERT INTO renting_instruments (student_numb, instrum_id, period_start, period_end, quantity_instruments, price_id) "
                +
                "VALUES (?, ?, ?, ?, 1, (SELECT price_id FROM price WHERE price_id = 1 AND price_start <= CURRENT_DATE AND price_finish >= CURRENT_DATE))";
        rentStmt = conn.prepareStatement(rentQuery);

        String endRentalQuery = "UPDATE renting_instruments SET period_end = CURRENT_DATE WHERE renting_id = ?";
        endRentalStmt = conn.prepareStatement(endRentalQuery);
    }

    public void listAvailableInstruments(String instrumentType) {
        try {
            listAvailableStmt.setInt(1, Integer.parseInt(instrumentType));
            ResultSet rs = listAvailableStmt.executeQuery();

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

    public void rentInstrument(int studentId, int instrumentId, String periodStart, String periodEnd) {
        try {
            // Проверка лимита с использованием FOR UPDATE
            checkLimitStmt.setInt(1, studentId);
            ResultSet rs = checkLimitStmt.executeQuery();

            int rentedCount = 0;
            while (rs.next()) {
                rentedCount++;
            }

            if (rentedCount >= 2) {
                System.out.println("Student has already rented the maximum allowed number of instruments.");
                return;
            }

            // Выполнение операции аренды
            rentStmt.setInt(1, studentId);
            rentStmt.setInt(2, instrumentId);
            rentStmt.setDate(3, Date.valueOf(periodStart));
            rentStmt.setDate(4, Date.valueOf(periodEnd));
            try {
                rentStmt.executeUpdate();
                conn.commit(); // Фиксация транзакции
                System.out.println("Instrument rented successfully.");
            } catch (SQLException e) {
                if (e.getSQLState().equals("23505")) { // Проверка на нарушение уникальности
                    System.out.println(
                            "Error: Renting ID already exists. Please enter a new renting ID or end the rental.");
                } else {
                    throw e; // Прокидываем остальные ошибки
                }
            }

        } catch (SQLException e) {
            try {
                conn.rollback(); // Откат в случае ошибки
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
    }

    public void endRental(int rentingId) {
        try {
            endRentalStmt.setInt(1, rentingId);
            endRentalStmt.executeUpdate();
            conn.commit(); // Фиксация транзакции
            System.out.println("Rental ended successfully.");
        } catch (SQLException e) {
            try {
                conn.rollback(); // Откат транзакции
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
    }

    private void closeConnection() {
        try {
            if (conn != null && !conn.isClosed())
                conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        RentalSystem system = new RentalSystem();
        Scanner scanner = new Scanner(System.in);

        try {
            // Предложение пользователю выбрать действие
            System.out.println("What would you like to do?");
            System.out.println("1. Rent an instrument");
            System.out.println("2. End a rental");
            int choice = scanner.nextInt();

            if (choice == 1) {
                // Процесс аренды
                System.out.println("Enter instrument type to list available instruments:");
                scanner.nextLine(); // Поглощаем остаточный символ новой строки
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

            } else if (choice == 2) {
                // Процесс завершения аренды
                System.out.println("Enter rental ID to end rental:");
                int rentingId = scanner.nextInt();
                system.endRental(rentingId);

            } else {
                System.out.println("Invalid choice. Please select 1 or 2.");
            }

        } finally {
            scanner.close(); // Закрытие ресурса Scanner
            system.closeConnection(); // Закрытие соединения с базой данных
        }
    }

}
