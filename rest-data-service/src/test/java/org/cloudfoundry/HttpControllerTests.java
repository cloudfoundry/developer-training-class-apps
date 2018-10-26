package org.cloudfoundry;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.Charset;
import java.util.Properties;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
@WebAppConfiguration
public class HttpControllerTests {

	final static MediaType contentType = new MediaType(MediaType.APPLICATION_JSON_UTF8.getType(),
			MediaType.APPLICATION_JSON_UTF8.getSubtype(), Charset.forName("utf8"));

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
	public void showsPartialAppDetails() throws Exception {
		Properties props = new Properties();
		props.load(this.getClass().getClassLoader().getResourceAsStream("cloud-data.properties"));
		Mockito.when(cloudProperties.cloudProperties()).thenReturn(props);
		mockMvc.perform(get("/app-details")).andExpect(status().isOk()).andExpect(content().contentType(contentType))
				.andExpect(content().json("{\"appName\": \"foo\"}"))
				.andExpect(content().json("{\"instanceIndex\": \"0\"}"))
				.andExpect(content().json("{\"serviceUrl\": \"jdbc:h2:mem:testdb\"}"))
				.andExpect(jsonPath("$.rosterVars").doesNotExist()).andExpect(jsonPath("$.appVersion").doesNotExist())
				.andDo(print());
	}
}
