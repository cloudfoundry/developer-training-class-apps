package org.cloudfoundry;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ApplicationTests {

	@MockBean(name = "localProps")
	private CloudProps cloudProperties;
	
	@Test
	public void contextLoads() {
	}

}
