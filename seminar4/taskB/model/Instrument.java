package model;

public class Instrument {
    private int id;
    private String brand;
    private double price;

    public Instrument(int id, String brand, double price) {
        this.id = id;
        this.brand = brand;
        this.price = price;
    }

    public int getId() {
        return id;
    }

    public String getBrand() {
        return brand;
    }

    public double getPrice() {
        return price;
    }

    @Override
    public String toString() {
        return "Instrument ID: " + id + ", Brand: " + brand + ", Price: " + price;
    }
}
