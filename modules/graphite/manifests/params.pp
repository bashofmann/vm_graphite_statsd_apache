class graphite::params {

  $graphite_version = "0.9.9"
  $build_dir = "/tmp/graphite_build_root"

  $whisper_dl_url = "http://launchpad.net/graphite/0.9/${graphite_version}/+download/whisper-${graphite_version}.tar.gz"
  $whisper_dl_loc = "$build_dir/whisper.tar.gz"

  $webapp_dl_url = "http://launchpad.net/graphite/0.9/${graphite_version}/+download/graphite-web-${graphite_version}.tar.gz"
  $webapp_dl_loc = "$build_dir/graphite-web.tar.gz"

  $carbon_dl_url = "http://launchpad.net/graphite/0.9/${graphite_version}/+download/carbon-${graphite_version}.tar.gz"
  $carbon_dl_loc = "$build_dir/carbon.tar.gz"

  $install_prefix = "/opt"
  $install_dir = "$install_prefix/graphite"

  $web_user = $::operatingsystem ? {
   ubuntu => "researchgate",
   centos => "apache",
   default => "researchgate"
  }
  $apacheconf_dir = $::operatingsystem ? {
   ubuntu => "/etc/apache2/sites-available",
   centos => "/etc/httpd/conf.d",
   default => "/etc/apache2/sites-available"
  }

  file {
        "$build_dir":
            ensure => directory;
        "$build_dir/patches":
            ensure => directory;
  }
}
