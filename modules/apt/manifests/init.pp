class apt {
	$root = '/etc/apt'
	$provider = '/usr/bin/apt-get'

    package { "python-software-properties": }

    file {
        "${root}/sources.list" :
            ensure => present,
            owner => "root",
            group => "root",
            mode => 644,
            content => '',
#            template("apt/sources-10.04.list.erb"),
            notify => Exec["apt_update"] ;

        "${root}/security.sources.list" :
            owner => "root",
            group => "root",
            mode => 644,
            content =>
            template("apt/sources-10.04.security.list.erb"),
            notify => Exec["apt_update"] ;
    }

	file { "${root}/sources.list.d":
		ensure => directory,
		owner => root,
		group => root,
	}

	exec { "apt_update":
		command => "${provider} update",
#		subscribe => [ File["${root}/sources.list"], File["${root}/sources.list.d"] ],
		refreshonly => true,
	}
}
