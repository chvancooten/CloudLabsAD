
PASSWORD=$1
IP_ADDRESS_SERVER=$2
# Create the agent policy
POLICY_ID=$(curl -s -u "elastic:$PASSWORD" -H 'Content-Type: application/json' -H 'kbn-xsrf: true' 'http://localhost/api/fleet/agent_policies?sys_monitoring=true' --data-raw '{"name":"Fleet Server policy","description":"","namespace":"default","monitoring_enabled":["logs","metrics"],"has_fleet_server":true}' -k | jq -r .item.id)

ELASTICSEARCH_VERSION=$(sudo /usr/share/elasticsearch/bin/elasticsearch -V | cut -d" " -f 2 | tr -d ",")
cd /tmp/
wget https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz
tar -xvf elastic-agent-8.1.0-linux-x86_64.tar.gz
cd elastic-agent-$ELASTICSEARCH_VERSION-linux-x86_64/
TOKEN=$(curl -k -u "elastic:$PASSWORD" -H 'kbn-xsrf: true' -s -X POST http://localhost/api/fleet/service-tokens  | jq -r .value)

# Enroll the fleet server
sudo ./elastic-agent install  \
  --fleet-server-es=https://localhost:9200 \
  --fleet-server-service-token=$TOKEN \
  --fleet-server-policy=$POLICY_ID \
  --fleet-server-es-insecure \
  --force

# Update the fleet server ip address
curl -k -u "elastic:$PASSWORD" -H 'kbn-xsrf: true' 'http://localhost/api/fleet/settings' \
  -X 'PUT' \
  -H 'Content-Type: application/json' \
  --data-raw "{\"fleet_server_hosts\":[\"https://$IP_ADDRESS_SERVER:8220\"]}"