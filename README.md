# puppet-openshift_origin

# About

This module helps install [OpenShift Origin](https://openshift.redhat.com/community/open-source) Platform As A Service.
Through the declaration of the `openshift_origin` class, you can configure the OpenShift Origin Broker, Node and support
services including ActiveMQ, Qpid, MongoDB, named and OS settings including firewall, startup services, and ntp.

## Authors

* Jamey Owens
* Ben Klang
* Ben Langfeld
* Krishna Raman

# About this fork

@pioneerskies and @matjack1 are trying to modify a bit this provision script so that it should work on Centos6.x
We're glad to say that we are provisioning successfully at this point of tweaking! Hoooray!

In this fork the goal is to build a live playground on a public VPS; actually we provision the ecosystem on the bare OS, without vagrant, but with a little kickstart.sh script. And all of this is done on top of Centos6.4

We made some changes to the puppet script and we hope that some of theme will be at least of inspiration to get the official script on the right way to run flewlessly on CentOS.

## Known Issues
###### (you man advised before installation!)

We know that on the first provision you'll get a bunch of errors; the entire _Console_ and _Broker_ installation processes will fail; I'm investigating around this problem (and I have a path), but we know that after the second provision everything will be fine!!!
If you need to improve this aspect, please drop us a some lines of code to fix our ;)

# Installation

We assume you're

* on a new VPS
* SO Centos
* logged in as root
* you have a working network setup (overall reboot proof ;) )

and that you have the right mood to follow these steps

1. ```yum install vim github```
1. ```cd && git clone git://github.com/matjack1/puppet-openshift_origin.git```
1. ```mkdir -p /etc/puppet/modules```
1. ```mv puppet-openshift_origin openshift_origin```
1. ```mv openshift_origin /etc/puppet/modules```
1. Edit line 1 and 5 in test/manifests/configure.pp substituting all *example.com* occurrences with the domain of your choice
1. Are you updating your OpenShift Origin? If you are, than edit line 20 in test/manifests/configure.pp by setting _is_update_ to _true_
1. Edit line 6 and 7 in test/manifests/init.pp substituting all *example.com* occurrences with the domain of your choice
1. ```bash /etc/puppet/modules/openshift_origin/test/kickstart.sh```
  * If you are *updating* OpenShift, then run ```bash /etc/puppet/modules/openshift_origin/test/kickstart.sh update```
