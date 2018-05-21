#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {	
	// Counters
	int lastT = -1;
	int deltaT = 0;

	int failed = 0;
	int succeeded = 0;

	float latencyTotal = 0.0;

	int numTests = 0;

	// For each line
	size_t buffSize;
	char *buff = NULL;

	while (getline(&buff, &buffSize, stdin) > 0) {
		// Check if site header line
		if (buff[0] == '#') {
			continue;
		}

		// Extract test result parts
		int i = 0;
		char *subtok = strtok(buff, " ");

		int testT = -1;
		float testLatency = 0.0;

		while (subtok !=NULL) {
			if (i == 0) { // If test time
				char *endptr;
				int inttok = strtol(subtok, &endptr, 10);

				if (endptr == subtok) { // Check parse error
					printf("Error parsing test time: %s, errno: %d\n", subtok, inttok);
					return 1;
				}

				// Set lastT
				testT = inttok;
			} else if (i == 1) {  // If test result
				// If successfull test
				char *endptr;
				int inttok = strtol(subtok, &endptr, 10);

				if (endptr == subtok) { // Check parse error
					printf("Error parsing test status: %s, errno: %d\n", subtok, inttok);
					return 1;
				}

				if (inttok == 1) {
					succeeded++;
			 	} else if (inttok == 0) {
					failed++;
				} else {
					printf("Error unknown test result value %d\n", inttok);
					return 1;
				}
			} else if (i == 3) { // If latency
				testLatency = atof(subtok);
				latencyTotal += testLatency;
			}

			subtok = strtok(NULL, " ");
			i++;
		}

		// Determine if script was paused
		int testDt = testT - lastT;
		if (testDt < 120) {
			deltaT += testDt;
		}

		lastT = testT;
		numTests++;
	}

	// Print results
	// -- -- Calculate percentages
	float failedPercent = 0.0;
	float succeededPercent = 0.0;

	if (numTests != 0) {
		failedPercent = ((float)failed / (float)numTests) * 100;
		succeededPercent = ((float)succeeded / (float)numTests) * 100;
	}

	// -- -- Calculate duration
	int hours = deltaT / 3600;
	int minutes = (deltaT % 3600) / 60;
	int seconds = deltaT % 60;

	// -- -- Calculate average latency
	float avrgLatency = latencyTotal / (float)numTests;
	
	// -- -- Output
	printf("Total: %d, Failed: %.3f% (%d), Succeeded: %.3f% (%d)\n", numTests, failedPercent, failed, succeededPercent, succeeded);
	printf("Ruuning time: %d:%d:%d, Avrg latency: %.3f ms\n", hours, minutes, seconds, avrgLatency);

	return 0;
}
