#!/bin/bash

# Are we updating a running OpenShift? True if first arg of the script is "update"
# Other args are ignored
[[ $1 == update ]] && update=true || update=false;

# "Update" related consistency checks
function update_conf{
  i=$(grep is_update manifests/configure.pp)
  
  if [[ $i == '' && $update == "true" ]]; then
    echo "ERROR: you are updating, but something is wrong in manifests/configure.pp. Aborting"
    exit 1
  elif [[ `grep false <(echo $i)` ]]; then
      echo "ERROR: you are updating, but you have declared it in manifests/configure.pp. Aborting"
      exit 1
  else
    return 0
  fi
}

touch /var/log/origin-setup.log
# Install EPEL repo
/bin/rpm -ivh http://ftp-stud.hs-esslingen.de/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Update the system
yum update -y                                          | tee -a /var/log/origin-setup.log

# Install puppetlabs repo
/bin/rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm

# Install latest puppet and fucter from puppetlabs repo
yum install -y puppet facter

# Now remove puppetlabs repo: conflicts happened
/bin/rpm -e $(rpm -qa | grep -i puppetlabs-release)

# Required puppet modules
/usr/bin/puppet module install puppetlabs/stdlib       | tee -a /var/log/origin-setup.log
/usr/bin/puppet module install puppetlabs/ntp          | tee -a /var/log/origin-setup.log

# Uninstall OS module if present
/usr/bin/puppet module uninstall openshift/openshift_origin          | tee -a /var/log/origin-setup.log

# Exec our puppet scripts
if [[ $update == "true" ]]; then
  update_conf
  /usr/bin/puppet apply --verbose /etc/puppet/modules/openshift_origin/test/manifests/configure.pp | tee -a /var/log/origin-setup.log
else
  /usr/bin/puppet apply --verbose /etc/puppet/modules/openshift_origin/test/manifests/init.pp      | tee -a /var/log/origin-setup.log
  /usr/bin/puppet apply --verbose /etc/puppet/modules/openshift_origin/test/manifests/configure.pp | tee -a /var/log/origin-setup.log
fi

# restart services
/sbin/service network restart                        | tee -a /var/log/origin-setup.log
/sbin/service activemq restart                       | tee -a /var/log/origin-setup.log
/sbin/service cgconfig restart                       | tee -a /var/log/origin-setup.log
/sbin/service cgred restart                           | tee -a /var/log/origin-setup.log
sleep 5
/sbin/service openshift-cgroups restart              | tee -a /var/log/origin-setup.log
/sbin/service httpd restart                          | tee -a /var/log/origin-setup.log
/sbin/service openshift-broker restart               | tee -a /var/log/origin-setup.log
/sbin/service openshift-node-web-proxy restart       | tee -a /var/log/origin-setup.log
/sbin/service mcollective restart                    | tee -a /var/log/origin-setup.log
/sbin/service named restart                          | tee -a /var/log/origin-setup.log

# If we are updating than register the broker DNS record and restart named
if [[ $update == "true" ]]; then
  hostname=$(hostname)
  usr/sbin/oo-register-dns -k /var/named/${hostname#*.}.key -d ${hostname#*.} -h ${hostname%%.*} -n $(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')       | tee -a /var/log/origin-setup.log
  sbin/service named restart                          | tee -a /var/log/origin-setup.log
fi
