# HVM - Helm Version Manager

---

Once upon a time I was working across several remote Kubernetes environments via my old Mac. Of course some of the clusters were running different versions of Tiller, and poor old Homebrew was not too happy with me rolling back to older versions. What to do? There are probably several solutions, but, as there was no good TV on this evening I decided to try and solve the with my bash hammer.

---

## Installation

1. Clone this repo onto your machine. ```$HOME/.hvm``` is currently the best place as this is one of the two places I 'tested' it from: 
    ```
    git clone git@github.com:templecloud/hvm.git ${HOME}/.nvm
    ```

2. Add an alias to your ```.bash_profile``` or whatever you used on the path to starting up your shell:
    ```
    alias hvm="$HOME/.nvm/nvm.sh" 
    ```

Or you can do it however you want. It is just a bit of bash after all.

If you are security minded you might want to glance though the code to make sure you are happy.

NB: HVM doe not work yet if Helm has also been installed with the system package manager. TODO: Fix this issue.

---

## Running

If you set it up ok, you should be able to run: ```hvm help``` to get the instructions. It is pretty basic stuff:

```
$> hvm help
usage: hvm <command> [version]

commands:
  add      [version] : Add the specified Helm version to HVM. If no version is
                       specified, the 'latest' github version is used.
  remove   [version] : Remove the specified Helm version from HVM. If no
                       version is specified, the 'current' NVM version is used.
  use       version  : Select and use an installed HVM Helm version.
  current            : Display the current Helm version HVM is using.
  versions           : Displays all Helm versions that have been added to HVM.
  latest             : Displays the latest Helm version in the github releases.
  releases           : Displays all the Helm versions available in the github
                       releases.
```

You can do the usual: download a new Helm client version, use a specific version, check your current version, etc.

NB: I might remove some of the 'default version' functionality later depending on wether it is helpful, or, confusing.

---

## Example Usage

Obvious stuff really. Here is a small session:

```
682 temple@occam:~/Work/dev/templecloud/hvm
$> hvm latest
v2.11.0
683 temple@occam:~/Work/dev/templecloud/hvm
$> hvm versions
684 temple@occam:~/Work/dev/templecloud/hvm
$> hvm add v2.11.0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 18.2M  100 18.2M    0     0   272k      0  0:01:08  0:01:08 --:--:--  409k
Using: v2.11.0
685 temple@occam:~/Work/dev/templecloud/hvm
$> hvm versions
v2.11.0
686 temple@occam:~/Work/dev/templecloud/hvm
$> hvm use v2.11.0
Using: v2.11.0
687 temple@occam:~/Work/dev/templecloud/hvm
$> hvm current
v2.11.0
688 temple@occam:~/Work/dev/templecloud/hvm
$> helm version -c
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
690 temple@occam:~/Work/dev/templecloud/hvm
$> hvm releases
v2.11.0
v2.11.0-rc.4
v2.11.0-rc.3
v2.11.0-rc.2
v2.11.0-rc.1
v2.10.0
v2.10.0-rc.3
v2.10.0-rc.2
v2.10.0-rc.1
v2.9.1
v2.9.0
v2.9.0-rc5
v2.9.0-rc4
v2.9.0-rc3
v2.9.0-rc2
v2.9.0-rc1
v2.8.2
v2.8.1
v2.8.0
v2.8.0-rc.1
v2.7.2
v2.7.1
v2.7.0
v2.7.0-rc1
v2.6.2
v2.6.1
v2.6.0
v2.5.1
v2.5.0
v2.4.2
691 temple@occam:~/Work/dev/templecloud/hvm
$> hvm add v2.8.2
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 14.2M  100 14.2M    0     0   600k      0  0:00:24  0:00:24 --:--:--  593k
692 temple@occam:~/Work/dev/templecloud/hvm
$> hvm versions
v2.11.0
v2.8.2
693 temple@occam:~/Work/dev/templecloud/hvm
$> hvm current
v2.11.0
694 temple@occam:~/Work/dev/templecloud/hvm
$> hvm use v2.8.2
Using: v2.8.2
695 temple@occam:~/Work/dev/templecloud/hvm
$> helm version -c
Client: &version.Version{SemVer:"v2.8.2", GitCommit:"a80231648a1473929271764b920a8e346f6d
e844", GitTreeState:"clean"}
696 temple@occam:~/Work/dev/templecloud/hvm
$> hvm remove v2.8.2
697 temple@occam:~/Work/dev/templecloud/hvm
$> hvm versions
v2.11.0
698 temple@occam:~/Work/dev/templecloud/hvm
$> hvm current
v2.8.2
699 temple@occam:~/Work/dev/templecloud/hvm
$> helm version -c
Client: &version.Version{SemVer:"v2.8.2", GitCommit:"a80231648a1473929271764b920a8e346f6d
e844", GitTreeState:"clean"}
701 temple@occam:~/Work/dev/templecloud/hvm
$> hvm use v2.11.0
Using: v2.11.0
702 temple@occam:~/Work/dev/templecloud/hvm
$> helm version -c
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
703 temple@occam:~/Work/dev/templecloud/hvm
$> hvm use v2.8.2
Version v2.8.2 unavailable.
Please run: 'hvm add v2.8.2'
```

---

## Uninstallation

If you have no cached Helm client binaries, you can just delete the ```$HOME/.hvm``` directory (or wherever you installed it). Also remember to clean up anything from your ```.bash_profile``` or similar.

