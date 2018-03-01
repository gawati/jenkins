#!/usr/bin/python
#
# Generates the version-compat.rst page for gawati-docs
# USAGE: 
#   python ./platform-versions.py > version-compat.rst
#
import json
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
            <th style="border: 1px solid black; text-align:center;">Gawati Auth</th>
            <th style="border: 1px solid black; text-align:center;">Gawati Client</th>
            <th style="border: 1px solid black; text-align:center;">Gawati Client Server</th>
            <th style="border: 1px solid black; text-align:center;">Gawati Client Data</th>
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
            <td style="border: 1px solid black; text-align:center;">$gawati_auth</td>
            <td style="border: 1px solid black; text-align:center;">$gawati_client</td>
            <td style="border: 1px solid black; text-align:center;">$gawati_client_server</td>
            <td style="border: 1px solid black; text-align:center;">$gawati_client_data</td>
        </tr>
    """)

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
            if pkg["version"] == "unrel":
                pkg_map[pkg["name"].replace("-", "_")] = "N/A"
            else:
                pkg_tmpl = Template("""
                    <a href="$pkg_url">$pkg_version</a>
                    """)
                pkg_url = {"pkg_url": pkg["url"] + "commit/" + pkg["git-hash"], "pkg_version": pkg["version"]}
                pkg_map[pkg["name"].replace("-", "_")] = pkg_tmpl.substitute(pkg_url)
        output_table.append(ROW_TEMPLATE.substitute(pkg_map))     
    return ''.join(output_table)


pkg_data = open("platform-versions.json").read()

pkg_json = json.loads(pkg_data)

print(DOC_TEMPLATE.substitute({"table": generate_table(pkg_json)}))
