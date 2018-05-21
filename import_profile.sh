#!/bin/sh
 curl -u admin:admin -F 'backup=@assets/SecurityAudit.xml' -v http://localhost:9000/api/qualityprofiles/restore 
 curl -u admin:admin -d 'language=java&qualityProfile=SecurityAudit' -v http://localhost:9000/api/qualityprofiles/set_default 
