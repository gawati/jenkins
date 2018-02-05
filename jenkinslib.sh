function PkgProvide {
  PKGgit="${npm_package_name}-${npm_package_gitHead}"
  PKGver="${npm_package_name}-${npm_package_version}"
  PKGlst="${npm_package_name}-latest"

  zip -r - . > "$DLD/${PKGgit}.zip"
  tar -cvjf "${DLD}/${PKGgit}.tbz" .

  for FTYP in zip tbz ; do
    [ -L "${DLD}/${PKGlst}.${FTYP}" ] && rm -f "${DLD}/${PKGlst}.${FTYP}"
    [ -e "${DLD}/${PKGlst}.${FTYP}" ] || ln -s "${PKGgit}.${FTYP}" "${DLD}/${PKGlst}.${FTYP}"
    [ -L "${DLD}/${PKGver}.${FTYP}" ] && rm -f "${DLD}/${PKGver}.${FTYP}"
    [ -e "${DLD}/${PKGver}.${FTYP}" ] || ln -s "${PKGgit}.${FTYP}" "${DLD}/${PKGver}.${FTYP}"
    done

