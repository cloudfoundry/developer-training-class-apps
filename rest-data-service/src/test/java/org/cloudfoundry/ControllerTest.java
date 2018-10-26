package org.cloudfoundry;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.Charset;
import java.util.Arrays;

import org.cloudfoundry.model.Person;
import org.cloudfoundry.model.PersonRepository;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.hateoas.MediaTypes;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
@WebAppConfiguration
public class ControllerTest {

	final static MediaType contentType = new MediaType(MediaTypes.HAL_JSON.getType(), MediaTypes.HAL_JSON.getSubtype(),
			Charset.forName("utf8"));

	private MockMvc mockMvc;

	@Autowired
	private WebApplicationContext webApplicationContext;

	@SuppressWarnings("rawtypes")
	private HttpMessageConverter mappingJackson2HttpMessageConverter;

	@Autowired
	private PersonRepository repository;

	@MockBean(name = "localProps")
	private CloudProps cloudProperties;

	@Autowired
	void setConverters(HttpMessageConverter<?>[] converters) {

		this.mappingJackson2HttpMessageConverter = Arrays.asList(converters).stream()
				.filter(hmc -> hmc instanceof MappingJackson2HttpMessageConverter).findAny().orElse(null);

		assertNotNull("the JSON message converter must not be null", this.mappingJackson2HttpMessageConverter);
	}

	@Before
	public void setup() {
		this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
		repository.deleteAll();
	}

	@Test
	public void listsPeople() throws Exception {
		mockMvc.perform(get("/people")).andExpect(status().isOk()).andExpect(content().contentType(contentType));
	}

	@Test
	public void itSavesAPerson() throws Exception {
		mockMvc.perform(post("/people").content(
				"{  \"firstName\" : \"Frodo\",  \"lastName\" : \"Baggins\", \"email\" : \"frodo@example.com\", \"phoneNumber\" : \"123456789\", \"companyName\" : \"Speedy Delivery\" }"))
				.andExpect(status().isCreated());

		mockMvc.perform(get("/people")).andExpect(status().isOk()).andExpect(content().contentType(contentType))
				.andExpect(jsonPath("$._embedded.people", hasSize(1)))
				.andExpect(jsonPath("$._embedded.people[0].firstName", is("Frodo")))
				.andExpect(jsonPath("$._embedded.people[0].lastName", is("Baggins")))
				.andExpect(jsonPath("$._embedded.people[0].email", is("frodo@example.com")))
				.andExpect(jsonPath("$._embedded.people[0].phoneNumber", is("123456789")))
				.andExpect(jsonPath("$._embedded.people[0].companyName", is("Speedy Delivery")));
	}

	@Test
	public void itGetsAPerson() throws Exception {

		repository.save(new Person("Frodo", "Baggins", "frodo@example.com", "123456789", "Speedy Delivery"));
		Person p = repository.findAll().iterator().next();

		mockMvc.perform(get("/people/" + p.getUuid())).andExpect(status().isOk())
				.andExpect(content().contentType(contentType)).andExpect(jsonPath("$.firstName", is("Frodo")))
				.andExpect(jsonPath("$.lastName", is("Baggins")))
				.andExpect(jsonPath("$.email", is("frodo@example.com")))
				.andExpect(jsonPath("$.phoneNumber", is("123456789")))
				.andExpect(jsonPath("$.companyName", is("Speedy Delivery")));
	}

	@Test
	public void itDeletesAPerson() throws Exception {

		repository.save(new Person("Frodo", "Baggins", "frodo@example.com", "867-5309", "Speedy Delivery"));
		Person p = repository.findAll().iterator().next();

		mockMvc.perform(delete("/people/" + p.getUuid())).andExpect(status().isNoContent());

		mockMvc.perform(get("/people/" + p.getUuid())).andExpect(status().isNotFound());
	}
}
