## Dockerfile for a pandoc environment
## Cf. https://github.com/jagregory/pandoc-docker/blob/master/Dockerfile
## from James Gregory <james@jagregory.com>
FROM       dgricci/haskell:0.0.5
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
# Cf. https://hackage.haskell.org/package/pandoc for pandoc version
ARG PANDOC_VERSION
ENV PANDOC_VERSION   ${PANDOC_VERSION:-2.1.3}

# install pandoc globally to prevent : error: exec: "/root/.cabal/bin/pandoc": stat /root/.cabal/bin/pandoc: permission denied
# with cabal 2 --global is deprecated, so set user-install: False in /root/.cabal/config
# removed pandoc-include package cause of
#IncludeFilter.hs:71:53: error:
#    * Couldn't match type `[Char]' with `Data.Text.Internal.Text'
#      Expected type: Data.Text.Internal.Text
#        Actual type: String
#    * In the second argument of `readMarkdown', namely `content'
#      In the second argument of `($!)', namely `readMarkdown def content'
#      In the expression: return $! readMarkdown def content
#   |
#71 | ioReadMarkdown content = return $! readMarkdown def content
#   |                                                     ^^^^^^^
# mkdir /root/.cabal/bin/ cause of :
#/root/.cabal/bin/aeson-pretty: createSymbolicLink: does not exist (No such file or directory)
# next time try pandoc-include-code pandoc-plantuml-diagrams pandoc-placetable packages too ?
# See https://hackage.haskell.org/packages/search?terms=pandoc
RUN \
    apt-get -qy update && \
    apt-get -qy install \
        apt-utils \
        zlib1g-dev \
        unzip \
    && \
    cabal update && \
    sed -i -e 's!^-- \(user-install: \)True!\1False!' /root/.cabal/config && \
    mkdir /root/.cabal/bin && \
    cabal install --global \
        unix \
        time \
        pandoc-${PANDOC_VERSION} \
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
    apt-get purge -y \
        zlib1g-dev \
    && \
    apt-get clean -y \
    && \
    rm -rf /var/lib/apt/lists/*

# default command : launch pandoc's version
CMD ["pandoc", "--version"]

