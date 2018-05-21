#!/bin/bash
docker-compose -f docker-compose.yml up -d
# Sleep for 15 seconds waiting for sonarqube to start
echo "Waiting for sonarqube ...."
sleep 60
echo "Import pre-defined qualify profile"
curl -u admin:admin -F 'backup=@assets/SecurityAudit.xml' -v http://localhost:9000/api/qualityprofiles/restore 
curl -u admin:admin -d 'language=java&qualityProfile=SecurityAudit' -v http://localhost:9000/api/qualityprofiles/set_default 
echo "Sonarqube started"