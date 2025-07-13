package com.ftracker.server.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.backend.url}")
    private String backendUrl;

    public void sendVerificationEmail(String email, String token) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setTo(email);
            helper.setSubject("Verify Your Account");

            // Direct link to your backend verification endpoint
            String verificationUrl = backendUrl + "/user/verify?token=" + token;
            String htmlContent = buildVerificationEmailContent(verificationUrl);

            helper.setText(htmlContent, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send verification email", e);
        }
    }

    public void sendPasswordResetEmail(String email, String token) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setTo(email);
            helper.setSubject("Reset Your Password");

            // Direct link to your backend password reset endpoint
            String resetUrl = backendUrl + "/user/reset-password?token=" + token;
            String htmlContent = buildPasswordResetEmailContent(resetUrl);

            helper.setText(htmlContent, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }

    private String buildVerificationEmailContent(String verificationUrl) {
        return "<html><body>" +
                "<h2>Verify Your Account</h2>" +
                "<p>Please click the link below to verify your account:</p>" +
                "<a href=\"" + verificationUrl + "\" style=\"display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;\">Verify Account</a>" +
                "<p>Or copy and paste this link into your browser:</p>" +
                "<p>" + verificationUrl + "</p>" +
                "<p>This link will expire in 24 hours.</p>" +
                "</body></html>";
    }

    private String buildPasswordResetEmailContent(String resetUrl) {
        return "<html><body style=\"font-family: Arial, sans-serif; line-height: 1.6; color: #333;\">" +
                "<div style=\"max-width: 600px; margin: 0 auto; padding: 20px;\">" +
                "<h2 style=\"color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 10px;\">Reset Your Password</h2>" +
                "<p>You have requested to reset your password. Please click the button below to reset it:</p>" +
                "<div style=\"text-align: center; margin: 30px 0;\">" +
                "<a href=\"" + resetUrl + "\" style=\"display: inline-block; padding: 12px 24px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 5px; font-weight: bold;\">Reset Password</a>" +
                "</div>" +
                "<p>Or copy and paste this link into your browser:</p>" +
                "<p style=\"word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace;\">" + resetUrl + "</p>" +
                "<div style=\"margin-top: 30px; padding: 15px; background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px;\">" +
                "<p style=\"margin: 0; color: #856404;\"><strong>Important:</strong></p>" +
                "<ul style=\"margin: 5px 0; color: #856404;\">" +
                "<li>This link will expire in 1 hour for security reasons</li>" +
                "<li>If you didn't request this password reset, please ignore this email</li>" +
                "<li>Your password will not be changed unless you click the link above</li>" +
                "</ul>" +
                "</div>" +
                "<hr style=\"margin: 30px 0; border: none; border-top: 1px solid #eee;\">" +
                "<p style=\"font-size: 12px; color: #666; text-align: center;\">This is an automated message, please do not reply to this email.</p>" +
                "</div>" +
                "</body></html>";
    }
}