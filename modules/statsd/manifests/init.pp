class statsd {
	require nodejs

    user {
        "statsd" :
            home => "/opt/statsd",
            managehome => true,
            shell => "/bin/bash",
            ensure => "present" ;
    }

    file {
        "/etc/init/statsd.conf" :
            source => "puppet:///modules/statsd/upstart.statsd.conf" ;

        "/opt/statsd" :
            recurse => true,
            owner => "statsd",
            source => "puppet:///modules/statsd/install/" ;

        "/opt/statsd/myconfig.js" :
            content => template("statsd/myconfig.js.erb") ;
    } ->
    service {
        "statsd" :
            require => File["/etc/init/statsd.conf"],
            provider => $::puppetversion ? {
                "0.25.4" => "init",
                default => "upstart"},
            ensure => "running" ;
    }
}
