#!/bin/bash

logDir=/opt/mapr/logs

rm -rf $logDir/netstat.pan.$HOSTNAME.out  $logDir/gatherServerDiagnostics.$HOSTNAME.out  $logDir/iostat.$HOSTNAME.out $logDir/mpstat.$HOSTNAME.out  $logDir/top.processes.$HOSTNAME.out $logDir/top.threads.$HOSTNAME.out $logDir/vmstat.$HOSTNAME.out 

echo Cleaned up diagnostics from $logDir
