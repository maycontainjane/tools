# use BSD sed to replace the keycloak image from quay.io with 'sleighzy/keycloak:latest'
sed -i '' 's/quay.io\/keycloak\/keycloak:15.0.2/sleighzy\/keycloak:latest/g' docker-compose.yml

# use BSD sed to add 'platform: linux/x86_64' as a parameter to the influxdb service
sed -i '' 's/image: influxdb:1.8.4/image: influxdb:1.8.4\n    platform: linux\/x86_64/' docker-compose.yml