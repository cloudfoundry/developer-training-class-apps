package org.cloudfoundry.training.routeservice.ratelimit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class RateLimitRouteServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(RateLimitRouteServiceApplication.class, args);
	}
}
