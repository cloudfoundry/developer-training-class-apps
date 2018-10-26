package org.cloudfoundry.training.routeservice.ratelimit.limiter;

import java.util.Date;

import org.cloudfoundry.training.routeservice.ratelimit.record.AccessRecord;
import org.cloudfoundry.training.routeservice.ratelimit.record.AccessRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RateLimiter {

	private int numRequestsPerPeriod;
	private int periodInSeconds;
	
	@Autowired
	private AccessRecordRepository repository;
	
	public RateLimiter(int numRequestsPerPeriod, int periodInSeconds) {
		this.numRequestsPerPeriod = numRequestsPerPeriod;
		this.periodInSeconds = periodInSeconds;
	}
	
	RateLimiter(AccessRecordRepository repository, int numRequestsPerPeriod, int periodInSeconds) {
		this.repository = repository;
		this.numRequestsPerPeriod = numRequestsPerPeriod;
		this.periodInSeconds = periodInSeconds;
	}

	public boolean isAllowed(String clientId) {
		AccessRecord record = repository.findOne(clientId);
		if ( record == null ) {
			repository.save(new AccessRecord(clientId, 1, new Date()));
			return true;
		}
		Date now = new Date();
		
		Date validDate = new Date(now.getTime() - periodInSeconds*1000); 
		
		if ( record.getLastSuccess().before(validDate) ) {
			// it doesn't matter the count.  reset it and the date.
			record.setCount(1);
			record.setLastSuccess(now);
			repository.save(record);
			return true;
		} else {
			if ( record.getCount() < numRequestsPerPeriod ) { 
				record.setCount(record.getCount() + 1);
				repository.save(record);
				return true;
			} else {
				record.setCount(record.getCount() + 1);
				repository.save(record);
				return false;
			}
		}
	}

	public int getNumRequestsPerPeriod() {
		return numRequestsPerPeriod;
	}

	public int getPeriodInSeconds() {
		return periodInSeconds;
	}

	public void setNumRequestsPerPeriod(int numRequestsPerPeriod) {
		this.numRequestsPerPeriod = numRequestsPerPeriod;
	}

	public void setPeriodInSeconds(int periodInSeconds) {
		this.periodInSeconds = periodInSeconds;
	}
	
}
