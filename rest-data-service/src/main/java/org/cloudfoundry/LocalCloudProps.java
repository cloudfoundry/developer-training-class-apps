package org.cloudfoundry;

import java.util.Properties;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("local")
public class LocalCloudProps implements CloudConfigProperties {

	@Bean
	public Properties cloudProperties() {
		return new Properties();
	}

}