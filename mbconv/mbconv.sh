#!/bin/bash
# +----------------------------------------------------------------------------+
# | MBConv v0.1 * Modbus register number/address converter utility             |
# | Copyright (C) 2023-2024 Pozsar Zsolt <pozsarzs@gmail.com>                  |
# | mbconv.sh                                                                  |
# | Bash shellscript version of the original mbconv ModShell script            |
# +----------------------------------------------------------------------------+
# 
# This program is free software: you can redistribute it and/or modify it
# under the terms of the European Union Public License 1.2 version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.

# VARIABLES AND CONSTANTS
OFFSET=10000
MSG=('MBConv v0.1 - Modbus register number/address converter utility' \
     '(C) 2024 Pozsar Zsolt <http://www.pozsarzs.hu>' \
     'Usage:' \
     '\tmbconv register_number' \
     '\tmbconv c|d|i|h address' \
     'discrete output coils' \
     'discrete input contacts' \
     'ERROR:' \
     'analog input registers' \
     'analog output holding registers' \
     'register number:\t' \
     'register type:\t' \
     'register address:\t' \
     'The register type can be c, d, i and h.' \
     'The address can be 0-9998.' \
     'The register number can be 1-9999, 10001-19999, 30001-39999 and 40001-49999.')
REGTYPE=('c' 'd' '_' 'i' 'h')

# PRINT SPLITTER
splitter()
{
  echo -n '  '
  for i in $(seq 1 54); do
    echo -n '-'
  done
  echo ''
}

# CHECK REGISTER TYPE
# result: 0,1,3,4 or 255
chkregtype()
{
  r=255
  for b in $(seq 0 4); do
    if [ $1 = ${REGTYPE[b]} ];
    then
      r=$b
    fi
  done
  if [ $r -eq 2 ];
  then
     r=255
  fi
  return $r
}

# CHECK REGISTER ADDRESS
# result: 0 or 255
chkregaddr()
{
  valid=255
  if [[ $1 -ne 0 ]] && [[ $1 -le 9998 ]];
  then
    valid=0
  fi
  return $valid
}

# CHECK REGISTER NUMBER
# result: 0,1,3,4 or 255
chkregnum()
{
  valid=255
  if [[ $1 -ge 1 ]] && [[ $1 -le 9999 ]]; then valid=0; fi
  if [[ $1 -ge 10001 ]] && [[ $1 -le 19999 ]]; then valid=1; fi
  if [[ $1 -ge 30001 ]] && [[ $1 -le 39999 ]]; then valid=3; fi
  if [[ $1 -ge 40001 ]] && [[ $1 -le 49999 ]]; then valid=4; fi
  return $valid
}

# MAIN
valid=255
if [ $# -eq 0 ];
then
  # print usage
  for i in $(seq 2 4); do
    echo -e ${MSG[$i]} 
  done
  exit 1
fi
# print header and select operation mode
for i in $(seq 0 1); do
  echo -e ${MSG[$i]} 
done
echo ''
if [ $# -eq 1 ];
then
  # CONVERT REGISTER NUMBER TO ADDRESS
  if [[ $1 =~ ^[0-9]+$ ]];
  then
    chkregnum $1
    valid=$?
   else
     valid=255
  fi
  if [ $valid -eq 255 ];
  then
    # error: bad register number
    echo ${MSG[7]} ${MSG[15]}
    exit 2
  fi
  let rtype=$valid+5
  rnumber=$1
  if [ $rnumber -eq 0 ]; then rnumber=rnumber+1; fi
  # print register number
  echo -e ' ' ${MSG[10]} $rnumber
  # print splitter
  splitter
  # print register type
  echo -e ' ' ${MSG[11]} ${MSG[$rtype]}
  # print register address
  let raddress=$rnumber+1-$OFFSET*$valid
  printf "  ${MSG[12]} %d (%Xh)\n" $raddress $raddress
else
  # CONVERT ADDRESS TO REGISTER NUMBER
  # check register type
  chkregtype $1
  valid=$?
  if [ $valid -eq 255 ];
  then
    # error: bad type
    echo ${MSG[7]} ${MSG[13]}
    exit 3
  fi
  rtype=$valid
  # check register address
  if [[ $2 =~ ^[0-9]+$ ]];
  then
    chkregaddr $2
    valid=$?
   else
     valid=255
  fi
  if [ $valid -eq 255 ];
  then
    # error: bad address
    echo ${MSG[7]} ${MSG[14]}
    exit 4
  fi
  raddress=$2
  # print register address
  printf "  ${MSG[12]} %d (%Xh)\n" $raddress $raddress
  # print register type
  echo -e ' ' ${MSG[11]} ${MSG[$rtype+5]}
  # print splitter
  splitter
  # print register number
  let rnumber=($OFFSET*$rtype)+$raddress+1
  echo -e ' ' ${MSG[10]} $rnumber
fi
exit 0
