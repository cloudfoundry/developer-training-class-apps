package org.cloudfoundry.training.routeservice.ratelimit;

import java.net.URI;

import org.cloudfoundry.training.routeservice.ratelimit.limiter.RateLimiter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestOperations;

@RestController
final class Controller {
	
	static final String CF_FORWARDED_URL = "X-Cf-Forwarded-Url";
    static final String FORWARDED_URL = "X-CF-Forwarded-Url";
    static final String PROXY_METADATA = "X-CF-Proxy-Metadata";
    static final String PROXY_SIGNATURE = "X-CF-Proxy-Signature";

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private final RestOperations restOperations;

    private RateLimiter limiter;
    
    @Autowired
    Controller(RestOperations restOperations, RateLimiter limiter) {
        this.restOperations = restOperations;
        this.limiter = limiter;
    }

    @RequestMapping(headers = {FORWARDED_URL, PROXY_METADATA, PROXY_SIGNATURE})
    ResponseEntity<?> service(RequestEntity<byte[]> incoming) {
        this.logger.info("Incoming Request: {}", incoming);

        String ip = getIp(incoming);
        if ( limiter.isAllowed(ip) ) {
        	RequestEntity<?> outgoing = getOutgoingRequest(incoming);
        	this.logger.info("Outgoing Request: {}", outgoing);
        	return this.restOperations.exchange(outgoing, byte[].class);
        } else {
        	return new ResponseEntity<String>("You are only allowed to make " + limiter.getNumRequestsPerPeriod() + " per " + limiter.getPeriodInSeconds() + " seconds", null, HttpStatus.TOO_MANY_REQUESTS);
        }
    }

    String getIp(RequestEntity<byte[]> incoming) {
    	return incoming.getHeaders().getFirst(CF_FORWARDED_URL);
    }
    
    private static RequestEntity<?> getOutgoingRequest(RequestEntity<?> incoming) {
        HttpHeaders headers = new HttpHeaders();
        headers.putAll(incoming.getHeaders());

        URI uri = headers.remove(FORWARDED_URL).stream()
            .findFirst()
            .map(URI::create)
            .orElseThrow(() -> new IllegalStateException(String.format("No %s header present", FORWARDED_URL)));

        return new RequestEntity<>(incoming.getBody(), headers, incoming.getMethod(), uri);
    }

}