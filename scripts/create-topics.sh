#!/bin/bash

# Create common Kafka topics for development

KAFKA_CONTAINER="kafka"
BOOTSTRAP_SERVER="localhost:9092"

echo "Creating Kafka topics..."

# Example topics
docker exec $KAFKA_CONTAINER kafka-topics --create \
  --topic user-events \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

docker exec $KAFKA_CONTAINER kafka-topics --create \
  --topic notifications \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions 2 \
  --replication-factor 1 \
  --if-not-exists

docker exec $KAFKA_CONTAINER kafka-topics --create \
  --topic logs \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions 1 \
  --replication-factor 1 \
  --if-not-exists

echo "Topics created successfully!"

# List all topics
echo "Current topics:"
docker exec $KAFKA_CONTAINER kafka-topics --list --bootstrap-server $BOOTSTRAP_SERVER