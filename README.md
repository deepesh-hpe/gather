# gatherServerDiagnostics for k8s nodes 
This script is useful for collecting diagnostics for all threads running on the system

you run the scripts in below order. Note: make sure you have tunned the configurable before starting the script. 
- gatherServerDiagnostics.sh to start collection, 
- stopServerDiagnostics.sh to stop collection, 
- packageServerDiagnostics.sh to zip up all the diagnostic files to one archive file, 
- cleanupServerDiagnostics.sh to delete all the diagnostic output files created by gatherServerDiagnostics.sh

The exact set of diagnostics gathered and the periodicity of collection is set in the gatherServerDiagnostics.sh script, adjust the values according to whatever metrics you want to collect as relevant to the issue you are working on.

The configurable fields are:

- lightPollingInterval - Controls how many seconds between gathering samples of "light" metrics, e.g. ones that are trivial to gather and can be gathered as often as once a second without a risk of impacting the node where it is running
- heavyPollingInterval - Controls how many seconds between gathering samples of "heavy" metrics, e.g. ones that requires non-trivial CPU/disk/memory usage to gather.  The amount required to gather one iteration of diagnostics is generally rather small, but gathering these every second can use an amount of system resources that can impact other running processes.  The effect shouldn't be severe but it is non-trivial.

- gatherAllThreads - Gather OS level per-thread diagnostics for all threads running on the system
- gatherAllProcesses - Gather OS level per-process diagnostics for all processes running on the system
- gatherHWResources - Gather system level hardware resource utilization statistics
- gatherNetstatPan - Gather the output of "netstat -pan" periodically
- gatherNetstatPanForMapR - Gather the output of "netstat -pan" but only save info for TCP connections to the MFS or CLDB processes
