# irc-server-dlang
This might be an irc server. Someday.

## Platforms, Dependancies and Requirements
This IRC server is written using D (D2) and aims to only use the standard library if possible, uses the dub build system, and currently the code is only tested for compilation on GDC (testing on other compilers would be welcome. I use GDC since my target is small boards e.g. RPI, and GDC is easily available on these).
The system requirements for the server are unknown, but since the raspberry pi 1 model b is a target platform for the functional server, those system specifications can be considered a minimum for known functionality when the server reaches a state of useable functionality. In reality, the memory requirements can practically be ignored with the memory capacities considered bare nowadays dwarfing the usage of this program as observed in development. CPU may be the only limitation when using the server, but any limitation can only become apparent under high usage.

## Branches
* Main development to add irc features is currently in the "ircDev" branch. This branch is the live code changes made when adding/removing functionality, and can not be relied upon for functionality or compilation at any time.
* The master branch of this repository will currently be updated from the ircDev branch when the features being developed appear to be working. It should not be relied upon for stability or functionality in production.
* A "release" branch will be created and subsequently updated whenever enough new features meet a level of expectation for how functional and stable the software should be for production.
* After re-writing a major part of the code, and re structuring the project, the master branch is planned to be the site of development, with "working" and "release" branches for appropriate points of development. When this point is reached, this section will be updated to show the new branch setup.
* This repository also includes a functional basic tcp message relay for multiple sockets in the "msgFun" branch. The relay sends data received by one socket to all other connections to the relay server.
