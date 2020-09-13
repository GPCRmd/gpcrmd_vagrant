# default path

$production_config = false

Exec {
    path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include postgresql
include python
include apache
include import_db
include adminer
include solr
include boost
include rdkit
include mdsrv
include clean_cache
include tools
if $::production_config {
    include production
}
