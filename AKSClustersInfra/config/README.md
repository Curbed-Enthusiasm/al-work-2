# Configure AKS

Compatible with AKS version: 1.22

This directory contains automation for configuring AKS clusters. It's written to be idempotent, so it can be used both
for initial set up and to make updates or configuration fixes in the future. A change log will be maintained to keep
track of updates and to track compatibility changes in the future

## Structure

This automation project is broken into modularized subdirectories. Each directory has its own configure.sh script that
manages the configuration of its own respective resources. Every configure.sh is expected to remain self contained
within the scope of it's folder, and remain idempotent so that it may be moved around or replaced in the future without
impacting any other higher level folder. There are two main subdirectories, plugins and resources. The plugins directory
contains automation for configuring external plugins, like emissary-ingress, linkerd, cert-manager, etc. The resources
folder is for any sort of custom resources we decide to define and run on all of our AKS clusters. An example might be
cluster level RBAC resources, ingress rules for certain dns names, certain network routing policies etc.

```
.
├── README.md
├── configure.sh
├── plugins
│   ├── README.md
│   ├── configure.sh
│   ├── cert-manager
│   │   ├── ...
│   ├── emissary
│   │   ├── ...
│   ├── external-dns
│   │   ├── ...
│   ├── linkerd
│   │   ├── ...
│   └── new-relic
│       └── ...
└── resources
    ├── README.md
    └── configure.sh

7 directories, 19 files
```

## How to Use

To run this automation, simply run the configure.sh script in this folder. From the root dir of the repository:

```bash
config/configure.sh
```

There are a few cli options you can see with the `-h` option.

```
$ config/configure.sh -h                            
  Add description of the script functions here.

  config/configure.sh [ -c CONTEXT ] [ -f ]
  options:
  c     Kube context to use when running setup.
  f     Run without confirming kube context (USE ONLY IF YOU UNDERSTAND THE IMPLICATIONS)
  h     Shares this help.
```

Below is an example of what a successful run should look like. If you have any problems, you can see more detailed logs
in the folder mentioned in the logs.

```
$ config/configure.sh                               
  Your kube context is set to nonprod-controlledchaos-aks.
  Is this the cluster you would like to configure? [y/n] y
  Starting setup, see detailed logs in /tmp/aks_configure.vnJ3W

  Configuring Plugins
  emissary... done
  cert-manager... done
  external-dns... done
  linkerd... done
  Plugins Configured

  Configuring Resources
  Resources Configured
```
