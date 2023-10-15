# podman-detect-option
Run a container image to detect the need for the `podman run` option `--userns=keep-id:uid=$uid,gid=$gid`

The ownership of created files are checked both in the container and in any created anonymous volumes.
If the container started to run as the container user root (0:0) but later created files with
ownership other than (0:0), that might indicate that the `podman run` option `--userns=keep-id:uid=$uid,gid=$gid`
is required if the container would be run with bind-mounts (`podman run --volume /host/dir:/container/dir ...`).

## Examples

### Example 1: try docker.io/library/redis

1. Set the shell variable _seconds_ to specify how long the container should run
   before the ownership of created files is checked.
   ```
   seconds=15
   ```
2. Run the test
   ```
   dir=$(mktemp -d)
   cd $dir
   git clone URL
   cd podman-detect-option
   chmod -R 755 $dir
   bash podman-detect-option.bash \
     "$dir/podman-detect-option/podman-detect-option.helper.bash" \
     $seconds \
     --quiet docker.io/library/redis
   ```
__Result__: `--userns=keep-id:uid=999,gid=999`

### Example 2: create user and try docker.io/library/mariadb

Example 2 is similar to Example 1. Example 2 demonstrates how to use
the wrapper script _create-user-and-detect-option.bash_ to first create
a user before running  _podman-detect-option.bash_.

The wrapper script _create-user-and-detect-option.bash_ needs to be run as root.

1. Set the shell variable _user_ to specify the username of a user account that will be created
   for the test.
   ```
   user=test
   ```
2. Set the shell variable _seconds_ to specify how long the container should run
   before the ownership of created files is checked.
   ```
   seconds=15
   ```
3. Run the test
   ```
   dir=$(mktemp -d)
   cd $dir
   git clone URL
   cd podman-detect-option
   chmod -R 755 $dir
   sudo bash create-user-and-detect-option.bash \
     "$dir/podman-detect-option/podman-detect-option.bash" \
     "$dir/podman-detect-option/podman-detect-option.helper.bash" \
     $user \
     $seconds \
     --quiet --env MARIADB_RANDOM_ROOT_PASSWORD=1 docker.io/library/mariadb     
   ```
__Result__: `--userns=keep-id:uid=999,gid=999`

`--quiet` was added to disable printing download progress of the container image.
The option `--env MARIADB_RANDOM_ROOT_PASSWORD=1` was found in the 
__docker.io/library/mariadb__ [documentation](https://hub.docker.com/_/mariadb)


## Result from some popular container images

Result from some popular container images
https://hub.docker.com/search?image_filter=official&q=

| arguments | result | comment |
| --        |  --    |  -- |
| docker.io/jenkins/jenkins | `--userns=keep-id:uid=1000,gid=1000` | [docker.io/library/jenkins](https://hub.docker.com/_/jenkins) is deprecated |
| docker.io/library/adminer | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/arangodb | | |
| docker.io/library/cassandra | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/couchbase | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/couchdb | `--userns=keep-id:uid=5984,gid=5984` | |
| docker.io/library/crate | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/drupal | `--userns=keep-id:uid=33,gid=33` | |
| --env MARIADB_RANDOM_ROOT_PASSWORD=1 docker.io/library/mariadb | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/flink | `--userns=keep-id:uid=9999,gid=9999` | |
| docker.io/library/fluentd | `--userns=keep-id:uid=100,gid=101` | |
| docker.io/library/gradle | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/haproxy | | |
| docker.io/library/jetty | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/joomla | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/matomo | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/mediawiki | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/mongo | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/mongo-express | | |
| docker.io/library/neo4j | `--userns=keep-id:uid=7474,gid=7474` | |
| docker.io/library/nextcloud | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/nginx | `--userns=keep-id:uid=101,gid=0` | a bit surprising result. Shouldn't it be uid=101,gid=101? See https://hub.docker.com/_/nginx |
| docker.io/library/orientdb | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/phpmyadmin | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/plone | `--userns=keep-id:uid=500,gid=500` | |
| docker.io/library/postgres | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/rabbitmq | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/redis | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/redmine | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/registry | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/rethinkdb | | |
| docker.io/library/solr | | |
| docker.io/library/sonarqube | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/tomcat | | |
| docker.io/library/varnish | | |
| docker.io/library/wordpress | `--userns=keep-id:uid=33,gid=33` | |
| docker.io/library/zookeeper | `--userns=keep-id:uid=1000,gid=1000` | |
| docker.io/library/xwiki | | |
| docker.io/owncloud/server | | [docker.io/library/owncloud](https://hub.docker.com/_/owncloud) is deprecated |

An empty result does not neccessarily mean that no `--userns=keep-id:uid=$uid,gid=$gid` is needed.