1. Don't stop the provision if you see errors! Wait a lot...probably you'll need a lot of [nyan](http://www.nyan.cat/)
1. Log out and in back to be sure to load new ENV
1. ```yum install ruby193-rubygem-net-ssh ruby193-rubygem-archive-tar-minitar ruby193-rubygem-commander``` and ```gem install httpclient```. Read about on [this issue](https://github.com/matjack1/puppet-openshift_origin/issues/14)
1. Due to non-fixed and probably won't fixed little issues you'l have to tun twice the provision with another ```bash /etc/puppet/modules/openshift_origin/test/kickstart.sh```. This will be very shorter and should fix all the errors left behind first provision
1. My colleague @matjack1 says everytime «```reboot``` it twice; anyway». Keep it in mind :P

# Configuration

There is one class (`openshift_origin`) that needs to be declared on all nodes managing
any component of OpenShift Origin. These nodes are configured using the parameters of
this class.

## Using Parameterized Classes

[Using Parameterized Classes](http://docs.puppetlabs.com/guides/parameterized_classes.html)

### Example: Single host (broker+console+node) which uses the Avahi MDNS and mongo Auth plugin:

    class { 'openshift_origin' :
      node_fqdn                  => "${hostname}.${domain}",
      cloud_domain               => 'openshift.local',
      dns_servers                => ['8.8.8.8'],
      os_unmanaged_users         => [],
      enable_network_services    => true,
      configure_firewall         => true,
      configure_ntp              => true,
      configure_activemq         => true,
      configure_mongodb          => true,
      configure_named            => false,
      configure_avahi            => true,
      configure_broker           => true,
      configure_node             => true,
      development_mode           => true,
      update_network_dns_servers => false,
      avahi_ipaddress            => '127.0.0.1',
      broker_dns_plugin          => 'avahi',
    }

### Example: Single host (broker+console+node) which uses the **Kerberos** Auth plugin. 

    class { 'openshift_origin' :
      node_fqdn                  => "${hostname}.${domain}",
      cloud_domain               => 'openshift.local',
      dns_servers                => ['8.8.8.8'],
      os_unmanaged_users         => [],
      enable_network_services    => true,
      configure_firewall         => true,
      configure_ntp              => true,
      configure_activemq         => true,
      configure_mongodb          => true,
      configure_named            => false,
      configure_avahi            => true,
      configure_broker           => true,
      configure_node             => true,
      development_mode           => true,
      broker_auth_plugin         => 'kerberos',
      kerberos_keytab            => '/var/www/openshift/broker/httpd/conf.d/http.keytab',
      kerberos_realm             => 'EXAMPLE.COM',
      kerberos_service           => $node_fqdn,
    }

Please note:

* The Broker needs to be enrolled in the KDC as a host, `host/node_fqdn` as well as a service, `HTTP/node_fqdn`
* Keytab should be generated, is located on the Broker machine, and Apache should be able to access it (`chown apache <kerberos_keytab>`)
* Like the example config below:
  * set `broker_auth_plugin` to `'kerberos'`
  * set `kerberos_keytab` to the absolute file location of the keytab
  * set `kerberos_realm` to the kerberos realm that the Broker host is enrolled with
  * set `kerberos_service` to the kerberos service, e.g. `HTTP/node_fqdn`
* After setup, `kinit <user>` then test the setup with `curl -Ik --negotiate -u : <node_fqdn>`.
* For any errors, on the Broker, check `/var/log/openshift/broker/httpd/error_log`.


# Parameters

The following lists all the class parameters the `openshift_origin` class accepts.

### node_fqdn

The FQDN for this host

### create_origin_yum_repos

True if OpenShift Origin dependencies and OpenShift Origin nightly yum repositories should be created on this node.

### install_client_tools

True if OpenShift Client tools be installed on this node.

### enable_network_services

True if all support services be enabled. False if they are enabled by other classes in your catalog.

### configure_firewall

True if firewall should be configured for this node (Will blow away any existing configuration)

### configure_ntp

True if NTP should be configured on this node. False if ntp is configured by other classes in your catalog.

### configure_activemq

True if ActiveMQ should be installed and configured on this node (Used by m-collective)

### configure_qpid

True if Qpid message broker should be installed and configured on this node. (Optionally, used by m-collective. Replaced ActiveMQ)

### configure_mongodb

Set to true to setup mongo (This will start mongod). Set to 'delayed' to setup mongo upon next boot.

### configure_named

True if a Bind server should be configured and run on this node.

### configure_avahi

True if a Avahi server should be configured and run on this node. (This is an alternative to named. Only one should be enabled)

### configure_broker

True if an OpenShift Origin broker should be installed and configured on this node.

### configure_console

True if an OpenShift Origin console should be installed and configured on this node.

### configure_node

True if an OpenShift Origin node should be installed and configured on this node.

### set_sebooleans

Set to true to setup selinux booleans. Set to 'delayed' to setup selinux booleans upon next boot.

### install_repo

The YUM repository to use when installing OpenShift Origin packages. Specify `nightlies` to pull latest nightly
build or provide a URL for another YUM repository.

### named_ipaddress

IP Address of DNS Bind server (If running on a different node)

### avahi_ipaddress

IP Address of Avahi MDNS server (If running on a different node)

### mongodb_fqdn

FQDN of node running the MongoDB server (If running on a different node)

### mq_fqdn

FQDN of node running the message queue (ActiveMQ or Qpid) server (If running on a different node)

### broker_fqdn

FQDN of node running the OpenShift OpenShift broker server (If running on a different node)

### cloud_domain

DNS suffix for applications running on this PaaS. Eg. `cloud.example.com` applications will be
`<app>-<namespace>.cloud.example.com`
  
### dns_servers

Array of DNS servers to use when configuring named forwarding. Defaults to `['8.8.8.8', '8.8.4.4']`

### configure_fs_quotas

Enables quotas on the local node. Applicable only to OpenShift OpenShift Nodes.  If this setting is set to false, it is expected
that Quotas are configured elsewhere in the Puppet catalog

### console_session_secret

Secret used for signing Rails sessions.

### oo_device

Device on which gears are stored (`/var/lib/openshift`)

### oo_mount

Base mount point for `/var/lib/openshift directory`

### configure_cgroups

Enables cgoups on the local node. Applicable only to OpenShift OpenShift Nodes. If this setting is set to false, it is expected
that cgroups are configured elsewhere in the Puppet catalog

### configure_pam

Updates PAM settings on the local node to secure gear logins. Applicable only to OpenShift OpenShift Nodes. If this setting is
set to false, it is expected that cgroups are configured elsewhere in the Puppet catalog

### broker_auth_plugin

The authentication plugin to use with the OpenShift OpenShift Broker. Supported values are `'mongo'`,
`'basic-auth'`, and `'kerberos'`

### broker_auth_pub_key

Public key used to authenticate communication between node and broker. If left blank, this file is auto generated.

### broker_auth_priv_key

Private key used to authenticate communication between node and broker. If `broker_auth_pub_key` is left blank, this
file is auto generated.

### broker_auth_key_password

Password for `broker_auth_priv_key` private key

### broker_auth_salt

Salt used to generate authentication tokens for communication between node and broker.

### broker_session_secret

Secret used for signing Rails sessions.

### kerberos_keytab

The full/absolute path to the Kerberos keytab for the Broker service, e.g. `'/var/www/openshift/broker/http/conf.d/http.keytab'`.

### kerberos_realm

The hostname in all caps that the Broker host/service is enrolled with, e.g. `'EXAMPLE.COM'`

### kerberos_service

The fully-qualified domain name that the service is enrolled with in your Kerberos setup. Do not include `HTTP/`, just the fqdn, e.g. `'example.com'` or just `$node_fqdn`.

### broker_rsync_key

RSync Key used during move gear admin operations

### mq_provider

Message queue plugin to configure for mcollecitve. Defaults to `'activemq'` Acceptable values are
`'activemq'`, `'stomp'` and `'qpid'`

### mq_server_user

User to authenticate against message queue server

### mq_server_password

Password to authenticate against message queue server

### mongo_auth_user

User to authenticate against Mongo DB server

### mongo_db_name

name of the MongoDB database

### mongo_auth_password

Password to authenticate against Mongo DB server

### named_tsig_priv_key

TSIG signature to authenticate against the Bind DNS server.  

### os_unmanaged_users

List of users with UID which should not be managed by OpenShift. (By default OpenShift Origin PAM will reserve all 
UID's > 500 and prevent user logins)

### update_network_dns_servers

True if Bind DNS server specified in `named_ipaddress` should be added as first DNS server for application name.
resolution. (This should be false if using Avahi for MDNS updates)

### development_mode

Set to true to enable development mode and detailed logging

