# podman-detect-option
Run a container image to detect the need for the `podman run` option `--userns=keep-id:uid=$uid,gid=$gid`

The ownership of created files are checked both in the container and in any created anonymous volumes.
If the container started to run as the container user root (0:0) but later created files with
ownership other than (0:0), that might indicate that the `podman run` option `--userns=keep-id:uid=$uid,gid=$gid`
is required if the container would be run with bind-mounts (`podman run --volume /host/dir:/container/dir ...`).

## Example 1: try docker.io/library/mariadb

1. Set the shell variable _user_ to specify the username of a user account that will be created
   for the test.
   ```
   user=test1
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
   sudo bash podman-detect-option.bash \
     "$dir/podman-detect-option/podman-detect-option.helper1.bash" \
     "$dir/podman-detect-option/podman-detect-option.helper2.bash" \
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
| docker.io/library/nginx | `--userns=keep-id:uid=101,gid=0` | a bit surprising result. Shouldn't it be uid=101,gid=101? See https://hub.docker.com/_/nginx |
| docker.io/library/redis | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/rabbitmq | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/registry | `--userns=keep-id:uid=999,gid=999` | |
| --env MARIADB_RANDOM_ROOT_PASSWORD=1 docker.io/library/mariadb | `--userns=keep-id:uid=999,gid=999` | |
| docker.io/library/tomcat | | |
| docker.io/library/mongo | | |
| docker.io/library/postgres | | |
| docker.io/library/wordpress | | |

An empty result does not neccessarily mean that no `--userns=keep-id:uid=$uid,gid=$gid` is needed.
