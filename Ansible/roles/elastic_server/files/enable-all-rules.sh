PASSWORD=$1
curl -k -u "elastic:$PASSWORD" 'http://localhost/api/detection_engine/rules/_bulk_action' \
  -H 'Content-Type: application/json' -H 'kbn-xsrf: true'  \
  --data-raw '{"action":"enable","query":""}'