# source.pp
# add an apt source

define apt::source(
    $ensure = present,
	$location = '',
	$release = 'lucid',
	$repos = 'main',
	$include_src = false,
	$required_packages = false,
	$key = false,
	$key_server = 'keyserver.ubuntu.com',
	$pin = false
) {

	include apt

	file { "${name}.list":
		name => "${apt::root}/sources.list.d/${name}.list",
		ensure => $ensure,
		owner => root,
		group => root,
		mode => 644,
		content => template("apt/source.list.d.erb"),
	}

	#todo dont pin release, pin the source
	if $pin != false {
		apt::pin { "${release}": priority => "${pin}" }
	}

	exec { "${name} apt update":
		command => "${apt::provider} update",
		subscribe => File["${name}.list"],
		refreshonly => true,
	}

	if $required_packages != false {
		exec { "${apt::provider} -y install ${required_packages}":
			subscribe => File["${name}.list"],
			refreshonly => true,
		}
	}

	if $key != false {
		exec { "/usr/bin/apt-key adv --keyserver ${key_server} --recv-keys ${key}":
			unless => "/usr/bin/apt-key list | grep ${key}",
			before => File["${name}.list"],
		}
	}

}
