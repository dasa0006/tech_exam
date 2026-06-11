package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit-test for demo-applikationen.
 */
public class AppTest {

    @Test
    public void testAppName() {
        String name = App.class.getSimpleName();
        assertEquals("App", name, "Klassenavnet skal være App");
    }

    @Test
    public void testPackageName() {
        String pkg = App.class.getPackageName();
        assertEquals("com.example", pkg, "Pakkenavnet skal være com.example");
    }
}
