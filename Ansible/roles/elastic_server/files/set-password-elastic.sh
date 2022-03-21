# Reset the password
NEW_PASSWORD=$(echo y | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic | sed  -n 's/^New value: \(.*\)$/\1/p')
curl -X POST --insecure --user elastic:$NEW_PASSWORD https://localhost:9200/_security/user/elastic/_password -H 'Content-Type: application/json' -d "{ \"password\" : \"$1\" }"