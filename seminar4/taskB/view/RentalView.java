package view;

import controller.RentalController;
import integration.InstrumentDAO;

import java.util.Scanner;

public class RentalView {
    public static void main(String[] args) {
        InstrumentDAO dao = new InstrumentDAO();
        RentalController rentalController = new RentalController(dao);

        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter student ID: ");
        int studentId = scanner.nextInt();

        System.out.print("Enter instrument ID: ");
        int instrumentId = scanner.nextInt();

        System.out.print("Enter rental start date (YYYY-MM-DD): ");
        String startDateStr = scanner.next();

        System.out.print("Enter rental end date (YYYY-MM-DD): ");
        String endDateStr = scanner.next();

        System.out.print("Enter quantity of instruments: ");
        int quantity = scanner.nextInt();

        try {
            rentalController.rentInstrument(studentId, instrumentId, startDateStr, endDateStr, quantity);
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
