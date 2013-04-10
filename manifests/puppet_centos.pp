# Install PupetLabs RHEL6 repos,
# puppet, facter, then removes
# repos due to future conflicts
# netween repositories
#
class openshift_orogin::puppet_centos {
  
  package { 'puppetlabs-release-6-6':
    ensure  => installed,
    source  => 'http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm',
  
  }
  
  ensure_resource('package', 'puppet'{
    ensure  => present,
    }
  )
  
  ensure_resource('package', 'facter'{
    ensure  => present,
    }
  )
  
  package { 'puppetlabs-release-6-6':
    ensure  => absent,
  }
  
  exec { '/usr/bin/yum clean all' }
  
}
