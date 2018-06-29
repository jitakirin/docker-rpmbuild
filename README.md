docker-rpmbuild
===============

A minimal docker rpmbuilder image.

Based on centos, includes only rpmdevtools and yum-utils and a couple
of scripts that automate building RPM packages.

The scripts take care of installing build dependencies (using
yum-builddep), building the package (using rpmbuild) and placing the
resulting RPMs in output directory.

The setup is based on Fedora packaging how-to:
http://fedoraproject.org/wiki/How_to_create_an_RPM_package

This repo was forked from [jitakirin/docker-rpmbuild](https://github.com/jitakirin/docker-rpmbuild) 

Supported tags and respective `Dockerfile` links
================================================

- [`latest` (centos:7 Dockerfile)](https://github.com/Setheck/docker-rpmbuild/blob/master/Dockerfile) - based on [centos:7](https://registry.hub.docker.com/_/centos/)

Usage
=====

The image expects that work directory will be set to directory
containing the sources (mounted from the host).

Typical usage:

```sh
docker run [--rm] -v /path/to/source:/src -w /src Setheck/rpmbuild -s MYSPEC.spec
```

For help with usage, you can also consult the -h|--help flag
```sh
docker run --rm Setheck/rpmbuild -h
```

This will build the project `MYPROJ` in current directory, placing
results in `RPMS/${ARCH}/` and `SRPMS/` subdirectories under current
directory.

You can also specify to place the results in a subdirectory:

```sh
docker run [--rm] -v /path/to/source:/src -w /src Setheck/rpmbuild -s MYSPEC.spec OUTDIR
```

This will create `OUTDIR` if necessary and place the results in
`OUTDIR/RPMS/${ARCH}/` and `OUTDIR/SRPMS/`.

If your package requires something from a non-core repo to build, you
can add that repo using a PRE_BUILDDEP hook.  It is an env variable
that should contain an inline script or command to add the repo you
need.  E.g. for EPEL do:

```sh
docker run --rm -e PRE_BUILDDEP="yum install -y epel-release" -v /path/to/source:/src -w /src Setheck/rpmbuild -s MYSPEC.spec
```

You can also gpg sign all resulting RPMs by specifying the signing name,
keyfile, and password (with `-a "Name;KeyFile;Password"`) and placing
your keyfile in the source directory with your sources and spec file.
E.g.

```sh
docker run --rm -e PRE_BUILDDEP="yum install -y epel-release" -v /path/to/source:/src -w /src Setheck/rpmbuild \
-s MYSPEC.spec -a "SETH;seth_key.asc;supersecretpw"
```

Debugging
=========

There are two options to aid with debugging the build.  One is to set
VERBOSE option in the environment (with `-e VERBOSE=1` option to
`docker run`) which will enable verbose output from the scripts and
rpmbuild.  The other is to pass an `--sh` option to the image, which
will drop to the shell instead of running rpmbuild, e.g.:

```sh
docker run -it -e VERBOSE=1 --rm --volume=$PWD:/src --workdir=/src \
  Setheck/rpmbuild --sh MYPROJ.spec
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
