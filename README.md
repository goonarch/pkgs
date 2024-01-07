
---
# Package repo for [GoonArch](https://github.com/goonarch)
---
###### includes packages that are not included in the standard repo. (usually from the AUR)

# How to use
Add this to the end of `/etc/pacman.conf`

```
[goonarch]
SigLevel = Optional
Server = https://raw.githubusercontent.com/goonarch/pkgs/main/$arch

```
