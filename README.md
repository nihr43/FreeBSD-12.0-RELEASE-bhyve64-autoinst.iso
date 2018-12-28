freebsd-autoinst
======

Clone to a fresh freebsd machine, customize the installerconfig, and run ./patch.sh.

Builds FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso with the following properties

- ssh enabled with prohibit-password
- no root password
- public keys from github
- ntpdate on boot
- a single serial TTY
- auto UFS root disk
- DHCP on vtnet0
- hostname determined by the mac address of vtnet0.  aa:bb:cc:dd:ee:ff becomes host ddeeff
