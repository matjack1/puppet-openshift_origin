#!/bin/bash
touch /var/log/origin-setup.log
/bin/rpm -ivh http://ftp-stud.hs-esslingen.de/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum update -y                                          | tee -a /var/log/origin-setup.log
/bin/rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm
yum install -y puppet facter
/bin/rpm -e $(rpm -qa | grep -i puppetlabs-release)
/usr/bin/puppet module install puppetlabs/stdlib       | tee -a /var/log/origin-setup.log
/usr/bin/puppet module install puppetlabs/ntp          | tee -a /var/log/origin-setup.log
/usr/bin/puppet module uninstall openshift/openshift_origin          | tee -a /var/log/origin-setup.log
/usr/bin/puppet apply --verbose /root/puppet-openshift_origin/test/manifests/init.pp      | tee -a /var/log/origin-setup.log
/usr/bin/puppet apply --verbose /root/puppet-openshift_origin/test/manifests/configure.pp | tee -a /var/log/origin-setup.log

/sbin/service network restart                        | tee -a /var/log/origin-setup.log
/sbin/service activemq restart                       | tee -a /var/log/origin-setup.log
/sbin/service cgconfig restart                       | tee -a /var/log/origin-setup.log
/sbin/service cgred restart                           | tee -a /var/log/origin-setup.log
sleep 5
/sbin/service openshift-cgroups restart              | tee -a /var/log/origin-setup.log
/sbin/service httpd restart                          | tee -a /var/log/origin-setup.log
/sbin/service openshift-broker restart               | tee -a /var/log/origin-setup.log
/sbin/service openshift-node-web-proxy restart       | tee -a /var/log/origin-setup.log
/sbin/service named restart                          | tee -a /var/log/origin-setup.log
/sbin/service mcollective restart                    | tee -a /var/log/origin-setup.log
/usr/sbin/oo-register-dns -h broker -n $(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')       | tee -a /var/log/origin-setup.log
