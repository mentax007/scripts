#!/bin/bash
################################################################################
#
# FILE:           vmMonCreator.sh
#
# CLASSIFICATION: None
#
# DESCRIPTION:    Script used to create VMs monitoring template for Centreon CLAPI
#                 This script expects to be passed a text file with the
#                 following format:
#
#                 ip_address hostname
#
#                 (Example)
#                 192.168.100.1 vm01.xxx.faa.gov
#                 192.168.100.2 vm02.xxx.faa.gov
#
# USAGE:          vmMonCreator.sh (file.txt)
#
################################################################################

#=======================================================================
# FUNCTION: createVMmon
#-----------------------------------------------------------------------
#- Creates a VM monitoring template from the parameters that are passed
#-----------------------------------------------------------------------
createVMmon () {

   # Define parameters as variables
   ipaddr=$1
   hostname=$2
   computeNode=$3

      # Continue to define parameters as variables
      firstPart=`echo $ipaddr | awk -F . '{print $1 "." $2 "." $3}' `
      vmname=`echo $hostname | awk -F . '{print $1}'`
      site=`echo $hostname | awk -F . '{print $2}' | tr [a-z] [A-Z]`
      shortname=`echo $hostname | awk -F . '{print $1}' | tr [a-z] [A-Z]`
echo "HOST;ADD;$hostname;$shortname.$site;$ipaddr;;Central;"
echo "HOST;setparam;$hostname;host_snmp_version;3"
echo "HOST;addtemplate;$hostname;generic-host"
echo "HOST;addtemplate;$hostname;SNMPv3-VM-Template"
echo "HC;addmember;$site;$hostname"

   if [ $vmname == "compute*" ]; then
      echo "HOST;setparam;$hostname;icon_image;ppm/operatingsystems-linux-snmp-OS-Linux-64.png"
   else
      echo "HOST;setparam;$hostname;icon_image;ppm/VM.png"
fi
}

########################################################################
# Main
########################################################################

# Read each line in the passed text file and feed it to the createVM function
while read -r line
do createVMmon $line
done < $1
