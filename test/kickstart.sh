#!/bin/bash
    touch /var/log/origin-setup.log; \
yum update -y                                          | tee -a /var/log/origin-setup.log; \
/usr/bin/puppet module uninstall openshift/openshift_origin          | tee -a /var/log/origin-setup.log; \
/usr/bin/puppet module install openshift/openshift_origin            | tee -a /var/log/origin-setup.log; \
/usr/bin/puppet apply --verbose /root/puppet-openshift_origin/test/manifests/init.pp      | tee -a /var/log/origin-setup.log; \
/usr/bin/puppet apply --verbose /root/puppet-openshift_origin/test/manifests/configure.pp | tee -a /var/log/origin-setup.log; \

/sbin/service network restart                        | tee -a /var/log/origin-setup.log; \
/sbin/service activemq restart                       | tee -a /var/log/origin-setup.log; \
/sbin/service cgconfig restart                       | tee -a /var/log/origin-setup.log; \
/sbin/service cgred restart                           | tee -a /var/log/origin-setup.log; \
sleep 5; \
/sbin/service openshift-cgroups restart              | tee -a /var/log/origin-setup.log; \
/sbin/service httpd restart                          | tee -a /var/log/origin-setup.log; \
/sbin/service openshift-broker restart               | tee -a /var/log/origin-setup.log; \
/sbin/service openshift-node-web-proxy restart       | tee -a /var/log/origin-setup.log; \
/sbin/service named restart                          | tee -a /var/log/origin-setup.log; \
/sbin/service mcollective restart                    | tee -a /var/log/origin-setup.log; \
/usr/sbin/oo-register-dns -h broker -n 127.0.0.1       | tee -a /var/log/origin-setup.log;
