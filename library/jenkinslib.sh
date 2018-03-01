#!/bin/bash
trap "exit 1" TERM

DEBUG=2

TreeTableOptions='style="border-collapse: collapse; border: solid 1px black;"'
TreeTableHeaderOptions='style="border: 1px solid black; text-align:center;"'
TreeTableDataOptions='style="border: 1px solid black; text-align:center;"'

[ "${JENKINS_HOME}" != "" ] && DLD="/var/www/html/dl.gawati.org"
DLD="${DLD:-/tmp/pkg}"

declare -A Branch2Folder=( ["dev"]="dev" ["master"]="prod" )


export PkgDataFile="jenkinsPkgDataFile.txt"
BRANCH="${JOB_BASE_NAME:-`git branch | cut -d ' ' -f 2`}"
REPO="repo"
ARCV="archive"

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
  #pause
  kill -s TERM ${MYPID}
  }


function vardebug {
  for VARIABLE in $* ; do
    message 4 "${VARIABLE}: >${!VARIABLE}<" 2
    done
  }


function PkgDerivedData {
  export PkgFileGit="${PkgName}-${PkgGitHash}"
  export PkgFileVer="${PkgName}-${PkgVersion}"
  export PkgFileLst="${PkgName}-latest"

  export PkgBranch="${DLD}/${Branch2Folder[${BRANCH}]}"
  export PkgRepo="${PkgBranch}/${REPO}"
  export PkgArchive="${PkgBranch}/${ARCV}"
  export PkgBundleRepo="${PkgBranch}/${PkgBundleVersion}"

  #vardebug BRANCH PkgSource PkgName PkgVersion PkgBundleVersion PkgGitURL PkgGitHash PkgFileGit PkgFileVer PkgFileLst PkgRepo PkgBranch PkgArchive PkgBundleRepo
  }


function PkgSourceFile {
  DataFile="${1}"
  [ -f "${DataFile}" ] || bail_out ">${DataFile}< is not a file."
  source "${DataFile}" || bail_out "Failed sourcing >${DataFile}< from >`pwd`<."

  PkgDerivedData
  }


function PkgSourceData {
  [ -f 'package.json' ] && {
    export PkgSource="package.json"

    npm --loglevel silent run vars > "${PkgDataFile}"
    export PkgName="`grep '^npm_package_name=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^npm_package_version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    #export PkgBundleVersion="`grep '^npm_package_gawati_version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  [ -f 'build.xml' ] && {
    export PkgSource="build.xml"

    ant vars | grep '^\[echoproperties\] ' | sed 's%^\[echoproperties\] \(.*\)$%\1%g' | grep -v '^#' > "${PkgDataFile}"
    export PkgName="`grep '^package(abbrev)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    export PkgVersion="`grep '^package(version)=' ${PkgDataFile} | cut -d '=' -f 2-`"
    #export PkgBundleVersion="`grep '^project.gawati-version=' ${PkgDataFile} | cut -d '=' -f 2-`"
    }

  export PkgName="${PKF:-${PkgName}}"
  export PkgGitHash="${GIT_COMMIT:-`git log --format="%H" -1 2>/dev/null`}"

  PkgDerivedData
  }


function TreeForAllInVersions {
  VersionFolder="${1}"
  [ -d "${VersionFolder}" ] || bail_out ">${VersionFolder}< is not a folder."

  VersionCallFunction="${2}"
  [ "`type -t ${VersionCallFunction}`" = function ] || bail_out ">${VersionCallFunction}< is not a function."

  #echo "-----"
  pushd "${VersionFolder}" >/dev/null
  VersionFolder="`pwd`"
  for BRANCH in `ls -1 -d */ 2>/dev/null | cut -d '/' -f1` ; do
    pushd "${BRANCH}" >/dev/null
    for PkgBundleVersion in `ls -1 -d */ 2>/dev/null | cut -d '/' -f1` ; do
      pushd "${PkgBundleVersion}" >/dev/null
      for FILE in `ls -p 2>/dev/null | grep -v /` ; do
        [ -f "${VersionFolder}/${FILE}" ] && source "${VersionFolder}/${FILE}"
        [ -f "${VersionFolder}/${BRANCH}/${FILE}" ] && source "${VersionFolder}/${BRANCH}/${FILE}"
        source "${FILE}"
        PkgDerivedData
        ${VersionCallFunction}
        #echo "-----"
        done
      popd >/dev/null
      done
    popd >/dev/null
    done
  popd >/dev/null
  }


