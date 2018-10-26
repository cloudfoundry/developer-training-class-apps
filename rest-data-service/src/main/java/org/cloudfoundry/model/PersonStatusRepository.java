package org.cloudfoundry.model;

import java.util.UUID;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "people_status", path = "people_status")
public interface PersonStatusRepository extends PagingAndSortingRepository<PersonStatus, UUID> {

}
