#!/usr/bin/env bash
set -eo pipefail

mariadb_server_version=develop/latest/amd64

while :; do
    case $1 in
        --mariadb-server-version)
            if [[ -n $2 ]] && [[ $2 != --* ]]; then
                mariadb_server_version=$2
                shift
            else
                echo "The $1 option requires an argument"
            fi
            ;;
        --mariadb-server-version=?*)
            mariadb_server_version=${1#*=}
            ;;
        *)
            break
    esac
    shift
done

cat << EOF > /etc/yum.repos.d/columnstore.repo
[columnstore]
name=columnstore
baseurl=https://cspkg.s3.amazonaws.com/${mariadb_server_version}/rockylinux8/
enabled=1
gpgcheck=0
EOF

cat << EOF > /etc/yum.repos.d/cmapi.repo
[cmapi]
name=cmapi
baseurl=https://cspkg.s3.amazonaws.com/cmapi/develop/latest/amd64/
enabled=1
gpgcheck=0
EOF

dnf module -y disable mysql mariadb
