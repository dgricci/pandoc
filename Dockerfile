## Dockerfile for a pandoc environment
## Cf. https://github.com/jagregory/pandoc-docker/blob/master/Dockerfile
## from James Gregory <james@jagregory.com>
FROM       dgricci/haskell:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
# Cf. https://hackage.haskell.org/package/pandoc for pandoc version
ARG PANDOC_VERSION
ENV PANDOC_VERSION   ${PANDOC_VERSION:-1.19.2.1}

# install pandoc globally to prevent : error: exec: "/root/.cabal/bin/pandoc": stat /root/.cabal/bin/pandoc: permission denied
RUN \
    apt-get -qy update && \
    cabal update && \
    cabal install --global \
        unix \
        time \
        pandoc-${PANDOC_VERSION} \
        pandoc-include \
    && \
    apt-get -qy install \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-lang-french \
        texlive-font-utils \
        texlive-fonts-recommended \
        texlive-pictures \
        texlive-pstricks \
        texlive-xetex \
    && \
    rm -rf /var/lib/apt/lists/*

# default command : launch pandoc's version
CMD ["pandoc", "--version"]

