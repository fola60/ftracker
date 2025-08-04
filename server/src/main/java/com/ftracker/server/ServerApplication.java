package com.ftracker.server;

import com.ftracker.server.service.CategoryService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;


@SpringBootApplication
public class ServerApplication {



	public static void main(String[] args) throws NoSuchAlgorithmException {
		SpringApplication.run(ServerApplication.class, args);

	}


}
