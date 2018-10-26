package org.cloudfoundry.training.routeservice.ratelimit.record;

import org.springframework.data.repository.CrudRepository;

public interface AccessRecordRepository extends CrudRepository<AccessRecord, String> {

}
