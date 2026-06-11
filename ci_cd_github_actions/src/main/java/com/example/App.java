package com.example;

/**
 * Simpel applikation til CI/CD-demonstration.
 */
public class App {

    public static String getGreeting() {
        return "Hello from CI/CD!";
    }

    public static int add(int a, int b) {
        return a + b;
    }

    public static void main(String[] args) {
        System.out.println(getGreeting());
    }
}
