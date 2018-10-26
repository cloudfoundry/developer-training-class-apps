package org.cloudfoundry;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Properties;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
@WebAppConfiguration
@TestPropertySource("roster-env.vars")
public class RosterPropsHttpControllerTests {

	private MockMvc mockMvc;

	@MockBean(name = "localProps")
	private CloudProps cloudProperties;

	@Autowired
	private WebApplicationContext webApplicationContext;

	@Before
	public void setup() {
		this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
	}

	@Test
	public void showsFullAppDetails() throws Exception {
		Properties props = new Properties();
		props.load(this.getClass().getClassLoader().getResourceAsStream("cloud-data.properties"));
		Mockito.when(cloudProperties.cloudProperties()).thenReturn(props);
		mockMvc.perform(get("/app-details")).andExpect(status().isOk())
				.andExpect(content().contentType(HttpControllerTests.contentType))
				.andExpect(content().json("{\"appName\": \"foo\"}"))
				.andExpect(content().json("{\"instanceIndex\": \"0\"}"))
				.andExpect(content().json("{\"serviceUrl\": \"jdbc:h2:mem:testdb\"}"))
				.andExpect(content()
						.json("{\"rosterVars\": {\"ROSTER_C\":\"baz\",\"ROSTER_B\":\"bar\",\"ROSTER_A\":\"foo\"}}"))
				.andExpect(content().json("{\"appVersion\": \"1.0.0\"}"));
	}
}
