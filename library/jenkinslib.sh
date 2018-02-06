#!/bin/bash
trap "exit 1" TERM

DEBUG=2

DLD="${DLD:-/tmp}"
REPO="repo"
export PkgDataFile="jenkinsPkgDataFile.txt"


COLOR_OFF='\033[0m'
COLOR_0='\033[0m'
COLOR_1='\033[0;32m'
COLOR_2='\033[0;33m'
COLOR_3='\033[0;31m'
COLOR_4='\033[0;96m'


function message {
  [ "$#" -gt 2 ] && {
    [ "${3}" -gt "${DEBUG}" ] && return 0
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


function PkgSourceData {
  [ -f 'package.json' ] && {
    export PkgSource="package.json"

    npm --loglevel silent run vars > "${PkgDataFile}"
    export PkgName="`grep '^npm_package_name=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^npm_package_version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgBundleVersion="`grep '^npm_package_gawati_version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  [ -f 'build.xml' ] && {
    export PkgSource="build.xml"

    ant vars | grep '^\[echoproperties\] ' | sed 's%^\[echoproperties\] \(.*\)$%\1%g' | grep -v '^#' > "${PkgDataFile}"
    export PkgName="`grep '^package(abbrev)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^package(version)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgBundleVersion="`grep '^package.gawati-version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  export PkgName="${PKF:-${PkgName}}"

  export PkgGitHash="${GIT_COMMIT:-`git log --format="%H" -1 2>/dev/null`}"

  export PkgFileGit="${PkgName}-${PkgGitHash}"
  export PkgFileVer="${PkgName}-${PkgVersion}"
  export PkgFileLst="${PkgName}-latest"

  export PkgRepo="${DLD}/${REPO}"
  export PkgBundleRepo="${DLD}/${PkgBundleVersion}"

  vardebug PkgSource PkgName PkgVersion PkgBundleVersion PkgGitHash PkgFileGit PkgFileVer PkgFileLst PkgRepo PkgBundleRepo
  }


function ForceLink {
  LINK="${1}"
  TARGET="${2}"

  [ -L "${LINK}" ] && rm -f "${LINK}"
  [ -e "${LINK}" ] || ln -s "${TARGET}" "${LINK}"
  }


function PkgLinkRoot {
  for FTYP in ${PkgResources} ; do
    ForceLink "${DLD}/${PkgFileLst}.${FTYP}" "${REPO}/${PkgFileGit}.${FTYP}"
    ForceLink "${DLD}/${PkgFileVer}.${FTYP}" "${REPO}/${PkgFileGit}.${FTYP}"
    done
  }


function PkgLinkBundle {
  [ -e "${PkgBundleRepo}" ] || mkdir -p "${PkgBundleRepo}"
  [ -d "${PkgBundleRepo}" ] || bail_out ">${PkgBundleRepo}< not a folder."

  for FTYP in ${PkgResources} ; do
    ForceLink "${PkgBundleRepo}/${PkgFileVer}.${FTYP}" "../${REPO}/${PkgFileGit}.${FTYP}"
    done
  }


function PkgLinkAll {
  PkgLinkRoot
  PkgLinkBundle
  }


function PkgEnsureRepo {
  [ -e "${DLD}" ] || bail_out "Package folder >${DLD}< does not exist."
  [ -d "${DLD}" ] || bail_out ">${DLD}< not a folder."

  [ -e "${PkgRepo}" ] || mkdir -p "${PkgRepo}"
  [ -d "${PkgRepo}" ] || bail_out ">${PkgRepo}< not a folder."
  }


function PkgPack {
  PkgEnsureRepo
  zip -r - . > "${PkgRepo}/${PkgFileGit}.zip"
  tar -cvjf "${PkgRepo}/${PkgFileGit}.tbz" ./*
  PkgResources="zip tbz"
  }


MYPID=$$

PkgSourceData

message 4 "To reread package information into environment run: PkgSourceData" 1
message 4 "To write zip/tarball of cwd into ${DLD} run: PkgPack" 1

