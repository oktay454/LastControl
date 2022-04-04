## LastControl-Handbook / User Guide
The document contains detailed information about the use for the LastControl

<br>

- [1. Installation and Usage](#1-installation)
- [2. Reporting](#2-reporting)<br>
  The "Checking Result" explanations in the LastControl Handbook guide you by answering the following quesions.<br>
  - [If Ram Usage is reported](#-ram_usage_is_reported)<br>
  - [If Swap Usage is reported](#-swap_usage_is_reported)<br>
  - [If Disk Usage is reported](#-disk_usage_is_reported)<br>
  - [Using the most Resource](#-using_the_most_resource)<br>
  - [Using the most Ram](#-using_the_most_ram)<br>
  - [Using the most Cpu](#-using_the_most_cpu)<br>
  - [If Update Check is reported](#-update_check_is_reported)<br>
  - [If Package Check is reported](#-package_check_is_reported)<br>
  - [If Log4j Usage is reported](#-log4j_usage_is_reported)<br>
---

## 1. Installation

**Requirements**<br>
It works in Debian environment. Desktop environment is not required.<br>

**Installation**<br>
Use LastControl with root user
```sh
$ wget https://raw.githubusercontent.com/eesmer/LastControl/main/lastcontrol-installer.sh
$ bash lastcontrol-installer.sh
```
**Usage**<br>
**Access Page:** http://$LASTCONTROL_IP

**add/remove machine**
```sh
$ vim /usr/local/lastcontrol/hostlist
```
In this file, one machine is written per line.<br>
Each machine must be written with the machine name.
(example: debianhost1, client_99) <br>
<br>
LastControl should be able to reach the target machine by hostname.
If you cannot use DNS;<br>
Add the target machine to the **/etc/hosts file** on the LastControl machine.

**install ssh-key (lastcontrol.pub)**
LastControl uses ssh-key to access machines. The ssh-key file is created during the installation of the LastControl machine.<br>
You can install the LastControl ssh-key file as follows to access the added machines.
```sh
$ wget http://$LASTCONTROL_IP/lastcontrol/lastcontrol.pub
$ cat lastcontrol.pub >> /root/.ssh/authorized_keys
```
**How it works**<br>
It runs periodically every 3 hours.<br>
If you want to trigger the operation manually;<br>
```sh
$ systemctl restart lastcontrol.service
```

## 2. Reporting
---
### -Ram_Usage_is_Reported
---
LastControl reports if the system's memory usage is greater than 50%. <br>
<br>
In Linux systems, the system takes all of the physical memory and distributes it according to the service it provides. <br>
When the machine is out of memory, running processes are abruptly terminated and this is a major issue. <br>
These interrupt the service provided by the machine. <br>
<br>
You can control it with the following tools or commands; <br>
**free -h** <br>
To understand this output correctly; <br>
You should be able to distinguish between the memory used in the application and the cache. <br>
You should remember that the cache takes physical memory for faster access and at the application level this is free memory. <br>
**top** <br>
With this program, you can observe the resource used by an application or process. <br>
**grep -i -r 'out of memory' /var/log/** <br>
This command will list if there is an "out of memory" record in the logs under the /var/log directory. <br>

## Extras
These notes contain additional information for this topic. It is not a recommendation for use or solution. <br>
<br>
**OOM Score:** <br>
Linux, keeps a score for each running process to kill in case of memory shortage.(/proc/<pid>/oom_score) <br>
The process to be terminated when the system is out of memory is selected according to the high of this score. <br>
<br>
Typically, non-critical and non-memory applications will output oom_score of 0. <br>
Yes, if ram usage and oom_score are high; In the first problem, that process is terminated. (example: mysql process) <br>
<br>

```sh
$ ps aux | grep <process name>
```
```sh
$ cat /proc/<pid>/oom_score  
```
If you cannot produce a permanent solution instantly and the system memory is exhausted; <br>
The kill feature can be disabled for the critical process. <br>
(This is obviously not a good idea. You may not have met Kernel Panic before. We're just learning more now. (: ) <br>
For this, it is necessary to change the system's overcommit calls. <br>
<br>
You can list all parameters with **sysctl -a** <br>
sysctl allows you to set some kernel-specific parameters without rebooting the system. <br>
<br>
vm.overcommit_memory and vm.overcommit_ratio are parameters used to check system memory. <br>
<br>
- With vm.overcommit_memory=2, it is not allowed to exceed the physical ram percentage for the process.
- With vm.overcommit_memory=1, the process can request as much memory as it deems necessary. (This may be more than physical memory.)
- With vm.overcommit_ratio=100, all physical memory is allowed to be used.

```sh
$ sysctl -w vm.overcommit_memory=2
```
```sh
$ sysctl -w vm.overcommit_ratio=100 
```
for permanent setting <br>
```sh
$ vim /etc/sysctl.conf
```
**Additional information:** <br>
Linux systems often allow processes to request more memory than is idle on the system to improve our memory usage. <br>
In such a case, if there is an insufficient memory problem in the system, the process is terminated. oom_score is kept as used information here.
<br>
Linux intentionally caches data on disk to increase system responsiveness. Cached memory is available for each application. <br>
So don't be surprised by the ram usage output from the free -m command. <br>
https://www.linuxatemyram.com/
<br>
<br>
**Conclusion:** In fact, if LastControl reports this situation frequently; <br>
This means that the resource is insufficient for the service provided by the machine. <br>
  
---
### -Swap_Usage_is_Reported
---
If LastControl reported the swap usage, the swap usage was probably required due to lack of memory. <br>
This warning is added to the report if the swap usage is not 0. <br>
<br>
The following can be used to investigate the swap usage status in the system. <br>
<br>
**smem package** <br>
On Debian based system; <br>
```sh
$ apt -y install smem
```
On RedHat based system; <br>
```sh
$ yum -y install smem
(from epel-release repository)
```
**smem** <br>
Lists swap usage per PID,User and process <br>
**PID &nbsp; User &nbsp; Command &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Swap &nbsp; USS &nbsp; PSS &nbsp; RSS** <br>
461 &nbsp; root &nbsp; /sbin/agetty -o -p -- \u --  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; &nbsp; 316 &nbsp; 414 &nbsp; 2064 <br>
394 &nbsp; root &nbsp; /usr/sbin/cron -f &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; 360 &nbsp; 604 &nbsp; 2736 <br>
360 &nbsp; messagebus &nbsp; /usr/bin/dbus-daemon --syst &nbsp; &nbsp; 0 &nbsp; &nbsp; 1080 &nbsp; 1506 &nbsp; 4324 <br>
3909 &nbsp; www-data &nbsp; /usr/sbin/apache2 -k start &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; 200 &nbsp; 1617 &nbsp; 11164 <br>
3910 &nbsp; www-data &nbsp; /usr/sbin/apache2 -k start &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; 200 &nbsp; 1617 &nbsp; 11164 <br>
479 &nbsp; ntp &nbsp; &nbsp; /usr/sbin/ntpd -p /var/run/ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; 1372 &nbsp; 1658 &nbsp; 4308 <br>
187 &nbsp; postfix &nbsp; qmgr -l -t unix -u &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; 1176 &nbsp; 1208 &nbsp; 1620 <br>
635 &nbsp; dbus &nbsp; /usr/bin/dbus-daemon --syst &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 192 &nbsp; &nbsp; 792 &nbsp; 928 &nbsp; 1612 <br>
<br>

**smem -u** <br>
With the parameter, the swap usage is listed on a per user basis. <br>
**smem -m** <br>
With the parameter, swap usage dump of each PID can be taken. <br>
**smem -p** <br>
With the parameter, PID, user, and used command basis usage is listed show a percentage. <br>
**smem --processfilter="apache"** <br>
apache process can be filtered <br>
<br>
https://linux.die.net/man/8/smem
<br>
<br>
**Conclusion:** In fact, if LastControl reports this situation frequently; <br>
This means that the resource is insufficient for the service provided by the machine. <br>

---
### -Disk_Usage_is_Reported
---
LastControl reports if the disk usage on which the system is installed is more than 50%. <br>
You should check the system or increase the space in case the remaining disk size is running out quickly. <br>
<br>
If the usage rate of disk size is higher than expected; these can be controlled by the following operations. <br>
<br>
The following command will list all directories sizes <br>
```sh
$ du -hsx /* | sort -rh
```
**.tar.gz .tar.bz archive files** <br>
You can list the tar.gz and tar.bz compressed files in the system. <br>
(usually these are files that have been archived or transferred for one-time use) <br>

```sh
$ find "tar.gz"| grep -v ' ' | xargs du -sch | sort -nk1 | grep 'M\|G'
```
```sh
$ find "tar.bz"| grep -v ' ' | xargs du -sch | sort -nk1 | grep 'M\|G'
```
**error_log** <br>
Reporting an error can enlarge the error_log file and fill the disk. <br>
```sh
$ find "error_log"| grep -v ' ' | xargs du -sch | sort -nk1 | grep 'M\|G'
```
If error_log exists and grows; It is enough to correct the error and delete the file. <br>
<br>

**Check old kernel files** <br>
On Debian based systems; <br>
```sh
$ dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d'
```
```sh
$ apt autoremove --purge
```
On RedHat based systems; <br>
```sh
$ rpm -qa |grep 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d'
```
**List of kernel modules** <br>
```sh
$ find / -xdev -name core -ls -o  -path "/lib*" -prune
```
<br>

**Conclusion:** The 50% rate may not matter if it does not continue to grow. For manual deletions though, the above can be considered.

---
### -Using_the_most_Resource
### -Using_the_most_Ram
### -Using_the_most_Cpu
---

**Using the most Resource:** Among the services running on the system, the process that uses the most resource is displayed instantly. <br>
**Using the most Ram:** Among the services running on the system, the process that uses the most RAM is displayed instantly. <br>
**Using the most Cpu:** Among the services running on the system, the process that uses the most CPU is displayed instantly. <br>
<br>

Lists the most resource uses services (top 10) <br>
```sh
$ top -b -n1 | head -17 | tail -10
```
---
### -Update_Check_is_Reported
---
If LastControl has reported that the system has an update system update is required. <br>
Systems that have not been updated for a long time cause problems in version transitions. <br>
<br>
In addition; It is very important to use the new packages and the ones that have been corrected according to some problems in the system.(for security and stability) <br>
In that case; Continuous Update <br>

<br>

Only Windows users don't care and are afraid to update. <br>
They usually do not have an update plan. <br>

Configuration or customization may be preventing you from updating the system. <br>
Attention!! The longer this goes on, the bigger the problem. <br>
  
<br>
  
**Update Check** <br>
On Debian based systems; <br>
```sh
$ apt list --upgradable
```
On RedHat based systems; <br>
```sh
$ yum check-update or dnf check-update
```
**Update Command** <br>
On Debian based systems; <br>
```sh
$ apt update && apt upgrade
```
**apt dist-upgrade vs apt full-upgrade** <br>

On RedHat based systems; <br>
```sh
$ dnf update or yum update
```
--- 
### -Package_Check_is_Reported
---
If LastControl reported corrupt packages on the system; <br>
these broken packages should be installed or removed without any problems. <br>
Otherwise, there will be a problem with the package installation or update process. <br>
<br>
Package installations on Linux systems should be done with distribution-specific package managers. (from the repository and with apt or yum,dnf) <br>
Package managers ensure that the process is done properly by fixing dependency and installation problems or by specifying if there is an obstacle to installation. <br>
In some exceptional cases; if the installation or uninstallation is causing problems and no fix is made, it will refuse to do a new install permanently (until it is fixed). This is for system stability. <br>

In such a case, a new installation or update may not be possible. <br>
This is caused by manual installation or uninstalling/deleting without using the package manager. <br>

Therefore it is important to install, uninstall and update from the distribution's repository. <br>
Thus, a stable system is used with the skill of the package manager. (unconsciously .deb or .rpm package installs) <br>

When you receive this notification, you can take the following actions. <br>

<br>

**Debian based systems** <br>
```sh
$ apt --fix-missing update
```
You can try to fix the installation problem with the command. Also, apt update should output fine. <br>
```sh
$ apt install -f
```
command searches the system for broken packages and tries to fix them. <br>

One can also use dpkg. <br>
```sh
$ dpkg --configure -a
```
Packages that have been opened but need to be configured are checked and the configuration is attempted to be completed. <br>
```sh
$ dpkg -l | grep ^..r
```
Packages marked with a configuration requirement are listed. <br>
If this command gives a output, it must be corrected. <br>
On non-problem systems this command should output blank. <br>
```sh
$ dpkg --remove --force-remove-reinstreq
```
Attempts to delete all corrupted packages. <br>
<br>
**RedHat based systems** <br>
```sh
$ rpm -Va
```
All packages in the system are checked. <br>
```sh
$ dnf --refresh reinstall $PACKAGE_NAME
```
Reinstallation is attempted for the broken package. <br>
<br>
**Conclusion:** Package managers are pretty good for hassle-free package installation and removal. <br>
Do not install from random .deb or .rpm packages.<br>
<br>
E.g; Installation of .deb or .rpm packages cannot be updated with the distribution's package manager. <br>
If there are such manual installations in the system, since manual installations cannot be updated after 1-2 updates with the package manager, all packages will not be synchronized and installation / uninstallation / update problems will occur in the system. <br>

---
### -Log4j_Usage_is_Reported
---
Log4j is a java logging library. It has a very widespread use. <br>
This use carries risks that can be exploited as described in CVE-2021-44228 <br>

<br>

Log4j 2.15 and earlier versions are vulnerable to this attack as they contain the corresponding feature. <br>
Log4j 1.x versions do not support JNDI, so it is not affected if the JMSAppender class is not enabled. <br>

<br>

You must provide configuration and update and fix for the application using the log4j library. <br>
Consider the resources below. <br>
https://logging.apache.org/log4j/2.x/security.html <br>
https://www.slf4j.org/log4shell.html <br>
https://reload4j.qos.ch/ <br>

<br>

LastControl also performs a log scan on the machine where it detects log4j usage. <br>
From this output, you can see if there has been an attempt to exploit the vulnerability. (general-report LOGs tab) <br>

