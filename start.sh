#!/bin/bash
echo "Starting up ..."
docker-compose -f docker-compose.yml up -d --build
# Sleep for 15 seconds waiting for sonarqube to start
echo "Waiting for sonarqube ...."
./wait_for_up.sh
echo "Import pre-defined qualify profile"
./import_profile.sh
# curl -u admin:admin -F 'backup=@assets/SecurityAudit.xml' -v http://localhost:9000/api/qualityprofiles/restore 
# curl -u admin:admin -d 'language=java&qualityProfile=SecurityAudit' -v http://localhost:9000/api/qualityprofiles/set_default 
echo "Sonarqube started"
