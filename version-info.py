import json
import os
import io
import sys
from string import Template

__version__ = "1.0.18"
__mode__ = "dev"

def read_kv_file(fileName):
    myvars = {}
    if os.path.isfile(fileName):
        with open(fileName) as kvfile:
            for line in kvfile:
                name, var = line.partition("=")[::2]
                myvars[name.strip()] = var.strip().replace('"', '')
        return myvars
    else:
        return myvars

def files(path):
    dir_files = []
    for file in os.listdir(path):
        """ 
        ignore directories and files starting with __ 
        """
        if (os.path.isfile(os.path.join(path, file)) and not file.startswith("__")):
            dir_files.append(file)
    return dir_files

versions_folder = os.path.join("versions")

pkg_map = {"version" : __version__, "packages" : [] }

default_json = read_kv_file(os.path.join(versions_folder, "__default"))
pkg_map.update(default_json)

pkg_files = files(os.path.join("versions"))

version_folder = os.path.join("versions", __mode__, __version__)
# get release date
pkg_rel_date = read_kv_file(os.path.join(version_folder, "__default"))
pkg_map.update(pkg_rel_date)


# get individual package files from versions root folder
for pkg_file in pkg_files:
    pkg = read_kv_file(os.path.join("versions", pkg_file))
    pkg_map["packages"].append(pkg)

# get package information for version
for pkg_item in pkg_map["packages"]:
    pkg_item_info = read_kv_file(os.path.join(version_folder, pkg_item["PkgName"]))
    pkg_item.update(pkg_item_info)

from datetime import datetime
pkg_map["PkgDownloadLink"] = pkg_map["PkgDlURLRoot"] + "/" + __mode__ +  "/" + pkg_map["version"]
pkg_rel_date = datetime.strptime( pkg_map["PkgBundleReleaseDate"], "%d.%m.%Y")
pkg_map["PkgReleasedOn"] = pkg_rel_date.strftime("%d %B %Y")


from string import Template

HEADER_TEMPLATE = Template("""
**Current Version** 

  * $PkgBundleFriendlyname $version  `download link <$PkgDownloadLink>`_ , released on: $PkgReleasedOn
""")

BODY_TEMPLATE = Template("""
    - `$PkgName <$PkgGitURL>`_ : `$PkgVersion <$PkgGitURL/tree/$PkgGitHash>`_
""")

version_info_tmpl = []
version_info_tmpl.append(HEADER_TEMPLATE.substitute(pkg_map))

for pkg_item in pkg_map["packages"]:
    try:
        pkg_item_tmpl = BODY_TEMPLATE.substitute(pkg_item)
        version_info_tmpl.append(pkg_item_tmpl)
    except:
        pass

print("".join(version_info_tmpl))








    

