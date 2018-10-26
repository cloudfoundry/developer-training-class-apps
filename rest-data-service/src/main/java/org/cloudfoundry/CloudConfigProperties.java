package org.cloudfoundry;

import java.util.Properties;

import org.springframework.context.annotation.Profile;

@Profile("cloud")
public interface CloudConfigProperties {

	public Properties cloudProperties();
}