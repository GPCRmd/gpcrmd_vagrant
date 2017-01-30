# default path
Exec {
    path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include python
include apache
include bootstrap
include tools
include adminer
include postgresql
include solr
include import_db
include rdkit
include mdsrv
include clean_cache
