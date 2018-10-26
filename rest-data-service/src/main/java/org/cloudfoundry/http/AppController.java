package org.cloudfoundry.http;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.sql.DataSource;

import org.cloudfoundry.CloudConfigProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {

	private CloudConfigProperties config;

	private DataSource db;

	@Value("${ROSTER_A:#{null}}")
	private String rosterVarA;

	@Value("${ROSTER_B:#{null}}")
	private String rosterVarB;

	@Value("${ROSTER_C:#{null}}")
	private String rosterVarC;

	@Value("${APP_VERSION:#{null}}")
	private String appVersion;

	@Autowired
	public AppController(CloudConfigProperties config, DataSource db) {
		this.config = config;
		this.db = db;
	}

	@RequestMapping("/kill")
	public void kill() {
		System.exit(1);
	}

	@RequestMapping("/app-details")
	public AppDetails info() throws SQLException {
		Properties cloudProperties = config.cloudProperties();
		Map<String, String> map = new HashMap<>();
		if (rosterVarA != null) {
			map.put("ROSTER_A", rosterVarA);
		}
		if (rosterVarB != null) {
			map.put("ROSTER_B", rosterVarB);
		}
		if (rosterVarC != null) {
			map.put("ROSTER_C", rosterVarC);
		}
		if (map.isEmpty()) {
			map = null;
		}
		return new AppDetails(cloudProperties.getProperty("cloud.application.name"),
				cloudProperties.get("cloud.application.instance_index").toString(),
				db.getConnection().getMetaData().getURL(), this.appVersion, map);

	}
}
