#!/bin/bash
#trap "exit 1" TERM

DEBUG=2
export PkgDataFile="jenkinsPkgDataFile.txt"


COLOR_OFF='\033[0m'
COLOR_0='\033[0m'
COLOR_1='\033[0;32m'
COLOR_2='\033[0;33m'
COLOR_3='\033[0;31m'
COLOR_4='\033[0;96m'


function message {
  [ "$#" -gt 2 ] && {
    [ "${3}" -lt "${DEBUG}" ] && return 0
    }
  COLOR_ON="`eval echo \$\{COLOR_${1}\}`"
  echo -e "${COLOR_ON}${2}${COLOR_OFF}"
  }


function bail_out {
  message 3 "${2}"
  kill -s TERM ${MYPID}
  }


function vardebug {
  for VARIABLE in $* ; do
    message 4 "${VARIABLE}: >${!VARIABLE}<" 2
    done
  }


function SourcePkgData {
  [ -f 'package.json' ] && {
    message 4 "Reading package.json" 2
    npm --loglevel silent run vars > "${PkgDataFile}"
    export PkgName="`grep '^npm_package_name=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^npm_package_version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  [ -f 'build.xml' ] && {
    message 4 "Reading build.xml" 2
    ant vars | grep '^\[echoproperties\] ' | sed 's%^\[echoproperties\] \(.*\)$%\1%g' | grep -v '^#' > "${PkgDataFile}"
    export PkgName="`grep '^package(abbrev)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^package(version)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  export PkgGitHash="${GIT_COMMIT:-`git log --format="%H" -1 2>/dev/null`}"

  export PkgFileGit="${PkgName}-${PkgGitHash}"
  export PkgFileVer="${PkgName}-${PkgVersion}"
  export PkgFileLst="${PkgName}-latest"

  vardebug PkgName PkgVersion PkgGitHash PkgFileGit PkgFileVer PkgFileLst
  }


function PkgProvide {
  zip -r - . > "$DLD/${PkgFileGit}.zip"
  tar -cvjf "${DLD}/${PkgFileGit}.tbz" .

  for FTYP in zip tbz ; do
    [ -L "${DLD}/${PkgFileLst}.${FTYP}" ] && rm -f "${DLD}/${PkgFileLst}.${FTYP}"
    [ -e "${DLD}/${PkgFileLst}.${FTYP}" ] || ln -s "${PkgFileGit}.${FTYP}" "${DLD}/${PkgFileLst}.${FTYP}"
    [ -L "${DLD}/${PkgFileVer}.${FTYP}" ] && rm -f "${DLD}/${PkgFileVer}.${FTYP}"
    [ -e "${DLD}/${PkgFileVer}.${FTYP}" ] || ln -s "${PkgFileGit}.${FTYP}" "${DLD}/${PkgFileVer}.${FTYP}"
    done
  }

SourcePkgData

