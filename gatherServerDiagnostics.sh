#!/bin/bash

logDir=/tmp/logs
lightPollingInterval=5
heavyPollingInterval=20

gatherAllThreads=0
gatherAllProcesses=1
gatherHWResources=1

gatherNetstatPan=0

if [ "$(ps -ef | grep -w "gatherServerDiagnostics.sh daemon" | grep -v -w -e grep | tr -s '  ' ' ' | cut -f 2-3 -d " " | grep -v -w -e $$ | wc -l)" -ne 0 ]; then
  echo "ERROR: This script is already running!"
  ps -ef | grep -w "gatherServerDiagnostics.sh daemon" | grep -v -w -e grep
  exit 1
fi

if [ "$1" = "daemon" ]; then

  topRunning=0
  gutsRunning=0
  topPid=-1
  gutsPid=-1
  mfsPid=-1
  iostatPid=-1
  mpstatPid=-1
  vmstatPid=-1
  topThreadsPid=-1
  topProcessesPid=-1
  nextLightPolling=0
  nextHeavyPolling=0
  
  while true; do
    now=$(date +%s)
    if [ "$now" -ge "$nextHeavyPolling" ]; then
      nextHeavyPolling=$(( $now + $heavyPollingInterval ))
      if [ "$gatherNetstatPan" -eq 1 ]; then
        netstat -pan | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> "$logDir/netstat.pan.$HOSTNAME.out" 2>&1 &
      fi
      if [ "$gatherHWResources" -eq 1 ]; then
        if [ ! -d "/proc/$iostatPid" ]; then
          iostat -cdmx "$lightPollingInterval"  | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> "$logDir/iostat.$HOSTNAME.out" 2>&1 &
          ret=$?
          iostatPid=$!
          if [ "$ret" -ne 0 ]; then
            iostatPid=-1
          fi
        fi
        if [ ! -d "/proc/$mpstatPid" ]; then
          mpstat -P ALL "$lightPollingInterval" | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> "$logDir/mpstat.$HOSTNAME.out" 2>&1 &
          ret=$?
          mpstatPid=$!
          if [ "$ret" -ne 0 ]; then
            mpstatPid=-1
          fi
        fi
        if [ ! -d "/proc/$vmstatPid" ]; then
          vmstat -n -SM "$lightPollingInterval" | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> "$logDir/vmstat.$HOSTNAME.out" 2>&1 &
          ret=$?
          vmstatPid=$!
          if [ "$ret" -ne 0 ]; then
            vmstatPid=-1
          fi
        fi
      fi
      if [ "$gatherAllThreads" -eq 1 ]; then
        if [ ! -d "/proc/$topThreadsPid" ]; then
          top -b -H -d "$heavyPollingInterval" | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> "$logDir/top.threads.$HOSTNAME.out" 2>&1 &
          ret=$?
          topThreadsPid=$!
          if [ "$ret" -ne 0 ]; then
            topThreadsPid=-1
          fi
        fi
      fi
      if [ "$gatherAllProcesses" -eq 1 ]; then
        if [ ! -d "/proc/$topProcessesPid" ]; then
          top -b -d "$heavyPollingInterval" | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' | grep -v -e " 0\.0 *0\.0 " >> "$logDir/top.processes.$HOSTNAME.out" 2>&1 &
          ret=$?
          topProcessesPid=$!
          if [ "$ret" -ne 0 ]; then
            topProcessesPid=-1
          fi
        fi
      fi
        
      if [ "$gatherGuts" -eq 1 ] || [ "$gatherMfsThreadsCpu" -eq 1 ]; then
        newMfsPid=$(/sbin/pidof mfs)
        if [ "$topRunning" -eq 1 ] && [ ! -d "/proc/$topPid" ]; then
          topRunning=0
        fi
        if [ "$gutsRunning" -eq 1 ] && [ ! -d "/proc/$gutsPid" ]; then
          gutsRunning=0
        fi
      fi
    fi
    sleep 1
  done


else 
  echo Launching collection daemon
  nohup "$0" daemon < /dev/null > "$logDir/gatherServerDiagnostics.$HOSTNAME.out" 2>&1 &
fi

