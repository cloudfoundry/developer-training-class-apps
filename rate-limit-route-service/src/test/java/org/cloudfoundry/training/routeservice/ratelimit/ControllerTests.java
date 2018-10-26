package org.cloudfoundry.training.routeservice.ratelimit;

import static org.springframework.http.HttpMethod.GET;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.cloudfoundry.training.routeservice.ratelimit.limiter.RateLimiter;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.client.ExpectedCount;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)
public class ControllerTests {

    private static final String PROXY_METADATA_VALUE = "test-proxy-metadata";

    private static final String PROXY_SIGNATURE_VALUE = "test-proxy-signature";

    private MockMvc mockMvc;

    private MockRestServiceServer mockServer;
    
    @Autowired
    private RateLimiter limiter;
    
    @Before
    public void setup() {
    	limiter.setNumRequestsPerPeriod(3);
    	limiter.setPeriodInSeconds(5);
    }

    @Test
    @DirtiesContext
	public void itAllowsWhenNew() throws Exception {
    	this.mockServer
	        .expect(method(GET))
	        .andExpect(requestTo("http://localhost/original/get"))
	        .andExpect(header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE))
	        .andExpect(header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
	        .andRespond(withSuccess());

	    this.mockMvc
	        .perform(get("http://localhost/route-service/get")
	            .header(Controller.FORWARDED_URL, "http://localhost/original/get")
	            .header(Controller.CF_FORWARDED_URL, "127.0.0.1")
	            .header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE)
	            .header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
	        .andExpect(status().isOk());
	
	    this.mockServer.verify();
	}
    
    @Test
    @DirtiesContext
	public void itDeniesWhenTooManyRequests() throws Exception {	
    	
    	this.mockServer.expect(ExpectedCount.times(limiter.getNumRequestsPerPeriod()), method(GET))
		    .andExpect(requestTo("http://localhost/original/get"))
		    .andExpect(header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE))
		    .andExpect(header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
		    .andRespond(withSuccess());
    	
    	for ( int i = 0; i < limiter.getNumRequestsPerPeriod(); i++ ) {		
		    this.mockMvc
		        .perform(get("http://localhost/route-service/get")
		            .header(Controller.FORWARDED_URL, "http://localhost/original/get")
		            .header(Controller.CF_FORWARDED_URL, "127.0.0.1")
		            .header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE)
		            .header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
		        .andExpect(status().isOk());
    	} 	
    	
    	this.mockMvc
        .perform(get("http://localhost/route-service/get")
            .header(Controller.FORWARDED_URL, "http://localhost/original/get")
            .header(Controller.CF_FORWARDED_URL, "127.0.0.1")
            .header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE)
            .header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
        .andExpect(status().isTooManyRequests());

    	this.mockServer.verify();
	}
    
	
	@Test
	@DirtiesContext
	public void itAllowsWhenTimeElapses() throws Exception {
	    	
    	this.mockServer.expect(ExpectedCount.times(limiter.getNumRequestsPerPeriod() + 1), method(GET))
		    .andExpect(requestTo("http://localhost/original/get"))
		    .andExpect(header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE))
		    .andExpect(header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
		    .andRespond(withSuccess());
	    	
	   	for ( int i = 0; i < limiter.getNumRequestsPerPeriod(); i++ ) {		
		    this.mockMvc
		        .perform(get("http://localhost/route-service/get")
		            .header(Controller.FORWARDED_URL, "http://localhost/original/get")
		            .header(Controller.CF_FORWARDED_URL, "127.0.0.1")
		            .header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE)
		            .header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
		        .andExpect(status().isOk());
	   	} 	
	    
	   	Thread.sleep((limiter.getPeriodInSeconds() + 1) * 1000);
	   	
	    this.mockMvc
	      	.perform(get("http://localhost/route-service/get")
	            .header(Controller.FORWARDED_URL, "http://localhost/original/get")
	            .header(Controller.CF_FORWARDED_URL, "127.0.0.1")
	            .header(Controller.PROXY_METADATA, PROXY_METADATA_VALUE)
	            .header(Controller.PROXY_SIGNATURE, PROXY_SIGNATURE_VALUE))
	        .andExpect(status().isOk());

	    this.mockServer.verify();
	}
    

    @Autowired
    void setRestTemplate(RestTemplate restTemplate) {
        this.mockServer = MockRestServiceServer.createServer(restTemplate);
    }

    @Autowired
    void setWebApplicationContext(WebApplicationContext wac) {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(wac).build();
    }
}