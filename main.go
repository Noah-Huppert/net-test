package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/Noah-Huppert/golog"
	"github.com/go-ping/ping"
	prom "github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const PING_COUNT int = 3

// die will print an error then exit the process with code 1
func die(err error) {
	fmt.Fatalf("error: %s", err.Error())
}

// check that error is nil, if not print the msg error and exit.
func check(msg string, err error) {
	if err != nil {
		die(fmt.Sprintf("error: %s: %s", msg, err.Error()))
	}
}

// main runs the command line interface.
func main() {
	log := golog.NewLogger("net-test")

	// Flags
	var targetHosts []string
	flag.StringVar(&targetHosts,
		"-t",
		[]string{
			"1.1.1.1",
			"8.8.8.8",
			"google.com",
			"wikipedia.org",
		},
		"Target hosts (DNS or IP4) to measure for connectivity")

	var metricsHost string
	flag.StringVar(&promClientHost,
		"-m",
		":2112",
		"Host on which to serve Prometheus metrics",
	)

	var methodFallover bool
	flag.BoolVar(&methodFallover,
		"-f",
		true,
		"Only measure the first target host and fallover to other following target hosts if the measurement fails (incompatible with -a)")

	var methodAll bool
	flag.BoolVar(&methodAll,
		"-a",
		false,
		"Measure all target hosts (incompatible with -f)")

	if methodFallover == true && methodAll == true {
		die(fmt.Errorf("options -f (fallover) and -a (all) cannot both be provided"))
	}

	var pingMs int
	flag.IntVar(&pingMs,
		"-p",
		10,
		fmt.Sprintf("Interval in milliseconds at which to perform the ping measurement. Will perform %d ping(s). A value of -1 disables this test.", PING_COUNT))

	check(flag.Parse(), "failed to parse command line options")

	// Monitor target hosts via prometheus
	if pingMs > 0 {
		// Setup prometheus metric
		pingRtt := prom.NewHistogram(prom.GaugeOpts{
			Name: "ping_rtt_ms",
			Help: "Round trip time for a target host in milliseconds ",
		})
		pingFailures := prom.NewCounter(prom.CounterOpts{
			Name: "ping_failures",
			Help: "Failures in pings for target hosts",
		})

		prom.MustRegister(pingRtt)
		prom.MustRegister(pingFailures)

		// Perform measurement
		pingers := []ping.Pinger{}
		for _, host := range targetHosts {
			pinger, err := ping.NewPinger(host)
			check(err, fmt.Sprintf("failed to create pinger for \"%s\"", host))
			pinger.Count = PING_COUNT

			pingers = append(pingers, pinger)
		}

		go func() {
			for _, pinger := range pingers {
				err := pinger.Run()
				if err != nil {
					// Failed to ping, don't record ping statistics, but do record the failure
					log.Warnf("failed to ping host \"%s\": %s", pinger.Addr(), err.Error())
					pingFailures.With(prom.Labels{
						"target_host": pinger.Addr(),
					}).Inc()
					continue
				}

				// Record ping round trip time
				stats := pinger.Statistics()

				pingRtt.With(prom.Labels{
					"target_host": pinger.Addr(),
				}).Set(stats.AvgRtt)

				// If in fallover mode
				if methodFallover {
					// We just measured one host successfully so stop measuring
					break
				}
			}

			// Sleep after measurement
			time.Sleep(pingMs)
		}()
	}

	// Ensure at least one metric is being recorded
	if pingMs < 0 {
		die(fmt.Errorf("at least one metrics must be selected to record (one of: -p)"))
	}

	http.Handle("/metrics", promhttp.Handler())
	err := http.ListenAndServe(metricsHost, nil)
	if err != http.ErrServerClosed {
		die(fmt.Errorf("failed to run http Prometheus metrics server on \"%s\"", metricsHost))
	}
}
