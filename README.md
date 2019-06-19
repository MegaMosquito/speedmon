# speedmon

A Wide Area Network (WAN) speed monitor daemon that uses the Speedtest-CLI library from speedtest.net.

It runs speed tests on a clock, and stuffs the results into a circular buffer in CouchDb that the web page visualizer pulls from.

