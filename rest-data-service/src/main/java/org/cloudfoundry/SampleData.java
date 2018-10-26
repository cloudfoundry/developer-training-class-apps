package org.cloudfoundry;

import org.cloudfoundry.model.Person;
import org.cloudfoundry.model.PersonRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Profile("dev")
@Component
public class SampleData implements CommandLineRunner {

	@Autowired
	private PersonRepository repository;
	
	@Override
	public void run(String... strings) throws Exception {
		repository.save(new Person("Frodo", "Baggins", "frodo@example.com", "123456789", "Speedy Delivery")); 
	}
	
}
