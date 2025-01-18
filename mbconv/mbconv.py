#!/usr/bin/python3
# +----------------------------------------------------------------------------+
# | MBConv v0.1 * Modbus register number/address converter utility             |
# | Copyright (C) 2024 Pozsar Zsolt <pozsarzs@gmail.com>                       |
# | mbconv.py                                                                  |
# | Python version of the original mbconv ModShell script                      |
# +----------------------------------------------------------------------------+
# 
# This program is free software: you can redistribute it and/or modify it
# under the terms of the European Union Public License 1.2 version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.

import sys

# VARIABLES AND CONSTANTS
global raddress
global rnumber
global rtype
global OFFSET
global MSG
global REGTYPE

OFFSET = 10000
MSG = ['' for x in range(15)]
MSG = ['MBConv v0.1 * Modbus register number/address converter utility',
       '(C) 2024 Pozsar Zsolt <http://www.pozsarzs.hu>',
       'Usage:',
       '  mbconv register_number',
       '  mbconv c|d|i|h address',
       ' discrete output coils',
       ' discrete input contacts',
       'ERROR:',
       ' analog input registers',
       ' analog output holding registers',
       '  register number:   ',
       '  register type:    ',
       '  register address:  ',
       ' The register type can be c, d, i and h.',
       ' The address can be 0-9998.',
       ' The register number can be 1-9999, 10001-19999, 30001-39999 and 40001-49999.']

REGTYPE = ['' for x in range(5)]
REGTYPE = ['c','d','_','i','h']

# CHECK REGISTER TYPE
# result: 0,1,3,4 or 255
def chkregtype(s):
  r = 255
  for b in range(5):
    if s == REGTYPE[b]:
      r = b
  if r == 2:
     r = 255
  return r

# CHECK REGISTER ADDRESS
# result: 0 or 255
def chkregaddr(s):
  valid = 255
  try:
    i = int(s)
  except:
    return 255
  if (i >= 0) and (i <= 9998):
    valid = 0
  return valid

# CHECK REGISTER NUMBER
# result: 0,1,3,4 or 255
def chkregnum(s):
  valid = 255
  try:
    w = int(s)
  except:
    return 255
  if (w >= 1) and (w <= 9999): valid = 0;
  if (w >= 10001) and (w <= 19999): valid = 1;
  if (w >= 30001) and (w <= 39999): valid = 3;
  if (w >= 40001) and (w <= 49999): valid = 4;
  return valid

# PRINT SPLITTER
def splitter():
  s = '  '
  for i in range(51):
    s = s + '-'
  print(s)

# MAIN
valid = 255
if len(sys.argv) == 1:
  # print usage
  for i in range(2,5):
    print(MSG[i])
  sys.exit(1)
# print header and select operation mode
for i in range(0,2):
  print(MSG[i])
print('')
if len(sys.argv) == 2:
  # CONVERT REGISTER NUMBER TO ADDRESS
  valid = chkregnum(sys.argv[1])
  if (valid == 255):
    # error: bad register number
    print(MSG[7] + MSG[15])
    sys.exit(2)
  rtype = valid + 5
  rnumber = int(sys.argv[1])
  if (rnumber == 0):
    inc =+ 1
  # print register number
  print(MSG[10], rnumber)
  # print splitter
  splitter()
  # print register type
  print(MSG[11], MSG[rtype])
  # print register address
  raddress = rnumber - ((OFFSET * valid) + 1)
  print(MSG[12], raddress, ' (' + hex(raddress) + ')');
else:
  # CONVERT ADDRESS TO REGISTER NUMBER
  # check register type
  valid = chkregtype(sys.argv[1])
  if (valid == 255):
    # error: bad type
    print(MSG[7] + MSG[13])
    sys.exit(3)
  rtype = valid
  # check register address
  valid = chkregaddr(sys.argv[2])
  if (valid == 255):
    # error: bad address
    print(MSG[7] + MSG[14])
    sys.exit(4)
  raddress = int(sys.argv[2])
  # print register address
  print(MSG[12], raddress, ' (' + hex(raddress) + ')')
  # print register type
  print(MSG[11], MSG[rtype + 5])
  # print splitter
  splitter()
  # print register number
  rnumber = (OFFSET * rtype) + raddress + 1
  print(MSG[10], rnumber)
sys.exit(0)
