docker-rpmbuild
===============

A minimal docker rpmbuilder image.

Currently based on [centos:7](https://registry.hub.docker.com/_/centos/),
includes only rpmdevtools and yum-utils on top of that and a couple of
scripts that automate its use for building RPM packages.

The scripts take care of installing build dependencies (using
yum-builddep), building the package (using rpmbuild) and placing the
resulting RPMs in output directory.

Usage
=====

The image expects that work directory will be set to directory
containing the sources (mounted from the host).

Typical usage:

```sh
docker run --rm --volume=$PWD:/src --workdir=/src \
  jitakirin/rpmbuild MYPROJ.spec
```

This will build the project `MYPROJ` in current directory, placing
results in `RPMS/${ARCH}/` and `SRPMS/` subdirectories under current
directory.

You can also specify to place the results in a subdirectory:

```sh
docker run --rm --volume=$PWD:/src --workdir=/src \
  jitakirin/rpmbuild MYPROJ.spec OUTDIR
```

This will create `OUTDIR` if necessary and place the results in
`OUTDIR/RPMS/${ARCH}/` and `OUTDIR/SRPMS/`.

Debugging
=========

There are two options to aid with debugging the build.  One is to set
VERBOSE option in the environment (with `-e VERBOSE=1` option to
`docker run`) which will enable verbose output from the scripts and
rpmbuild.  The other is to pass an `--sh` option to the image, which
will drop to the shell instead of running rpmbuild, e.g.:

```sh
docker run -it -e VERBOSE=1 --rm --volume=$PWD:/src --workdir=/src \
  jitakirin/rpmbuild --sh MYPROJ.spec
```

From there you can inspect the environment and you can run the build
manually either by switching to `rpmbuild` user:

```sh
su - rpmbuild
rpmbuild -ba rpmbuild/SPECS/MYPROJ.spec
```

or by running the same script the image uses:

```sh
runuser -u rpmbuild /usr/local/bin/docker-rpm-build.sh \
  ~rpmbuild/SPECS/MYPROJ.spec
```

Jenkins
=======

To use this from a Jenkins builder which itself is running under docker
(assuming it has access to host's docker socket), use something like:

```sh
docker run --rm \
  --volumes-from=JENKINS-VOLUME-CONTAINER --workdir="${WORKSPACE}" \
  jitakirin/rpmbuild MYPROJ.spec
```

This will build RPMs and place the results back in Jenkins' workspace
directory.
