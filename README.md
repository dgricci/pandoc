% Environnement Haskell pour pandoc
% Didier Richard
% rév. 0.0.1 du 10/07/2016
% rév. 0.0.2 du 10/08/2016
% rév. 0.0.3 du 10/09/2016

---

# Building #

```bash
$ docker build -t dgricci/pandoc:0.0.3 -t dgricci/pandoc:latest .
```

## Behind a proxy (e.g. 10.0.4.2:3128) ##

```bash
$ docker build \
    --build-arg http_proxy=http://10.0.4.2:3128/ \
    --build-arg https_proxy=http://10.0.4.2:3128/ \
    -t dgricci/pandoc:0.0.3 -t dgricci/pandoc:latest .
```

## Build command with arguments default values ##

```bash
$ docker build \
    --build-arg PANDOC_VERSION=1.17.2 \
    -t dgricci/pandoc:0.0.3 -t dgricci/pandoc:latest .
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.

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
usage: `basename $0` [--help -h] | [--show] argumentsAndOptions

    --help, -h          : prints this help and exits
    --show              : do not execute pandoc, just show the command to be executed

    argumentsAndOptions : arguments and/or options to be handed over to pandoc
EOF
    exit $1
}
#
# main
#
cmdToExec="docker run -e USER_ID=${UID} -e USER_NAME=${USER} --name=\"pandoc\" --rm=true -v`pwd`:/tmp -w/tmp dgricci/pandoc pandoc"
while [ $# -gt 0 ]; do
    if [ -n "${noMoreOptions}" ] ; then
        cmdToExec="${cmdToExec} $1"
    else
        case $1 in
        --help|-h)
            run -1 "${cmdToExec} --help"
            usage 0
            ;;
        --show)
            # -s is a pandoc option ... so it is discarded here !
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
            cmdToExec="${cmdToExec} $1"
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

[^pandoc_gen]: document généré via $ `docker run -e USER_ID="`id -u`" --name="pandoc" --rm -v`pwd`:/tmp -w/tmp dgricci/pandoc -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o pandoc.pdf README.md`{.bash}
