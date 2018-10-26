package org.cloudfoundry;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

import org.cloudfoundry.model.Person;
import org.cloudfoundry.model.PersonRepository;
import org.cloudfoundry.model.PersonStatusRepository;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
@WebAppConfiguration
public class PersonStatusControllerTest {

	private MockMvc mockMvc;

	@Autowired
	private WebApplicationContext webApplicationContext;

	@Autowired
	private PersonRepository repository;

	@Autowired
	private PersonStatusRepository statusRepository;

	@MockBean(name = "localProps")
	private CloudProps cloudProperties;

	private UUID personId;

	@Before
	public void setup() throws Exception {
		this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
		repository.deleteAll();
		statusRepository.deleteAll();
		Person p = repository.save(new Person("Frodo", "Baggins", "frodo@example.com", "123456789", "Speedy Delivery"));
		personId = p.getUuid();
	}

	@Test
	public void testInsertStatus() throws Exception {
		mockMvc.perform(get("/people")).andDo(print());
		mockMvc.perform(get("/people/" + personId + "/personStatuses")).andDo(print());
		mockMvc.perform(post("/people_status").content(
				"{\"status\" : \"Active\", \"updatedTime\" : \"2017-03-10T13:16:36.780+0000\", \"person\" : \"http://localhost/people/"
						+ personId + "\"}"))
				.andExpect(status().isCreated()).andDo(print());
		mockMvc.perform(get("/people/" + personId + "/personStatuses")).andExpect(status().isOk())
				.andExpect(content().contentType(ControllerTest.contentType))
				.andExpect(jsonPath("$._embedded.people_status", hasSize(1)))
				.andExpect(jsonPath("$._embedded.people_status[0].status", is("Active")))
				.andExpect(jsonPath("$._embedded.people_status[0].updatedTime", is("2017-03-10T13:16:36.780+0000")));

	}
}
