echo  "Create elasticsearch enrollment token"
ENROLLMENT_TOKEN=$(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)
echo $ENROLLMENT_TOKEN
echo  "Setup Kibana with enrollment token"
echo $ENROLLMENT_TOKEN | sudo /usr/share/kibana/bin/kibana-setup