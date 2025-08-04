package com.ftracker.server.controller;

import com.ftracker.server.entity.User;
import com.ftracker.server.service.EmailService;
import com.ftracker.server.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService service;

    @Autowired
    private EmailService emailService;

    @GetMapping("/auth/check-token")
    public ResponseEntity<?> checkAuthentication() {
        return ResponseEntity.ok(Map.of(
                "authenticated", true
        ));
    }

    @PostMapping("/register")
    public ResponseEntity<String> postUser(@Validated @RequestBody User user) {
        User existingUser = service.getUserByEmail(user.getEmail());

        if (existingUser != null) {
            if (existingUser.isVerified()) {
                return new ResponseEntity<>("Login. User already exists.", HttpStatus.CONFLICT);
            } else {
                // Resend verification email
                String newToken = generateVerificationToken();
                existingUser.setVerificationToken(newToken);
                existingUser.setTokenExpiry(LocalDateTime.now().plusHours(24));
                service.saveUser(existingUser);

                emailService.sendVerificationEmail(existingUser.getEmail(), newToken);
                return new ResponseEntity<>("Verification email was sent to your inbox at: " + existingUser.getEmail(), HttpStatus.OK);
            }
        }

        // New user registration
        String verificationToken = generateVerificationToken();
        user.setVerificationToken(verificationToken);
        user.setTokenExpiry(LocalDateTime.now().plusHours(24));
        user.setVerified(false);
        service.saveUser(user);

        emailService.sendVerificationEmail(user.getEmail(), verificationToken);
        return new ResponseEntity<>("Verification email sent to inbox at: " + user.getEmail(), HttpStatus.CREATED);
    }

    @GetMapping("/verify")
    public ResponseEntity<String> verifyUser(@RequestParam String token) {
        User user = service.getUserByVerificationToken(token);

        if (user == null) {
            return ResponseEntity.ok(buildHtmlResponse(
                    "Invalid Verification Token",
                    "The verification token is invalid or has already been used.",
                    "error"
            ));
        }

        if (user.getTokenExpiry().isBefore(LocalDateTime.now())) {
            return ResponseEntity.ok(buildHtmlResponse(
                    "Token Expired",
                    "The verification token has expired. Please register again.",
                    "error"
            ));
        }

        user.setVerified(true);
        user.setVerificationToken(null);
        user.setTokenExpiry(null);
        service.saveUser(user);


        return ResponseEntity.ok(buildHtmlResponse(
                "Account Verified Successfully!",
                "Your account has been verified. You can now log in to your account.",
                "success"
        ));
    }

    @GetMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestParam String email) {

        System.out.println("Forgot password call: " + email);

        User user = service.getUserByEmail(email);

        if (user == null || !user.isVerified()) {
            return new ResponseEntity<>("Account is not verified or does not exist.", HttpStatus.OK);
        }

        String resetToken = generateVerificationToken();
        user.setResetToken(resetToken);
        user.setResetTokenExpiry(LocalDateTime.now().plusHours(1));
        service.saveUser(user);

        emailService.sendPasswordResetEmail(user.getEmail(), resetToken);

        return new ResponseEntity<>("A password reset link has been sent.", HttpStatus.OK);
    }

    @GetMapping("/reset-password")
    public ResponseEntity<String> showResetPasswordForm(@RequestParam String token) {
        User user = service.getUserByPasswordResetToken(token);

        if (user == null) {
            return ResponseEntity.ok(buildHtmlResponse(
                    "Invalid Reset Token",
                    "The password reset token is invalid or has already been used.",
                    "error"
            ));
        }

        if (user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
            return ResponseEntity.ok(buildHtmlResponse(
                    "Token Expired",
                    "The password reset token has expired. Please request a new password reset.",
                    "error"
            ));
        }

        return ResponseEntity.ok(buildPasswordResetForm(token));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String newPassword = request.get("password");
        String confirmPassword = request.get("confirmPassword");

        if (token == null || newPassword == null || confirmPassword == null) {
            return new ResponseEntity<>("Missing required fields", HttpStatus.BAD_REQUEST);
        }

        if (!newPassword.equals(confirmPassword)) {
            return new ResponseEntity<>("Passwords do not match", HttpStatus.BAD_REQUEST);
        }

        if (!newPassword.matches("(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$&*]).{8,}")) {
            return new ResponseEntity<>("Password must be at least 8 characters long and include at least one uppercase letter, one digit, and one special character (!@#$&*)", HttpStatus.BAD_REQUEST);
        }

        User user = service.getUserByPasswordResetToken(token);

        if (user == null) {
            return new ResponseEntity<>("Invalid reset token", HttpStatus.BAD_REQUEST);
        }

        if (user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
            return new ResponseEntity<>("Token expired", HttpStatus.BAD_REQUEST);
        }

        // Reset password
        boolean success = service.resetPassword(user, newPassword);

        if (success) {
            return new ResponseEntity<>("Password reset successfully", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Failed to reset password", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }



    private String buildPasswordResetForm(String token) {
        return "<!DOCTYPE html>" +
                "<html lang='en'>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                "<title>Reset Password</title>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f8f9fa; }" +
                ".container { max-width: 400px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }" +
                ".form-group { margin-bottom: 15px; }" +
                "label { display: block; margin-bottom: 5px; font-weight: bold; }" +
                "input[type='password'] { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }" +
                "button { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }" +
                "button:hover { background-color: #0056b3; }" +
                ".error { color: #dc3545; margin-top: 10px; }" +
                ".success { color: #28a745; margin-top: 10px; }" +
                "h1 { text-align: center; margin-bottom: 20px; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<h1>Reset Your Password</h1>" +
                "<form onsubmit='resetPassword(event)'>" +
                "<div class='form-group'>" +
                "<label for='password'>New Password:</label>" +
                "<input type='password' id='password' name='password' required minlength='6'>" +
                "</div>" +
                "<div class='form-group'>" +
                "<label for='confirmPassword'>Confirm Password:</label>" +
                "<input type='password' id='confirmPassword' name='confirmPassword' required minlength='6'>" +
                "</div>" +
                "<button type='submit'>Reset Password</button>" +
                "<div id='message'></div>" +
                "</form>" +
                "</div>" +
                "<script>" +
                "async function resetPassword(event) {" +
                "event.preventDefault();" +
                "const password = document.getElementById('password').value;" +
                "const confirmPassword = document.getElementById('confirmPassword').value;" +
                "const messageDiv = document.getElementById('message');" +
                "if (password !== confirmPassword) {" +
                "messageDiv.innerHTML = '<div class=\"error\">Passwords do not match</div>';" +
                "return;" +
                "}" +
                "try {" +
                "const response = await fetch('/user/reset-password', {" +
                "method: 'POST'," +
                "headers: { 'Content-Type': 'application/json' }," +
                "body: JSON.stringify({ token: '" + token + "', password: password, confirmPassword: confirmPassword })" +
                "});" +
                "const result = await response.text();" +
                "if (response.ok) {" +
                "messageDiv.innerHTML = '<div class=\"success\">' + result + '</div>';" +
                "document.querySelector('form').reset();" +
                "} else {" +
                "messageDiv.innerHTML = '<div class=\"error\">' + result + '</div>';" +
                "}" +
                "} catch (error) {" +
                "messageDiv.innerHTML = '<div class=\"error\">An error occurred. Please try again.</div>';" +
                "}" +
                "}" +
                "</script>" +
                "</body>" +
                "</html>";
    }


    private String buildHtmlResponse(String title, String message, String type) {
        String backgroundColor = type.equals("success") ? "#d4edda" : "#f8d7da";
        String textColor = type.equals("success") ? "#155724" : "#721c24";
        String borderColor = type.equals("success") ? "#c3e6cb" : "#f5c6cb";

        return "<!DOCTYPE html>" +
                "<html lang='en'>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                "<title>" + title + "</title>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f8f9fa; }" +
                ".container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }" +
                ".message { padding: 20px; margin-bottom: 20px; border-radius: 5px; background-color: " + backgroundColor + "; color: " + textColor + "; border: 1px solid " + borderColor + "; }" +
                ".icon { font-size: 48px; text-align: center; margin-bottom: 20px; }" +
                ".success-icon { color: #28a745; }" +
                ".error-icon { color: #dc3545; }" +
                "h1 { text-align: center; margin-bottom: 20px; }" +
                "p { text-align: center; font-size: 16px; line-height: 1.5; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='icon " + (type.equals("success") ? "success-icon" : "error-icon") + "'>" +
                (type.equals("success") ? "✓" : "✗") +
                "</div>" +
                "<h1>" + title + "</h1>" +
                "<div class='message'>" +
                "<p>" + message + "</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }

    @PostMapping("/login")
    public String login(@Validated @RequestBody User user) {
        return service.verify(user);
    }


    @GetMapping("/get-user/{id}")
    public User getUserById(@PathVariable Integer id) {
        return service.getUserById(id);
    }

    public String generateVerificationToken() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}