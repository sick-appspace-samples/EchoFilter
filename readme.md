## EchoFilter

Applying echo filter on scans read from a file.

### Description

The sample shows the effect of the echo filter on scans read from a file.
Every time a new scan is read from the given resource file the Lua function "handleOnNewScan"
is called. The next scan, passed as argument, is investigated in the following ways:
1. The number of beams with non-zero distances are counted for all available echoes and the
   percentage is printed (see function "countNonZeroBeams").
2. The input scan is filtered with the EchoFilter with option "LAST". For each beam, this copies
   the last echo with non-zero distance to the first echo. All other echoes are removed.
3. The number and the percentage of non-zero distances are counted and printed
   (see function "countNonZeroBeams")
4. The changes in distance values between the first echo of the original scan and the filtered scan
   (which has now only one echo) are shown (see function "compareScans").

### How to run

Starting this sample is possible either by running the app (F5) or
debugging (F7+F10). Output is printed to the console. The playback stops after the
last scan in the file. To replay, the sample must be restarted.
To run this sample, a device with AppEngine >= 2.5.0 is required.

### Implementation

To run with real device data, the file provider has to be exchanged with the
appropriate scan provider.

### Topics

algorithm, scan, filtering, sample, sick-appspace
