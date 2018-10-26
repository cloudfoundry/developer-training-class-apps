package org.cloudfoundry.training.routeservice.ratelimit.record;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class AccessRecord {

	@Id
	private String clientId;
	private int count;
	private Date lastSuccess;
	
	AccessRecord() {}

	public AccessRecord(String clientId, int count, Date lastSuccess) {
		this.clientId = clientId;
		this.count = count;
		this.lastSuccess = lastSuccess;
	}
	
	public String getClientId() {
		return clientId;
	}

	public void setClientId(String clientId) {
		this.clientId = clientId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public Date getLastSuccess() {
		return lastSuccess;
	}

	public void setLastSuccess(Date lastSuccess) {
		this.lastSuccess = lastSuccess;
	}
	
	@Override
	public String toString() {
		return "AccessRecord [clientId=" + clientId + ", count=" + count + ", lastSuccess=" + lastSuccess + "]";
	}
	
}
