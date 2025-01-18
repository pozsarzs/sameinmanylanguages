{ +--------------------------------------------------------------------------+ }
{ | MBConv v0.1 * Modbus register number/address converter utility           | }
{ | Copyright (C) 2024 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | mbconv.pas                                                               | }
{ | Turbo Pascal version of the original mbconv ModShell script              | }
{ +--------------------------------------------------------------------------+ }
{ 
  This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.
}

program mbconv;
{ VARIABLES AND CONSTANTS }
var
  b: byte;
  e: integer;
  raddress: integer;
  rnumber: word;
  rtype: byte;
  valid: byte;
const
  OFFSET: integer = 10000;
  MSG: array[0..15] of string =
       (
        'MBConv v0.1 * Modbus register number/address converter utility',
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
        ' The register number can be 1-9999, 10001-19999, 30001-39999 and 40001-49999.'
       );
  REGTYPE: array[0..4] of char =('c','d','_','i','h');

{ PRINT SPLITTER }
procedure splitter;
var
  b: byte;
begin
  write('  ');
  for b := 1 to 50 do write('-');
  writeln;
end;

{ CONVERT DEC -> HEX }
function dec2hex(i: integer): string;
const
  hexdigits: array[0..15] of char = '0123456789ABCDEF';
var
  s: string;
  r: integer;
begin
  s := '';
  repeat
    r := i mod 16;
    s := hexdigits[r] + s;
    i := i div 16;
  until i = 0;
  dec2hex := s;
end;

{ CHECK REGISTER TYPE }
{ result: 0,1,3,4 or 255 }
function chkregtype(s: string): byte;
var
  b, r: byte;
begin
  r := 255;
  for b := 0 to 4 do
    if s = regtype[b] then r := b;
  if r = 2 then r := 255;
  chkregtype := r;
end;

{ CHECK REGISTER ADDRESS }
{ result: 0 or 255 }
function chkregaddr(s: string): byte;
var
  i: integer;
begin
  chkregaddr := 255;
  val(s, i, e);
  if (i >= 0) and (i <= 9998) then chkregaddr := 0;
end;

{ CHECK REGISTER NUMBER }
{ result: 0,1,3,4 or 255 }
function chkregnum(s: string): byte;
var
  w: word;
begin
  chkregnum := 255;
  val(s, w, e);
  if (w >= 1) and (w <= 9999) then chkregnum := 0;
  if (w >= 10001) and (w <= 19999) then chkregnum := 1;
  if (w >= 30001) and (w <= 39999) then chkregnum := 3;
  if (w >= 40001) and (w <= 49999) then chkregnum := 4;
end;

{ MAIN }
begin
  valid := 255;
  if length(paramstr(1)) = 0 then 
  begin
    { print usage }
    for b := 2 to 4 do writeln(MSG[b]);
    halt(1);
  end;
  { print header and select operation mode }
  for b := 0 to 1 do writeln(MSG[b]);
  writeln;
  if paramcount = 1 then
  begin
    { CONVERT REGISTER NUMBER TO ADDRESS }
    valid := chkregnum(paramstr(1));
    if valid = 255 then
    begin
      { error: bad register number }
      writeln(MSG[7] + MSG[15]);
      halt(2);
    end;
    rtype := valid + 5;
    val(paramstr(1), rnumber, e);
    if rnumber = 0 then inc(rnumber);
    { print register number }
    writeln(MSG[10], rnumber);
    { print splitter }
    splitter;
    { print register type }
    writeln(MSG[11], MSG[rtype]);
    { print register address }
    raddress := rnumber - ((OFFSET * valid) + 1);
    writeln(MSG[12], raddress, ' (', dec2hex(raddress), 'h)');
  end else
  begin
    { CONVERT ADDRESS TO REGISTER NUMBER }
    { check register type }
    valid := chkregtype(paramstr(1));
    if valid = 255 then
    begin
      { error: bad type }
      writeln(MSG[7] + MSG[13]);
      halt(3);
    end;
    rtype := valid;
    { check register address }
    valid := chkregaddr(paramstr(2));
    if valid = 255 then
    begin
      { error: bad address }
      writeln(MSG[7] + MSG[14]);
      halt(4);
    end;
    val(paramstr(2), raddress, e);
    { print register address }
    writeln(MSG[12], raddress, ' (', dec2hex(raddress), 'h)');
    { print register type }
    writeln(MSG[11], MSG[rtype + 5]);
    { print splitter }
    splitter;
    { print register number }
    rnumber := (OFFSET * rtype) + raddress + 1;
    writeln(MSG[10], rnumber);
  end;
  halt(0);
end.
