#!/bin/sh
sh ps_set.sh <<eof
30
0
hsxytest.7wan.com
112.65.227.79
114.80.226.153
172.16.1.21
172.16.1.21
1000

eof


sh ps_set.sh <<eof
31
1
hsxytest.7wan.com
112.65.227.79
114.80.226.153
172.16.1.21
172.16.1.21
1001

eof


sh ps_set.sh <<eof
32
2
hsxytest.7wan.com
112.65.227.79
114.80.226.153
172.16.1.21
172.16.1.21
1002

eof


