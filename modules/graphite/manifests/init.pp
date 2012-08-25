import "*.pp"

class graphite {
    Exec {
        path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin"
    }
    include graphite::params

    class {'graphite::whisper':} ->
    class {'graphite::carbon':} ->
    class {'graphite::web':}

}