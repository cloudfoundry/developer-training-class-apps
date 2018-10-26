package org.cloudfoundry.http;

import java.util.Map;

public class AppDetails {
	private String appName;
	private String instanceIndex;
	private String serviceUrl;
	private String appVersion;

	private Map<String, String> rosterVars;

	public AppDetails(String appName, String instanceIndex, String serviceUrl, String appVersion,
			Map<String, String> rosterVars) {
		super();
		this.appName = appName;
		this.instanceIndex = instanceIndex;
		this.serviceUrl = serviceUrl;
		this.appVersion = appVersion;
		this.rosterVars = rosterVars;
	}

	public String getAppName() {
		return appName;
	}

	public String getInstanceIndex() {
		return instanceIndex;
	}

	public String getServiceUrl() {
		return serviceUrl;
	}

	public String getAppVersion() {
		return appVersion;
	}

	public Map<String, String> getRosterVars() {
		return rosterVars;
	}
}
