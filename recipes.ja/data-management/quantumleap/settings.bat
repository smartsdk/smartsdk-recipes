@ECHO OFF

:: Crate
setx CRATE_VERSION "2.3.6"
setx EXPECTED_NODES "1"
setx RECOVER_AFTER_NODES "1"
setx MINIMUM_MASTER_NODES "1"
setx CLUSTER_DOMAIN "mydomain.com"

:: Traefik
setx TRAEFIK_VERSION "1.3.5-alpine"

:: QL
setx CRATE_HOST "crate"
setx QL_VERSION "latest"
