# Configure Plugins

Compatible with AKS version: 1.22

This directory contains automation for configuring AKS clusters. It's written to be idempotent, so it can be used both
for initial set up and to make updates or configuration fixes in the future. A change log will be maintained to keep
track of updates and to track compatibility changes in the future

## Structure

The configure.sh script in this directory assumes all subdirectories are plugins with their own respective configure.sh.
It will run through and run the configure script for each plugin one at a time. It sorts them by their directory name,
so it is important to prefix the folders with numbers in the order that each plugin should be installed. The naming
schema for these folders is `${INDEX}_${PLUGIN_NAME}`. It's importaint to maintain this schema so that the root plugin
configure script is able to parse the order and names.

```
.
├── 01_emissary
│   ├── configure.sh
│   └── ...
├── 02_cert-manager
│   ├── configure.sh
│   ├── ...
├── 03_external-dns
│   ├── configure.sh
│   └── ...
├── 04_linkerd
│   ├── configure.sh
│   ├── ...
├── 05_new-relic
│   └── README.md
├── README.md
└── configure.sh

5 directories, 16 files

```

## How to Use

To run this automation, simply run the configure.sh script in this folder. This will typically only be run by the root
configuration script, but if you ever need to run only this use the following:

```bash
config/plugins/configure.sh
```

Below is an example of what a successful run should look like. If it runs into any errors, a directory to look at logs
will be printed out. If you would like to set this directory on your own, just export a `LOG_DIR` variable.

```
$ config/configure.sh                               
  emissary... done
  cert-manager... done
  external-dns... done
  linkerd... done
```
