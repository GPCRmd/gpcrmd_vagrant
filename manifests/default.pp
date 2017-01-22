# default path
Exec {
    path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include tools
include adminer
include postgresql
include solr
include python
include import_db
include rdkit
include mdsrv
