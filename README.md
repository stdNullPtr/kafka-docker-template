# Kafka Docker Template

A production-ready Apache Kafka setup with Zookeeper and Kafka UI for message streaming and event processing.

## Quick Start

1. Copy environment configuration:
   ```bash
   cp .env.example .env
   ```

2. Update credentials in `.env` for production use

3. Start services:
   ```bash
   docker-compose up -d
   ```

4. Access Kafka UI:
    - URL: http://localhost:8070
    - Username: admin (configurable via KAFKA_UI_USERNAME)
    - Password: admin (configurable via KAFKA_UI_PASSWORD)

## Directory Structure

```
.
├── docker-compose.yml          # Main compose configuration
├── .env                        # Environment variables (local)
├── .env.example                # Environment template
├── config/                     # Kafka configuration files
├── data/                       # Persistent data
│   ├── zookeeper/             # Zookeeper data and logs
│   └── kafka/                 # Kafka data
├── scripts/                   # Management scripts
└── topics/                    # Topic creation scripts
```

## Configuration

### Environment Variables

| Variable                | Default | Description                 |
|-------------------------|---------|-----------------------------|
| `ZOOKEEPER_CLIENT_PORT` | 2181    | Zookeeper client port       |
| `ZOOKEEPER_TICK_TIME`   | 2000    | Zookeeper tick time         |
| `KAFKA_BROKER_ID`       | 1       | Kafka broker ID             |
| `KAFKA_INTERNAL_PORT`   | 29092   | Internal Kafka port         |
| `KAFKA_EXTERNAL_PORT`   | 9092    | External Kafka port         |
| `KAFKA_JMX_PORT`        | 9999    | JMX monitoring port         |
| `KAFKA_UI_PORT`         | 8070    | Kafka UI web interface port |
| `KAFKA_UI_USERNAME`     | admin   | Kafka UI username           |
| `KAFKA_UI_PASSWORD`     | admin   | Kafka UI password           |

### Production Considerations

1. **Change default passwords** in `.env`
2. **Configure proper security** for production deployment
3. **Set up monitoring** using JMX metrics
4. **Configure backup strategy** for the `data/` directory
5. **Tune Kafka settings** based on your use case
6. **Set appropriate replication factors** for production

## Usage

### Creating Topics

```bash
# Create a topic
docker exec kafka kafka-topics --create \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# List topics
docker exec kafka kafka-topics --list \
  --bootstrap-server localhost:9092

# Describe a topic
docker exec kafka kafka-topics --describe \
  --topic my-topic \
  --bootstrap-server localhost:9092
```

### Producing and Consuming Messages

```bash
# Start a producer
docker exec -it kafka kafka-console-producer \
  --topic my-topic \
  --bootstrap-server localhost:9092

# Start a consumer
docker exec -it kafka kafka-console-consumer \
  --topic my-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

### Consumer Groups

```bash
# List consumer groups
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list

# Describe a consumer group
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group my-group \
  --describe
```

## Common Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f kafka
docker-compose logs -f zookeeper
docker-compose logs -f kafka-ui

# Stop services
docker-compose down

# Reset data (removes all data!)
docker-compose down -v
sudo rm -rf data/

# Backup data
tar -czf kafka-backup-$(date +%Y%m%d).tar.gz data/

# Update to latest versions
docker-compose pull
docker-compose up -d

# Check cluster health
docker exec kafka kafka-broker-api-versions \
  --bootstrap-server localhost:9092

# Monitor JMX metrics
# Connect JConsole to localhost:9999
```

## Performance Tuning

### Kafka Settings

For production workloads, consider adjusting these settings in your docker-compose.yml:

```yaml
environment:
  # Increase log segment size for better performance
  KAFKA_LOG_SEGMENT_BYTES: 1073741824

  # Adjust flush settings
  KAFKA_LOG_FLUSH_INTERVAL_MESSAGES: 10000
  KAFKA_LOG_FLUSH_INTERVAL_MS: 1000

  # Memory settings
  KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"

  # Network settings
  KAFKA_SOCKET_SEND_BUFFER_BYTES: 102400
  KAFKA_SOCKET_RECEIVE_BUFFER_BYTES: 102400
  KAFKA_SOCKET_REQUEST_MAX_BYTES: 104857600
```

### Zookeeper Settings

```yaml
environment:
  # Memory settings
  KAFKA_HEAP_OPTS: "-Xmx512M -Xms512M"

  # Increase max client connections
  ZOOKEEPER_MAX_CLIENT_CNXNS: 60
```

## Monitoring

### Health Checks

The setup includes health checks for Kafka. Monitor service health with:

```bash
# Check service status
docker-compose ps

# View health check logs
docker inspect kafka | grep Health -A 10
```

### JMX Metrics

Kafka exposes JMX metrics on port 9999. Use tools like:

- JConsole (built into JDK)
- Prometheus JMX Exporter
- Grafana with JMX datasource

Key metrics to monitor:

- `kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec`
- `kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec`
- `kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec`
- `kafka.log:type=LogFlushStats,name=LogFlushRateAndTimeMs`

## Security

### Basic Authentication (Kafka UI)

Kafka UI supports various authentication methods. The default setup uses form-based login.

### Production Security

For production deployments, consider:

1. **SSL/TLS encryption** for client-broker communication
2. **SASL authentication** for client authentication
3. **ACLs (Access Control Lists)** for authorization
4. **Network isolation** using Docker networks
5. **Firewall rules** to restrict access

## Troubleshooting

1. **Services won't start**: Check logs with `docker-compose logs`
2. **Connection refused**: Ensure services are healthy and ports are correct
3. **Out of disk space**: Monitor data directory size
4. **Memory issues**: Adjust JVM heap settings
5. **Network connectivity**: Check Docker network configuration
6. **Permission issues**: Ensure proper file permissions on data directories

### Common Issues

**Kafka can't connect to Zookeeper:**

```bash
# Check Zookeeper logs
docker-compose logs zookeeper

# Verify Zookeeper is responsive
echo ruok | docker exec -i zookeeper nc localhost 2181
```

**Topics not visible in UI:**

```bash
# Refresh Kafka UI or check cluster configuration
# Verify bootstrap servers in Kafka UI settings
```

**Performance issues:**

```bash
# Check resource usage
docker stats

# Monitor Kafka metrics via JMX
# Tune JVM and Kafka settings based on workload
```