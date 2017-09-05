# irc-server-dlang
This might be an irc server. Someday.

## About
* This IRC server is written using D (D2), aiming to only use the standard library and is currently suceeding in that goal.
* It uses the dub build system
* It currently the code is only tested for compilation on GDC (testing on other compilers would be welcome. I use GDC since my target is small boards e.g. RPI, and GDC is easily available on these). Main development is usually on debian 9 GNU/Linux, x86_64, with the same tools stated above.

## Requirements
The system requirements for the server are unknown, but since the raspberry pi 1 model b is a target platform for the functional server, those system specifications can be considered a minimum for known functionality when the server reaches a state of release. In reality, the memory requirements can practically be ignored with the memory capacities considered bare nowadays dwarfing the usage of this program as observed in development. CPU may be the only limitation when using the server, but any limitation will only become apparent under heavy production usage.

## Dependancies


## Branches

### Current
* Main development takes place on the master branch. This branch is the live code changes made when adding/removing functionality, and can not be relied upon to work or compile.
* The release branch will be created and subsequently updated whenever enough new features meet a level of expectation for how functional and stable the software should be for production.
* The working branch will be updated with new code each time a feature appears to be working properly. This branch should be expected to compile and function, but may not be reliable enough for production use as all features in each commit will not be tested. This will be the branch you want to use when making fixes, adding features or generally just trying out the server.

### Old
* The ircDev branch is the branch that used to contain the main development version of this software. It was discontinued when the code required re-writing. All features once in this are now in the master branch, properly implemented for their current state.
* The rewrite branch was a fork of ircDev, made when it was decided to re-write the code in it for a much cleaner, more modular and easier to work with solution. This branch is no longer needed for now, since the re-written code in it has now been merged back into master to continue development. It may be re-used for re-writing code in the future if required.
* This repository also includes a functional basic tcp message relay for multiple sockets in the "msgFun" branch. The relay sends data received by one socket to all other connections to the relay server.
