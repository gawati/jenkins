#!/usr/bin/python
#
# Generates the version-compat.rst page for gawati-docs
# USAGE: 
#   python ./platform-versions.py 
# creates a version-compat.rst and version-info.rst in the current folder
#
import json
import os
import io
import sys
from string import Template

DOC_TEMPLATE = Template("""Version Compatibility Chart
###########################

GAWATI VERSION - is a composite version number attached to the entire stack and identifies a specific combination of packages which are compatible.

.. raw:: html
    
    <table style="border-collapse: collapse; border: solid 1px black;">
    $table
    </table>

    """)

HEADER_TEMPLATE = """
    <thead>
        <tr>
            <th style="border: 1px solid black; text-align:center;">Gawati Version</th>
            <th style="border: 1px solid black; text-align:center;">Portal UI</th>
            <th style="border: 1px solid black; text-align:center;">Portal Server</th>
            <th style="border: 1px solid black; text-align:center;">Gawati Data</th>
            <th style="border: 1px solid black; text-align:center;">Gawati Data XML</th>
        </tr>
    </thead>
    """

ROW_TEMPLATE = Template("""
        <tr>
            <td style="border: 1px solid black; text-align:center;">$version</td>
            <td style="border: 1px solid black; text-align:center;">$portal_ui</td>
            <td style="border: 1px solid black; text-align:center;">$portal_server</td>
            <td style="border: 1px solid black; text-align:center;">$gawati_data</td>
            <td style="border: 1px solid black; text-align:center;">$gw_data</td>
        </tr>
    """)


VERSION_INFO_HEADER_RST = Template("""
**Current Version** 

  * GAWATI $version

    """)

VERSION_INFO_ITEM_RST = Template("""
    - `$PkgName <$PkgGitURL>`_ : `$PkgVersion <$PkgGitHashURL>`_
    """)  

VERSION_INFO_FOOTER_RST = """

  See full :doc:`Version Compatibility Chart <./version-compat>`.
    """


def files(path):
    for file in os.listdir(path):
        if (os.path.isfile(os.path.join(path, file))):
            yield file

def read_kv_file(fileName):
    myvars = {}
    with open(fileName) as kvfile:
        for line in kvfile:
            name, var = line.partition("=")[::2]
            myvars[name.strip()] = var.strip().replace('"', '')
    return myvars


def gawati_packages():
    return [file for file in files("versions")]

def versions(vType):
    return os.listdir(os.path.join("versions", vType))


def platform_versions(packageMode): 
    gwPackages = gawati_packages()
    devVersions = versions(packageMode)
    masterVersions = {"name": "gawati", "versions": []}
    for devVersion in devVersions:
        version = { "version" : devVersion, "packages": [] }
        for gwPackage in gwPackages:
            objPackage = read_kv_file(os.path.join("versions", gwPackage))
            objPackageExtended = read_kv_file(
                os.path.join(
                    "versions", 
                    packageMode, 
                    devVersion, 
                    objPackage["PkgName"]
                )
            )
            objPackage.update(objPackageExtended)
            version["packages"].append(objPackage)
        masterVersions["versions"].append(version)
    return masterVersions


def generate_table(pkg_json):
    output_table = []
    pkg_versions = pkg_json["versions"]
    output_table.append(HEADER_TEMPLATE)
    for pkg_version in pkg_versions:
        version = pkg_version['version']
        pkgs = pkg_version['packages']
        pkg_map = {}
        pkg_map["version"] = version
        for pkg in pkgs:
            #if pkg["version"] == "unrel":
            #    pkg_map[pkg["name"].replace("-", "_")] = "N/A"
            #else:
            pkg_tmpl = Template("""
                <a href="$pkg_url">$pkg_version</a>
                """)
            pkg_url = {"pkg_url": pkg["PkgGitURL"] + "/commit/" + pkg["PkgGitHash"], "pkg_version": pkg["PkgVersion"]}
            pkg_map[pkg["PkgName"].replace("-", "_")] = pkg_tmpl.substitute(pkg_url)
        output_table.append(ROW_TEMPLATE.substitute(pkg_map))     
    return ''.join(output_table)

def version_info_page(this_version):
    output_page = []
    output_page.append(VERSION_INFO_HEADER_RST.substitute({'version': this_version['version']}))
    pkgs = this_version["packages"]
    for pkg in pkgs:
        output_page.append(VERSION_INFO_ITEM_RST.substitute({
            'PkgName': pkg['PkgName'], 
            'PkgGitURL': pkg['PkgGitURL'],
            'PkgVersion': pkg['PkgVersion'],
            'PkgGitHashURL': pkg["PkgGitURL"] + "/commit/" + pkg["PkgGitHash"]
        }))
    output_page.append(VERSION_INFO_FOOTER_RST)
    return ''.join(output_page)

pkg_versions = platform_versions("dev")


version_info = version_info_page(pkg_versions['versions'][0])

#pkg_versions_string = json.dumps(platform_versions("dev"))

#pkg_versions = json.loads(pkg_versions_string)

# process Unicode text
with io.open('version-compat.rst','w',encoding='utf8') as f:
    f.write(DOC_TEMPLATE.substitute({"table": generate_table(pkg_versions)}))

with io.open('version-info.rst', 'w', encoding='utf8') as f:
    f.write(version_info)