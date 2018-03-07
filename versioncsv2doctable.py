#!/usr/bin/python

import sys
import pprint

indent=2

t_in='<table style="border-collapse: collapse; border: solid 1px black;">'
t_out='</table>'

th_in='<th style="border: 1px solid black; text-align:center;">'
th_out='</th>'

td_in='<td style="border: 1px solid black; text-align:center;">'
td_out='</td>'

pp = pprint.PrettyPrinter()

in_header = sys.stdin.readline().rstrip()
in_header = in_header.split(',')
(PkgBundleFriendlyname,PkgDlURLRoot)=in_header[1].split(';')

PkgList=[]

for item in in_header[2:]:
  item.rstrip()
  (name,repo)=item.split(';')
  PkgList.append({'PkgName':name, 'PkgRepoURL':repo})


PkgTable={}

in_data = sys.stdin.readline().rstrip()

while in_data:
  if in_data == '': break
  in_data=in_data.split(',')

  #print "New dataline ---"
  #print in_data

  branch=in_data[0]

  if not (branch in PkgTable.keys()):
    PkgTable[branch]=[]
    #print PkgTable

  Packages=[]

  for item in in_data[2:]:
    item.rstrip()
    item+=";0"
    (version,hash)=item.split(';')[:2]
    Packages.append({'PackageVersion':version, 'PackageHash':hash})

  PkgTable[branch].append({'BundleVersion':in_data[1], 'Packages':Packages})
    

  #print PkgTable

  in_data = sys.stdin.readline().rstrip()

#print PkgBundleFriendlyname
#print PkgDlURLRoot
#pp.pprint(PkgList)
#pp.pprint(PkgTable)


for branch in PkgTable.keys():
  title = branch + " branch version table"
  print
  print title.capitalize()
  print '*'*len(title)
  print

  print '.. raw:: html'
  print

  print ' '*indent*1 + t_in

  print ' '*indent*2 + '<thead>'
  print ' '*indent*3 + '<tr>'
  print ' '*indent*4 + th_in + PkgBundleFriendlyname + th_out

  for item in PkgList:
    print ' '*indent*4 + th_in + '<a href="' + item['PkgRepoURL'] + '">' + item['PkgName'] +'</a>' + th_out

  print ' '*indent*3 + '</tr>'
  print ' '*indent*2 + '</thead>'


  for line in PkgTable[branch]:
    #print line
    pkgline=line['Packages']
    print ' '*indent*3 + '<td>'
    print ' '*indent*4 + td_in + '<a href="' + PkgDlURLRoot + '/' + branch + '/' + line['BundleVersion'] + '">' + line['BundleVersion'] +'</a>' + td_out

    for i in range(0,len(pkgline)):
      item=pkgline[i]
      header=PkgList[i]
      #print item
      #print header
      print ' '*indent*4 + td_in + item['PackageVersion'] +'</a>' + td_out

    print ' '*indent*3 + '</td>'

  print ' '*indent*1 + t_out

