package com.example;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

/**
 * Enhedstests til CI/CD-demonstration.
 */
public class AppTest {

    @Test
    public void testGetGreeting() {
        assertEquals("Hello from CI/CD!", App.getGreeting());
    }

    @Test
    public void testAdd() {
        assertEquals(5, App.add(2, 3));
        assertEquals(0, App.add(-1, 1));
    }
}
