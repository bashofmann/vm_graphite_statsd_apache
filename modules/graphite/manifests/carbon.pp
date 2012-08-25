class graphite::carbon {
    include graphite::params

    exec {
        "download-carbon" :
            command =>
            "wget -O $graphite::params::carbon_dl_loc $graphite::params::carbon_dl_url",
            creates => "$graphite::params::carbon_dl_loc",
            require => File["$graphite::params::build_dir"] ;
    } ->
    exec {
        "unpack-carbon" :
        # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
            command =>
            "true ; cd $graphite::params::build_dir ; tar -zxvf $graphite::params::carbon_dl_loc ; cd carbon-$graphite::params::graphite_version ;",
            subscribe => Exec["download-carbon"],
            refreshonly => true ;
    } ->
    exec {
        "install-carbon" :
        # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
            command =>
            "true && cd $graphite::params::build_dir/carbon-$graphite::params::graphite_version && python setup.py install",
            creates => "$graphite::params::install_dir/bin/carbon-cache.py",
            require => Exec["unpack-carbon"] ;
    } ->
    file {
        "$graphite::params::install_dir/conf/carbon.conf" :
            content => template ("graphite/carbon.conf.erb"),
            subscribe => Exec["install-carbon"];
        "$graphite::params::install_dir/conf/storage-schemas.conf" :
            source => "puppet:///modules/graphite/storage-schemas.conf",
            subscribe => Exec["install-carbon"];
    } ->
    file {
        "/etc/init/carbon-cache.conf":
            source => "puppet:///modules/graphite/upstart_carbon-cache.conf"
    } ->
    service {
        "carbon-cache":
            require => File["/etc/init/carbon-cache.conf"],
            provider => "init",
            ensure => running;
    }
}
