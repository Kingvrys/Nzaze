package com.nzaze.util; // Adjust package name to match your folder structure if needed

import java.security.SecureRandom;

public class CredentialGenerator {

    private static final String ALPHA_NUMERIC = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
    private static final String DIGITS = "0123456789";
    private static final SecureRandom random = new SecureRandom();

    /**
     * Generates a username based on first and last name (e.g., "john.doe").
     */
    public static String generateUsername(String firstName, String lastName) {
        String cleanFirst = firstName.trim().toLowerCase().replaceAll("[^a-z0-9]", "");
        String cleanLast = lastName.trim().toLowerCase().replaceAll("[^a-z0-9]", "");
        return cleanFirst + "." + cleanLast;
    }

    /**
     * Generates a random temporary password (8 characters).
     */
    public static String generateTemporaryPassword() {
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(ALPHA_NUMERIC.charAt(random.nextInt(ALPHA_NUMERIC.length())));
        }
        return sb.toString();
    }

    /**
     * Generates a 6-digit room access code (e.g., "849201").
     */
    public static String generateAccessCode() {
        StringBuilder sb = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            sb.append(DIGITS.charAt(random.nextInt(DIGITS.length())));
        }
        return sb.toString();
    }
}