function TreeMakeBundleLinks {
  VersionFolder="${1}"

  TreeForAllInVersions "${VersionFolder}" PkgLinkBundle
  }


function TreeAddComponent {
  TreeComponents+=" ${PkgName}"
  }


function TreeListComponents {
  VersionFolder="${1}"

  TreeComponents=""
  TreeForAllInVersions "${VersionFolder}" TreeAddComponent
  TreeComponents="`echo ${TreeComponents} | xargs -n1 | sort -u | xargs`"
  #vardebug TreeComponents
  }


function TreeMakeComponentTableDataRow {
  BundleChanged="n"
  [ "${LastBRANCH}${LastPkgBundleVersion}" != "${BRANCH}${PkgBundleVersion}" ] && BundleChanged="y"

  [ "${BundleChanged}" = "y" ] && {
    TreeColumn=0
    echo -n "${LastAppend}"
    echo -n "${Branch2Folder[${BRANCH}]},${PkgBundleVersion}"
    LastAppend=""
    }
  TreeColumn=$((TreeColumn+1))

  #if current column matches package name echo "            <td ${TreeTableDataOptions}>${PkgVersion}</td>"
  [ "${PkgName}" = "`echo ${TreeComponents} | cut -d ' ' -f ${TreeColumn}`" ] && echo -n ",${PkgVersion};${PkgGitHash}" || echo -n ",N/A"

  [ "${BundleChanged}" = "y" ] && {
    LastAppend=$'\n'
    LastBRANCH="${BRANCH}"
    LastPkgBundleVersion="${PkgBundleVersion}"
    }
  }


function TreeMakeComponentTableData {
  VersionFolder="${1}"

  LastBRANCH=""
  LastPkgBundleVersion=""
  LastAppend=""
  TreeForAllInVersions "${VersionFolder}" TreeMakeComponentTableDataRow
  echo -n "${LastAppend}"
  LastAppend=""
  }


function TreeMakeComponentsTable {
  VersionFolder="${1}"

  TreeListComponents "${VersionFolder}"

  echo -n "Branch,Gawati Version"

  for Component in ${TreeComponents} ; do
    PkgFile="${VersionFolder}/${Component}"
    [ -f "${PkgFile}" ] || bail_out ">${PkgFile}< not a file."
    source "${PkgFile}"
    echo -n ",${PkgFriendlyName};${PkgGitURL}"
    done
  echo

  TreeMakeComponentTableData "${VersionFolder}"
  }


function ForceLink {
  LINK="${1}"
  TARGET="${2}"

  [ -L "${LINK}" ] && rm -f "${LINK}"
  [ -e "${LINK}" ] || ln -s "${TARGET}" "${LINK}"
  }


function PkgLinkLatest {
  for FTYP in ${PkgResources} ; do
    ForceLink "${PkgBranch}/${PkgFileLst}.${FTYP}" "${REPO}/${PkgFileGit}.${FTYP}"
    ForceLink "${PkgArchive}/${PkgFileVer}.${FTYP}" "../${REPO}/${PkgFileGit}.${FTYP}"
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
  PkgLinkLatest
  PkgLinkBundle
  }


function PkgEnsureRepo {
  [ -e "${DLD}" ] || bail_out "Package folder >${DLD}< does not exist."
  [ -d "${DLD}" ] || bail_out ">${DLD}< not a folder."

  for FOLDER in "${PkgBranch}" "${PkgRepo}" "${PkgArchive}" ; do
    [ -e "${FOLDER}" ] || mkdir -p "${FOLDER}"
    [ -d "${FOLDER}" ] || bail_out ">${FOLDER}< not a folder."
    done
  }


function PkgPack {
  PkgEnsureRepo
  zip -r - . > "${PkgRepo}/${PkgFileGit}.zip"
  tar -cvjf "${PkgRepo}/${PkgFileGit}.tbz" ./*
  PkgResources="zip tbz"
  }


function PkgXar {
  PkgEnsureRepo
  zip -r - . > "${PkgRepo}/${PkgFileGit}.xar"
  PkgResources="xar"
  }


MYPID=$$

PkgSourceData

#message 4 "To reread package information into environment run: PkgSourceData" 1
#message 4 "To write zip/tarball of cwd into ${PkgBranch} run: PkgPack" 1

