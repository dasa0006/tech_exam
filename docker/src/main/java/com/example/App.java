package com.example;

/**
 * Simpel demo-applikation til Docker-eksamen.
 * Printer et HTTP-svar på port 8080 for at simulere en webapp.
 */
public class App {
    public static void main(String[] args) throws Exception {
        System.out.println("========================================");
        System.out.println("  Docker Demo App started on port 8080");
        System.out.println("========================================");

        // Simpel HTTP-server på port 8080
        try (var server = new java.net.ServerSocket(8080)) {
            while (true) {
                var client = server.accept();
                var writer = new java.io.PrintWriter(client.getOutputStream());
                writer.println("HTTP/1.1 200 OK");
                writer.println("Content-Type: text/html");
                writer.println();
                writer.println("<h1> Docker Demo App </h1>");
                writer.println("<p>Container kører! Image bygget med multi-stage build.</p>");
                writer.println("<p>Host: " + java.net.InetAddress.getLocalHost().getHostName() + "</p>");
                writer.flush();
                client.close();
            }
        }
    }
}
