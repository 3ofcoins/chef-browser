chef-browser RPM packaging
==========================

Easy packaging of chef-browser into an RPM. It handles the needed runtime dependencies and provides a simple start script and base configuration.

## Usage

```
$ VERSION=1.1.1 make package
```

### Build variables

|Name   |Description|
|-------|-----------|
|VERSION| The version of chef-browser to be packaged. This must match a valid version tag in the chef-browser repository.|

## Build dependencies

    ruby
    ruby-devel
    libicu-devel
    zlib-devel
    openssl-devel
    cmake
    fpm

## Build environment

The contained Vagrantfile provides a build environment with all dependencies expect `fpm` which must be installed manually.

### Using the build environment

```
vagrant up
vagrant ssh
# Install FPM since there are no rpm's available on standard repositories.
cd chef-browser-build
VERSION=1.1.1 make package
```
