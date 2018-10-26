package org.cloudfoundry.training.routeservice.ratelimit.limiter;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.when;

import java.util.Date;

import org.cloudfoundry.training.routeservice.ratelimit.record.AccessRecord;
import org.cloudfoundry.training.routeservice.ratelimit.record.AccessRecordRepository;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
public class RateLimiterTests {

	@MockBean
	private AccessRecordRepository repository;
	
	@Test
	public void itIsTrueWhenNoRecord() {
		RateLimiter limiter = new RateLimiter(repository, 10, 60);
		when(repository.findOne(anyString())).thenReturn(null);
		assertTrue(limiter.isAllowed("clientId"));
	}
	
	@Test
	public void itIsTrueWhenWithinBounds() {
		RateLimiter limiter = new RateLimiter(repository, 10, 60);
		when(repository.findOne(anyString())).thenReturn(new AccessRecord("clientId", 1, new Date()));
		assertTrue(limiter.isAllowed("clientId"));
	}
	
	@Test
	public void itIsFalseWhenTooManyRequestsWithinTime() {
		RateLimiter limiter = new RateLimiter(repository, 10, 60);
		when(repository.findOne(anyString())).thenReturn(new AccessRecord("clientId", 10, new Date()));
		assertFalse(limiter.isAllowed("clientId"));
	}
	
	@Test
	public void itIsFalseWhenTooManyRequestsWithinTimeButOkForOtherClient() {
		RateLimiter limiter = new RateLimiter(repository, 10, 60);
		when(repository.findOne("clientId")).thenReturn(new AccessRecord("clientId", 10, new Date()));
		when(repository.findOne("otherClientId")).thenReturn(new AccessRecord("otherClientId", 5, new Date()));
		assertFalse(limiter.isAllowed("clientId"));
		assertTrue(limiter.isAllowed("otherClientId"));
	}
	
	@Test
	public void itIsTrueWhenTimeElapses() {
		RateLimiter limiter = new RateLimiter(repository, 10, 60);
		Date date = new Date();
		date.setTime(date.getTime() - 61000);
		when(repository.findOne(anyString())).thenReturn(new AccessRecord("clientId", 20, date));
		assertTrue(limiter.isAllowed("clientId"));
	}
	
}
