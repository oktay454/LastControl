#!/bin/bash

#--------------------------------------------------------
# This script,
# It produces the report of SSH Config checks.
#--------------------------------------------------------

HOST_NAME=$(hostnamectl --static)
RDIR=/usr/local/lcreports/$HOST_NAME
LOGO=/usr/local/lastcontrol/images/lastcontrol_logo.png
DATE=$(date)

# PRIVATE HOST KEY
SSHCHECK1=$(stat /etc/ssh/sshd_config |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
SSHD_ACL="Fail"
if [ "$SSHCHECK1" = 0600 ]; then SSHD_ACL="Pass"; fi

SSHCHECK2=$(stat /etc/ssh/ssh_host_rsa_key |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
RSAKEY_ACL="Fail"
if [ "$SSHCHECK2" = 0600 ]; then RSAKEY_ACL="Pass"; fi

SSHCHECK3=$(stat /etc/ssh/ssh_host_ecdsa_key |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
ECDSAKEY_ACL="Fail"
if [ "$SSHCHECK3" = 0600 ]; then ECDSAKEY_ACL="Pass"; fi

SSHCHECK4=$(stat /etc/ssh/ssh_host_ed25519_key |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
ED25519KEY_ACL="Fail"
if [ "$SSHCHECK4" = 0600 ]; then ED25519KEY_ACL="Pass"; fi

# PUBLIC HOST KEY
SSHCHECK5=$(stat /etc/ssh/ssh_host_rsa_key.pub |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
RSAKEYPUB_ACL="Fail"
if [ "$SSHCHECK5" = 0644 ]; then RSAKEYPUB_ACL="Pass"; fi

SSHCHECK6=$(stat /etc/ssh/ssh_host_ed25519_key.pub |grep "Uid:" |cut -d " " -f2 |cut -d "(" -f2 |cut -d "/" -f1)
ED25519PUB_ACL="Fail"
if [ "$SSHCHECK6" = 0644 ]; then ED25519PUB_ACL="Pass"; fi

grep ^Protocol /etc/ssh/sshd_config >> /dev/null
PROTOCOL2="Fail"
if [ "$?" = 0 ]; then PROTOCOL2="Pass"; fi

SSHCHECK7=$(sshd -T | grep loglevel |cut -d " " -f2)
LOGLEVEL="Fail"
if [ "$SSHCHECK7" = INFO ]; then LOGLEVEL="Pass"; fi

SSHCHECK8=$(sshd -T | grep x11forwarding |cut -d " " -f2)
X11FORWARD="Fail"
if [ "$SSHCHECK8" = no ]; then X11FORWARD="Pass"; fi

SSHCHECK9=$(sshd -T | grep maxauthtries |cut -d " " -f2)
MAXAUTHTRIES="Fail"
if [ "$SSHCHECK9" -lt 4 ]; then MAXAUTHTRIES="Pass"; fi

SSHCHECK10=$(sshd -T | grep ignorerhosts |cut -d " " -f2)
IGNORERHOST="Fail"
if [ "$SSHCHECK10" = yes ]; then IGNORERHOST="Pass"; fi

SSHCHECK11=$(sshd -T | grep hostbasedauthentication |cut -d " " -f2)
HOSTBASEDAUTH="Fail"
if [ "$SSHCHECK11" = no ]; then HOSTBASEDAUTH="Pass"; fi

SSHCHECK12=$(sshd -T | grep permitrootlogin |cut -d " " -f2)
ROOTLOGIN="Fail"
if [ "$SSHCHECK12" = no ]; then ROOTLOGIN="Pass"; fi

SSHCHECK13=$(sshd -T | grep permitemptypasswords |cut -d " " -f2)
EMPTYPASS="Fail"
if [ "$SSHCHECK13" = no ]; then EMPTYPASS="Pass"; fi

SSHCHECK14=$(sshd -T | grep permituserenvironment |cut -d " " -f2)
PERMITUSERENV="Fail"
if [ "$SSHCHECK14" = no ]; then PERMITUSERENV="Pass"; fi


cat > $RDIR/$HOST_NAME-sshreport.md<< EOF

---
title: SSH Configuration Report
geometry: "left=3cm,right=3cm,top=0.5cm,bottom=1cm"
---

![]($LOGO){ width=25% }

Date     : $DATE

Hostname : $HOST_NAME

---

SSHD Config File ACL Check :
 ~ $SSHD_ACL

ECDSA Public Key ACL Check :
 ~ $ECDSAKEY_ACL

RSA Public Key ACL Check :
 ~ $RSAKEYPUB_ACL

RSA Private Key ACL Check :
 ~ $RSAKEY_ACL

ED25519 Public Key ACL Check :
 ~ $ED25519PUB_ACL

ED25519 Private Key ACL Check :
 ~ $ED25519KEY_ACL

Protocol2 Usage Check :
 ~ $PROTOCOL2

Log Level (info) Check :
 ~ $LOGLEVEL

X11 Forwarding Check :
 ~ $X11FORWARD

Max. Auth Tries Check :
 ~ $MAXAUTHTRIES

Ignorer Host Check :
 ~ $IGNORERHOST

Host Based Authentication :
 ~ $HOSTBASEDAUTH

Permit Root Login :
 ~ $ROOTLOGIN 

Permit Empty Password :
 ~ $EMPTYPASS

Permit User Environment :
 ~ $PERMITUSERENV

---
EOF

cat > $RDIR/$HOST_NAME-sshreport.txt << EOF
====================================================================================================
:::. $HOST_NAME SSH CONFIG REPORT :::.
====================================================================================================
$DATE

----------------------------------------------------------------------------------------------------
SSH Settings
----------------------------------------------------------------------------------------------------
SSHD Config File ACL Check     |$SSHD_ACL
ECDSA Public Key ACL Check     |$ECDSAKEY_ACL
RSA Public Key ACL Check       |$RSAKEYPUB_ACL
RSA Private Key ACL Check      |$RSAKEY_ACL
ED25519 Public Key ACL Check   |$ED25519PUB_ACL
ED25519 Private Key ACL Check  |$ED25519KEY_ACL
Protocol2 Usage Check          |$PROTOCOL2
Log Level (info) Check         |$LOGLEVEL
X11 Forwarding Check           |$X11FORWARD
Max. Auth Tries Check          |$MAXAUTHTRIES
Ignorer Host Check             |$IGNORERHOST
Host Based Authentication      |$HOSTBASEDAUTH
Permit Root Login              |$ROOTLOGIN 
Permit Empty Password          |$EMPTYPASS
Permit User Environment        |$PERMITUSERENV
====================================================================================================
EOF

#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#echo "::: SSH Access Logs (Accepted) :::" >> $RDIR/$HOST_NAME.sshreport
#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#
#if [ "$REP" = APT ]; then
#	find /var/log -name 'secure*' -type f -exec sh -c "cat {} | egrep -i 'Accepted'" \; |grep "sshd" >> $RDIR/$HOST_NAME.sshreport
#elif [ "$REP" = YUM ]; then
#	find /var/log -name 'secure*' -type f -exec sh -c "cat {} | egrep -i 'Accepted'" \; |grep "sshd" >> $RDIR/$HOST_NAME.sshreport
#fi
#
#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#echo "" >> $RDIR/$HOST_NAME.sshreport
#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#echo "::: SSH Access Logs (Failed) :::" >> $RDIR/$HOST_NAME.sshreport
#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#
#if [ "$REP" = APT ]; then
#	find /var/log -name 'secure*' -type f -exec sh -c "cat {} | egrep -i 'Fail'" \; |grep "sshd" >> $RDIR/$HOST_NAME.sshreport
#elif [ "$REP" = YUM ]; then
#	find /var/log -name 'secure*' -type f -exec sh -c "cat {} | egrep -i 'Fail'" \; |grep "sshd" >> $RDIR/$HOST_NAME.sshreport
#fi
#
#echo "----------------------------------------------------------------------------------------------------" >> $RDIR/$HOST_NAME.sshreport
#echo "====================================================================================================" >> $RDIR/$HOST_NAME.sshreport
