# makesbld

## Slackware SlackBuild Script Builder
This program will create Slackware SlackBuild.sh files
by prompting for input and variables to fill out the
SlackBuild file.

Templates exist for retrieving and building packages from
tar, cvs, svn, git, and perl files.

## Features
* Dialog-based user input form  
* User variables (pkg location, user suffix, make options, arch)  
* Library of common functions  
* Bash scripting  
* Presets for configure, make, and make install blocks  
* Resuable code means just call a function that's already written and tested  
* SlackBuild files easily modifiable  
* Consistency across all packages and source types

## Current Function List

Function Name        | Description
:-------------       | :-----------
| bin_perms()          | Set executable permisssions |
| check_req_pkg()      | Check for required packages |
| cleanup()            | Wipe SRC and TMP install dirs |
| create_docs()        | Add DOC files from standardized list |
| die()                | Exit program on any error |
| dobin()              | Install file(s) in /bin /usr/bin |
| dodoc()              | Install select file(s) into docdir |
| doetc()              | Put files in /etc or /etc/{DIR} |
| doexe()              | Install file into DIR and mark executable |
| doicon()             | Install icon file(s) |
| doins()              | Install file(s) anywhere |
| doman()              | Install man file(s) (1-8) |
| domenu()             | Install application menu file |
| dorc()               | Install Slackware rc. \*file |
| dosbin()             | Install file(s) in /sbin or /usr/sbin |
| doshare()            | Install /usr/share file(s) DIR(s) |
| double_check_user()  | Make sure all installed files are owned by root.root |
| etc2new()            | Move files in /etc to have .new extension |
| fetch()              | wget files |
| fetch_cvs()          | get cvs files |
| fetch_svn()          | get svn files |
| fetch_git()          | get git files |
| fix_source()         | Set proper permissions and ownership in upacked SRC DIR |
| get_args()           | Get arguments for creating SlackBuild |
| gzip_docs()          | gzip all DOCs |
| gzip_info()          | gzip info file(s) |
| gzip_man()           | gzip man file(s) |
| gzip_man_info()      | gzip both man and info file(s) |
| gzip_misc()          | gzip any file anywhere |
| pkg_setup()          | create SRC and TMP install directoriees |
| spatch()             | patch file(s) with .diff file |
| strip_all()          | strip debug symbol info from executables and library file(s) |
| strip_bin()          | strip executable file(s) |
| strip_lib()          | strip library file(s) |
| strip_static()       | strip static library file(s) |
| unpack()             | unpack any tar type file |
| usage()              | makesble-d.sh SlackBuild arguments |

## Authors and Credits
Peter Hyman <pete@peterhyman.com>  
Original concept by Jim Simmons (formerly <tg@linuxpackages.net>)  
The Create_Docs function is based on a concept  
in the checkinstall program: http://asic-linux.com.mx/~izto/checkinstall/index.php  
Felipe Eduardo Sanchez Diaz Duran <izto@asic-linux.com.mx>  
The various functions in makesbld.inc are inspired by the Gentoo Linux ebuild system.  
