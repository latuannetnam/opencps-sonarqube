#!/bin/bash
code=`docker-compose logs --tail=5 | grep "SonarQube is up"`
#echo  ${#code}
while [ ${#code} -eq 0 ]
do
    echo "Waiting ..."
    sleep 5
    code=`docker-compose logs --tail=5 | grep "SonarQube is up"`
done    
