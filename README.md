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
    - 0.0.6 : 08/04/2018  

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
    --build-arg PANDOC_VERSION=2.1.3 \
    -t dgricci/pandoc:$(< VERSION) .
$ docker tag dgricci/pandoc:$(< VERSION) dgricci/pandoc:latest
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.

```bash
$ docker run --rm dgricci/pandoc:$(< VERSION)
pandoc 2.1.3
Compiled with pandoc-types 1.17.4.2, texmath 0.10.1.1, skylighting 0.7.1
Default user data directory: /root/.pandoc
Copyright (C) 2006-2018 John MacFarlane
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

## A shell to hide container's usage ##

As a matter of fact, typing the `docker run ...` long command is painfull !  
In the [bin directory, the pandoc.sh bash shell](bin/pandoc.sh) can be invoked
to ease the use of such a container. For instance (we suppose that the shell
script has been copied in a bin directory and is in the user's PATH) :

```bash
$ cd whatever/bin
$ ln -s pandoc.sh pandoc
$ pandoc --version
pandoc 2.1.3
Compiled with pandoc-types 1.17.4.2, texmath 0.10.1.1, skylighting 0.7.1
Default user data directory: /root/.pandoc
Copyright (C) 2006-2018 John MacFarlane
Web:  http://pandoc.org
This is free software; see the source for copying conditions.
There is no warranty, not even for merchantability or fitness
for a particular purpose.
```

# Miscellaneous #

See all [https://github.com/danstoner/pandoc_samples](sample pandoc-generated PDF font examples)

Getting all fonts on your system :

```bash
$ fc-list --format="%{family}\n" | cut -f1 -d, | sort | uniq
```


__Et voilà !__


_fin du document[^pandoc_gen]_

[^pandoc_gen]: document généré via $ `docker run -e USER_ID="`id -u`" --name="pandoc" --rm -v`pwd`:/tmp -w/tmp dgricci/pandoc pandoc --latex-engine=xelatex -V mainfont="DejaVu Sans" -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o pandoc.pdf README.md`{.bash}

