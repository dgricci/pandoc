% Environnement Haskell pour pandoc
% Didier Richard
% 13/03/2017

---

revision:
    - 0.0.1 : 10/07/2016
    - 0.0.2 : 10/08/2016
    - 0.0.3 : 10/09/2016
    - 0.0.4 : 20/10/2016
    - 0.0.5 : 13/03/2017

---

# Building #

```bash
$ docker build -t dgricci/pandoc:$(< VERSION) .
$ docker tag dgricci/pandoc:$(< VERSION) dgricci/pandoc:latest
```

## Behind a proxy (e.g. 10.0.4.2:3128) ##

```bash
$ docker build \
    --build-arg http_proxy=http://10.0.4.2:3128/ \
    --build-arg https_proxy=http://10.0.4.2:3128/ \
    -t dgricci/pandoc:$(< VERSION) .
$ docker tag dgricci/pandoc:$(< VERSION) dgricci/pandoc:latest
```

## Build command with arguments default values ##

```bash
$ docker build \
    --build-arg PANDOC_VERSION=1.19.2.1 \
    -t dgricci/pandoc:$(< VERSION) .
$ docker tag dgricci/pandoc:$(< VERSION) dgricci/pandoc:latest
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.

```bash
$ docker run --rm dgricci/pandoc:$(< VERSION)
pandoc 1.19.2.1
Compiled with pandoc-types 1.17.0.5, texmath 0.9.3, skylighting 0.1.1.5
Default user data directory: /home/ricci/.pandoc
Copyright (C) 2006-2016 John MacFarlane
Web:  http://pandoc.org
This is free software; see the source for copying conditions.
There is no warranty, not even for merchantability or fitness
for a particular purpose.
```

## An example ##

See [https://github.com/dgricci/xml-1a](XML training, 1st part) for files.

```bash
$ tree .
.
├── img
│   ├── by-nc-sa.png
│   └── crs.jpeg
└── XML1-A.md

1 directory, 3 files

$ docker run -e USER_ID=$UID --name="pandoc" --rm=true -v`pwd`:/tmp -w/tmp dgricci/pandoc -s -N --toc -o XML1-A.pdf XML1-A.md
$ tree .
.
├── img
│   ├── by-nc-sa.png
│   └── crs.jpeg
├── XML1-A.md
└── XML1-A.pdf

1 directory, 4 files
```

# A shell to hide the container's usage #

```bash
#!/bin/bash
#
# Exécute le container docker dgricci/pandoc
#
# Constantes :
VERSION="1.0.0"
# Variables globales :
unset show
unset noMoreOptions
#
# Exécute ou affiche une commande
# $1 : code de sortie en erreur
# $2 : commande à exécuter
run () {
    local code=$1
    local cmd=$2
    if [ -n "${show}" ] ; then
        echo "cmd: ${cmd}"
    else
        eval ${cmd}
    fi
    [ ${code} -ge 0 -a $? -ne 0 ] && {
        echo "Oops #################"
        exit ${code#-} #absolute value of code
    }
    [ ${code} -ge 0 ] && {
        return 0
    }
}
#
# Affichage d'erreur
# $1 : code de sortie
# $@ : message
echoerr () {
    local code=$1
    shift
    echo "$@" 1>&2
    usage ${code}
}
#
# Usage du shell :
# $1 : code de sortie
usage () {
    cat >&2 <<EOF
usage: `basename $0` [--help -h] | [--show|-s] argumentsAndOptions

    --help, -h          : prints this help and exits
    --show, -s          : do not execute pandoc, just show the command to be executed

    argumentsAndOptions : arguments and/or options to be handed over to pandoc
EOF
    exit $1
}
#
# main
#
cmdToExec="docker run -e USER_ID=${UID} -e USER_NAME=${USER} --name=\"pandoc$$\" --rm=true -v`pwd`:/tmp -w/tmp dgricci/pandoc pandoc"
[ $# -eq 0 ] && {
    # add option --version to positional arguments (cause none)
    set -- "--version"
}
while [ $# -gt 0 ]; do
    # protect back argument containing IFS characters ...
    arg="$1"
    [ $(echo -n ";$arg;" | tr "$IFS" "_") != ";$arg;" ] && {
        arg="\"$arg\""
    }
    if [ -n "${noMoreOptions}" ] ; then
        cmdToExec="${cmdToExec} $arg"
    else
        case $arg in
        --help|-h)
            run -1 "${cmdToExec} --help"
            usage 0
            ;;
        --show|-s)
            # -s is a pandoc option ... we expect -s to be at the beginning of
            # the positional parameters before options for pandoc !
            show=true
            noMoreOptions=true
            ;;
        --)
            noMoreOptions=true
            ;;
        *)
            [ -z "${noMoreOptions}" ] && {
                noMoreOptions=true
            }
            cmdToExec="${cmdToExec} $arg"
            ;;
        esac
    fi
    shift
done

run 100 "${cmdToExec}"

exit 0
```

__Et voilà !__


_fin du document[^pandoc_gen]_

[^pandoc_gen]: document généré via $ `docker run -e USER_ID="`id -u`" --name="pandoc" --rm -v`pwd`:/tmp -w/tmp dgricci/pandoc --latex-engine=xelatex -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o pandoc.pdf README.md`{.bash}

