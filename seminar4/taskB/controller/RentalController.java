package controller;

import integration.InstrumentDAO;
import java.sql.Date;

public class RentalController {
    private final InstrumentDAO instrumentDAO;

    public RentalController(InstrumentDAO instrumentDAO) {
        this.instrumentDAO = instrumentDAO;
    }

    public void rentInstrument(int studentId, int instrumentId, String startDateStr, String endDateStr, int quantity) {
        try {
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);

            // Проверка лимитов для инструмента
            if (instrumentDAO.getCurrentRentalsForInstrument(instrumentId).size() >= 2) {
                throw new IllegalArgumentException("This instrument has reached its rental limit.");
            }

            // Проверка лимитов для студента
            int activeRentals = instrumentDAO.getActiveRentalCountForStudent(studentId);
            if (activeRentals >= 2) { // Лимит активных аренд — 2
                throw new IllegalArgumentException("Student has reached the rental limit.");
            }

            // Создание аренды
            instrumentDAO.createRental(studentId, instrumentId, startDate, endDate, quantity);
            System.out.println("Rental created successfully.");
        } catch (Exception e) {
            throw new RuntimeException("Error creating rental: " + e.getMessage());
        }
    }
}
