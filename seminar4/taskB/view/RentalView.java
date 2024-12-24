package view;

import controller.RentalController;
import integration.InstrumentDAO;

import java.util.Scanner;

public class RentalView {
    public static void main(String[] args) {
        InstrumentDAO dao = new InstrumentDAO();
        RentalController rentalController = new RentalController(dao);
        Scanner scanner = new Scanner(System.in);

        try {
            System.out.println("What would you like to do?");
            System.out.println("1. Rent an instrument");
            System.out.println("2. End a rental");
            System.out.println("3. List of instruments");
            int choice = scanner.nextInt();

            switch (choice) {
                case 1:
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

                    rentalController.rentInstrument(studentId, instrumentId, startDateStr, endDateStr, quantity);
                    break;

                case 2:
                    System.out.print("Enter rental ID to end: ");
                    int rentalId = scanner.nextInt();
                    rentalController.endRental(rentalId);
                    break;

                case 3:
                    System.out.print("Enter instrument type: ");
                    int instrumentType = scanner.nextInt();
                    dao.listAvailableInstruments(instrumentType);
                    break;

                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        } finally {
            scanner.close();
        }
    }
}
