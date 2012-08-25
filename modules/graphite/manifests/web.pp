class graphite::web {
    include graphite::params

    if ! defined(Package[apache2]){
        package {
            "apache2":
                ensure => present;
        }
    }
    if ! defined(File["/etc/apache2/envvars"]){
        file {
            "/etc/apache2/envvars" :
                source => "puppet:///files/apache2/envvars",
                mode => 644,
                owner => root,
                group => root,
                require => Package[apache2],
               # notify => Exec["reload-apache"] ;
        }
    }


    exec {
        "download-webapp" :
            command =>
            "wget -O $graphite::params::webapp_dl_loc $graphite::params::webapp_dl_url",
            creates => "$graphite::params::webapp_dl_loc",
            require => File["$graphite::params::build_dir"];
    }
    exec {
        "unpack-webapp" :
        # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
            command =>
            "bash -c 'true && cd $graphite::params::build_dir && tar -zxvf $graphite::params::webapp_dl_loc'",
            require => File["$graphite::params::build_dir/patches"],
            subscribe => Exec["download-webapp"],
            refreshonly => true,
            creates => "$graphite::params::build_dir/graphite-web-$graphite::params::graphite_version/";
    } ->
    exec {
        "patch webapp":
            onlyif => "ls -A $graphite::params::build_dir/patches/* &>/dev/null",
            command => "true && cd $graphite::params::build_dir/graphite-web-$graphite::params::graphite_version && patch -p1 < $graphite::params::build_dir/patches/*.diff ;",
            subscribe => Exec["unpack-webapp"],
            refreshonly => true;
    }
    exec {
        "install-webapp" :
        # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
            command =>
            "true && cd $graphite::params::build_dir/graphite-web-$graphite::params::graphite_version && python setup.py install",
            subscribe => Exec["unpack-webapp"],
            refreshonly => true,
            creates => "$graphite::params::install_dir/webapp";
    }
    exec {
        "initialize-db" :
            command =>
            "bash -c 'export PYTHONPATH=/opt/graphite/webapp &&  cd /opt/graphite/webapp/graphite/ && python manage.py syncdb'",
            subscribe => Exec["install-webapp"],
            require => File["$graphite::params::install_dir/webapp/graphite/local_settings.py"],
            refreshonly => true,
            user => $graphite::params::web_user;
    }
    file {
        "$graphite::params::install_dir/webapp/graphite/local_settings.py" :
            content => template ("graphite/local_settings.py.erb"),
            subscribe => Exec["install-webapp"];
    }
    file {
        "$graphite::params::apacheconf_dir/graphite.conf" :
            content => template ("graphite/graphite_apache.conf.erb"),
            subscribe => Exec["install-webapp"];
    }
    file {
        "$graphite::params::install_dir/conf/graphite.wsgi" :
            source => "puppet:///modules/graphite/graphite.wsgi",
            subscribe => Exec["install-webapp"];
    }
    file {
        "$graphite::params::install_dir/storage" :
            owner => $graphite::params::web_user,
            subscribe => Exec["install-webapp"];
    }
    file {
        "$graphite::params::install_dir/lib" :
            owner => $graphite::params::web_user,
            subscribe => Exec["install-webapp"],
            recurse => inf;
    }
    package {
        ["python-ldap", "python-cairo", "python-django", "python-memcache", "memcached",
        "libapache2-mod-python", "libapache2-mod-wsgi", "python-simplejson",
        "python-psycopg2", "python-django-tagging","python-twisted"] :
            ensure => present ;
    }
    file {
        "/etc/apache2/sites-enabled/graphite":
            #notify => Exec["reload-apache"],
            ensure => link,
            target => "$graphite::params::apacheconf_dir/graphite.conf";
    }
}
