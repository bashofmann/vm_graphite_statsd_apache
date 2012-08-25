exec { 'apt-get update':
  command => '/usr/bin/apt-get update'
}
file {
    "/data":
        ensure => directory,
        mode => '0777';
}

class apache {

  package { 
    "apache2":
        ensure => present;
    "php5-dev":
        ensure => present;
    "php5-cli":
        ensure => present;
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }
}

class tools {
  package { 
    "curl":
        ensure => present;
  }
}

include apache
include tools
include graphite
include statsd
