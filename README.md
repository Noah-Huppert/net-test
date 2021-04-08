# Net Test
Monitors network connectivity for downtime.

# Table Of Contents
- [Overview](#overview)
- [Run](#run)
  - [Run with Docker Compose](#run-with-docker-compose)
  - [Run Manually](#run-manually)
- [Analyse](#analyse)

# Overview
Tool which measures network connectivity to target hosts.

The `net-test` program performs measurements and publishes the resulting metrics for Prometheus to scrape.

Prometheus can then be used to analyse and view data.

# Run
The `net-test` tool measures results and publishes them for Prometheus to scrape. One cannot meaningfully view the resulting measurements without Prometheus.

A Docker Compose setup is provided to make this process as easy as running a single tool, see [Run with Docker Compose](#run-with-docker-compose).

If one would like to run the setup without Docker Compose see [Run Manually](#run-manually).

The command line options of the `net-test` program describe its capabilities:

```
  -T string
        Add this target host to the beginning of existing target hosts
  -a    Measure all target hosts (incompatible with -f)
  -f    Only measure the first target host and fallover to other following target hosts if the measurement fails (incompatible with -a) (default true)
  -m string
        Host on which to serve Prometheus metrics (default ":2112")
  -p int
        Interval in milliseconds at which to perform the ping measurement. Will perform 3 ping(s). A value of -1 disables this test. Results recorded to the "ping_rtt_ms" and "ping_failures_total" metrics with the "target_host" label. (default 10000)
  -t value
        Target hosts (DNS or IP4) to measure for connectivity
```

## Run with Docker Compose
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

## Run Manually
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
