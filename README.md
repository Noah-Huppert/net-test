# Net Test
Monitors network connectivity for downtime.

# Table Of Contents
- [Overview](#overview)
- [Run](#run)
  - [Docker Compose](#docker-compose)
  - [Manual](#manual)
- [Analyse](#analyse)

# Overview
Tool which measures network connectivity to target hosts.

The `net-test` program performs measurements and publishes the resulting metrics for Prometheus to scrape.

Prometheus can then be used to analyse and view data.

# Run
## Docker Compose
A Docker Compose file is provided which orchestrates the execution of this tool.

Run:

```
docker-compose up -d
```

Then visit [127.0.0.1:9090](http://127.0.0.1:9090) to view the metrics.

To customize the command line arguments used to run `net-test` in Docker create a copy of `docker-compose.custom.example.yml` named `docker-compose.custom.yml`. Then edit this file with your custom command. To run with the custom command:

```
docker-compose -f docker-compose.yml -f docker-compose.custom.yml up -d
```

## Manual
The `net-test` tool is written in Go. Run it:

```
go run main.go
```

See the output of `go run main -h` for supported options.

Next run Prometheus and have it scrape the host on which you set `net-test` to publish metrics. By default this is `127.0.0.1:2112`.

# Analyse
Measurements are placed in Prometheus. The following measurement types create the following metrics:

**Ping (`-p <ms interval>`)**  
- `ping_rtt_ms` (Histogram, labels `target_host`): Round trip time to target host
- `ping_failures_total` (Count, labels `target_host`): Incremented when a target host cannot be reached
