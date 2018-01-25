#!/bin/sh
################################################################################
# This script sync Latest RedHat Repos to /home/REPO/ directory and make       #
# tar.gz archive which will be ready to distribute to secure environment.      #
# It's required RH7 machine which MUST have direct access to the internet      #
# All repos must be registered and subscribed to RedHat prior to run this      #
# script                                                                       #
################################################################################
###############################
###### Sergey Kharlamov  ######
###### Jan 2018          ######
###############################

###############################
##### Prepare environment #####
###############################

# Register to RHN Repo:
# subscription-manager register --username <RHN_USERNAME> --password <RHN_PASSWORD>

# Show all available REPO's
# subscription-manager list --available --all

# Subscribe to RHN Repo channels
# subscription-manager attach --pool=<POOL_ID> --pool=<POOL_ID>

echo
echo -e "\e[44m##### !!! WARNING !!! ##### !!! WARNING !!! ##### !!! WARNING !!! #####\e[0;39m"
echo -e "\e[44m#\e[0;39m"
echo -e "\e[44m#\e[0;39m \e[31mThis script will remove ALL EXISTING repos and create new one.\e[0;39m \e[44m######\e[0;39m"
echo -e "\e[44m#\e[0;39m"
echo -e "\e[44m##### !!! WARNING !!! ##### !!! WARNING !!! ##### !!! WARNING !!! #####\e[0;39m"
echo

read -p "Are you sure you want to continue <Yes/No>" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then

echo Sync job start at `date '+%Y-%m-%d-%H:%M'` > /home/REPO/repo_create.log

# Install EPEL Fresh REPO
echo
echo -e "\e[41m Installing EPEL Repo \e[0;39m"
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
echo

# Install createrepo package
echo -e "\e[41m Installing createrepo package \e[0;39m"
yum -y install createrepo
echo

# Add Gluster REPO File
echo "[centos-7-glusterfs]
name=CentOS-7-Gluster 3.13
baseurl=http://mirror.centos.org/centos/7/storage/x86_64/gluster-3.13/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage" > /etc/yum.repos.d/GlusterFS.repo

# Remove OLD stuff from previous script run job
echo -e "\e[41mCleanup environment from previous run \e[0;39m"
echo
rm -rf /home/REPO/TMP
mkdir -p /home/REPO/TMP
rm -rf /home/REPO/RHEL7
mkdir /home/REPO/RHEL7

rm -rf /home/REPO/EPEL7
mkdir /home/REPO/EPEL7

# Start syncing REPOs
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-extras-rpms REPO ##############\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-extras-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-optional-rpms REPO ############\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-optional-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rhevh-rpms REPO ###############\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rhevh-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rhn-tools-rpms REPO ###########\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rhn-tools-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rhv-4.1-rpms REPO #############\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rhv-4.1-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rpms REPO #####################\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rhv-4-mgmt-agent-rpms REPO ####\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rhv-4-mgmt-agent-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync rhel-7-server-rh-common-rpms REPO ###########\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r rhel-7-server-rh-common-rpms -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync EPEL REPO ###################################\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r epel -l -a x86_64 -n
echo
echo -e "\e[41m######################################################\e[0;39m"
echo -e "\e[41m### Sync GlusteFS REPO ###############################\e[0;39m"
echo -e "\e[41m######################################################\e[0;39m"
reposync -p /home/REPO/TMP/ -r centos-7-glusterfs -l -a x86_64 -n
echo

# Move all RPM's to correct folder
echo -e "\e[41m Moving RPMs to /home/REPO/RHEL7\e[0;39m"
mv -f /home/REPO/TMP/rhel* /home/REPO/RHEL7/
mv -f /home/REPO/TMP/epel/* /home/REPO/EPEL7/
mv -f /home/REPO/TMP/centos-7-glusterfs /home/REPO/RHEL7/
echo

# Remove TMP Directory
echo -e "\e[41m Delete /home/REPO/TMP Directory\e[0;39m"
rm -rf /home/REPO/TMP
echo

# Create repodata
echo -e "\e[41m Updating Repodata for new repo RHEL7\e[0;39m"
/usr/bin/createrepo /home/REPO/RHEL7
echo
echo -e "\e[41m Updating Repodata for new repo EPEL7\e[0;39"
/usr/bin/createrepo /home/REPO/EPEL7
echo

# Show directory structure (for debug)
echo "##### RHEL7 Folder structure #####" > /home/REPO/repo_create.log
ls -la /home/REPO/RHEL7 >> /home/REPO/repo_create.log
echo "##### EPEL7 Folder structure #####" >> /home/REPO/repo_create.log
ls -la /home/REPO/EPEL7 >> /home/REPO/repo_create.log

# Create VERSION file
echo -e "\e[41m Repo sync date to /home/REPO/VERSION\e[0;39m"
echo This REPO created `date '+%Y-%m-%d-%H:%M'` > /home/REPO/VERSION
echo This REPO created `date '+%Y-%m-%d-%H:%M'` > /home/REPO/EPEL7/VERSION
echo This REPO created `date '+%Y-%m-%d-%H:%M'` > /home/REPO/RHEL7/VERSION
echo

# Make archive which is ready to be distributed
echo -e "\e[41m Archiving new RHEL7 repo \e[0;39m"
DATE=`date '+%Y-%m-%d'`
RHEL7_REPO_ARCHIVE="RHEL7-REPO-$DATE.tar.gz"
cd /home/
tar -zcvf /home/$RHEL7_REPO_ARCHIVE REPO/RHEL7

echo -e "\e[41m Archiving new EPEL7 repo\e[0;39m"
EPEL7_REPO_ARCHIVE="EPEL7-REPO-$DATE.tar.gz"
cd /home/
tar -zcvf /home/$EPEL7_REPO_ARCHIVE REPO/EPEL7

echo -e "\e[36m#######################################################\e[0;39m"
echo -e "\e[36m#########\e[0;39m \e[31mREPO Sysncronization is done\e[0;39m \e[36m ###############\e[0;39m"
echo -e "\e[36m#######################################################\e[0;39m"
echo
echo -e "RHEL7 repo location: \e[31m/home/$RHEL7_REPO_ARCHIVE\e[0;39m"
echo -e "EPEL7 repo location: \e[31m/home/$EPEL7_REPO_ARCHIVE\e[0;39m"
echo

else
  exit 0
fi
