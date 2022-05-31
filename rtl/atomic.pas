{ atomic utils

  Copyright (C) 2018-2022 Red_prig

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.
}

unit atomic;

{$mode objfpc}{$H+}

interface

Const
 CacheLineSize=64;

function  load_consume(Var addr:Pointer):Pointer; inline;
function  load_consume(Var addr:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  load_consume(Var addr:DWORD):DWORD; inline;
{$ENDIF}

function  load_acquire(Var addr:Pointer):Pointer; inline;
function  load_acquire(Var addr:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  load_acquire(Var addr:DWORD):DWORD; inline;
{$ENDIF}

function  load_acq_rel(Var addr:Pointer):Pointer; inline;
function  load_acq_rel(Var addr:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  load_acq_rel(Var addr:DWORD):DWORD; inline;
function  load_acq_rel(Var addr:Integer):Integer; inline;
{$ENDIF}

Procedure store_release(Var addr:Pointer;v:Pointer); inline;
Procedure store_release(Var addr:SizeUInt;v:SizeUInt); inline;
{$IF defined(CPUX86_64)}
Procedure store_release(Var addr:DWORD;v:DWORD); inline;
Procedure store_release(Var addr:Integer;v:Integer); inline;
{$ENDIF}

Procedure store_seq_cst(Var addr:Pointer;v:Pointer); inline;
Procedure store_seq_cst(Var addr:SizeUInt;v:SizeUInt); inline;
{$IF defined(CPUX86_64)}
Procedure store_seq_cst(Var addr:DWORD;v:DWORD); inline;
Procedure store_seq_cst(Var addr:Integer;v:Integer); inline;
{$ENDIF}

function  _CAS(Var addr:Pointer;Comp,New:Pointer):Pointer; inline;
function  _CAS(Var addr:SizeUInt;Comp,New:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  _CAS(Var addr:DWORD;Comp,New:DWORD):DWORD; inline;
{$ENDIF}

function  CAS(Var addr:Pointer;Comp,New:Pointer):Boolean; inline;
function  CAS(Var addr:SizeUInt;Comp,New:SizeUInt):Boolean; inline;
{$IF defined(CPUX86_64)}
function  CAS(Var addr:DWORD;Comp,New:DWORD):Boolean; inline;
function  CAS(Var addr:Integer;Comp,New:Integer):Boolean; inline;
{$ENDIF}

function  XCHG(Var addr:Pointer;New:Pointer):Pointer; inline;
function  XCHG(Var addr:SizeUInt;New:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  XCHG(Var addr:DWORD;New:DWORD):DWORD; inline;
function  XCHG(Var addr:Integer;New:Integer):Integer; inline;
{$ENDIF}

function  fetch_add(Var addr:SizeUInt;i:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  fetch_add(Var addr:DWORD;i:DWORD):DWORD; inline;
function  fetch_add(Var addr:Integer;i:Integer):Integer; inline;
{$ENDIF}

function  fetch_sub(Var addr:SizeUInt;i:SizeUInt):SizeUInt; inline;
{$IF defined(CPUX86_64)}
function  fetch_sub(Var addr:DWORD;i:DWORD):DWORD; inline;
function  fetch_sub(Var addr:Integer;i:Integer):Integer; inline;
{$ENDIF}

function  fetch_xor(var Target:SizeUInt;mask:SizeUInt):Boolean;       ms_abi_default;
{$IFDEF CPUX86_64}
function  fetch_xor(var Target:DWORD;mask:DWORD):Boolean;             ms_abi_default;
{$ENDIF}

function  fetch_or(var Target:SizeUInt;mask:SizeUInt):Boolean;        ms_abi_default;
{$IFDEF CPUX86_64}
function  fetch_or(var Target:DWORD;mask:DWORD):Boolean;              ms_abi_default;
{$ENDIF}

function  fetch_and(var Target:SizeUInt;mask:SizeUInt):Boolean;       ms_abi_default;
{$IFDEF CPUX86_64}
function  fetch_and(var Target:DWORD;mask:DWORD):Boolean;             ms_abi_default;
{$ENDIF}

function  test_and_set(var Target:SizeUInt;bit:byte):Boolean;         ms_abi_default;
{$IFDEF CPUX86_64}
function  test_and_set(var Target:DWORD;bit:byte):Boolean;             ms_abi_default;
{$ENDIF}

function  test_and_reset(var Target:qword;bit:byte):Boolean;          ms_abi_default;
{$IFDEF CPUX86_64}
function  test_and_reset(var Target:DWORD;bit:byte):Boolean;          ms_abi_default;
{$ENDIF}

function  marked_ptr(P:Pointer;B:SizeUInt=0):Pointer; inline;
function  ptr1(P:Pointer):Pointer; inline;
function  bits1(P:Pointer):SizeUInt; inline;
function  bits1(P:SizeUInt):SizeUInt; inline;
procedure spin_pause;

implementation

function load_consume(Var addr:Pointer):Pointer; inline;
begin
 ReadDependencyBarrier;
 Result:=addr;
end;

function load_consume(Var addr:SizeUInt):SizeUInt; inline;
begin
 ReadDependencyBarrier;
 Result:=addr;
end;

{$IF defined(CPUX86_64)}
function load_consume(Var addr:DWORD):DWORD; inline;
begin
 ReadDependencyBarrier;
 Result:=addr;
end;
{$ENDIF}

function load_acquire(Var addr:Pointer):Pointer; inline;
begin
 ReadBarrier;
 Result:=addr;
end;

function load_acquire(Var addr:SizeUInt):SizeUInt; inline;
begin
 ReadBarrier;
 Result:=addr;
end;

{$IF defined(CPUX86_64)}
function load_acquire(Var addr:DWORD):DWORD; inline;
begin
 ReadBarrier;
 Result:=addr;
end;
{$ENDIF}

function load_acq_rel(Var addr:Pointer):Pointer; inline;
begin
 Result:=System.InterLockedExchangeAdd(Pointer(addr),nil);
end;

function load_acq_rel(Var addr:SizeUInt):SizeUInt; //inline;
begin
 Result:=SizeUInt(load_acq_rel(Pointer(addr)));
end;

{$IF defined(CPUX86_64)}
function load_acq_rel(Var addr:DWORD):DWORD; inline;
begin
 Result:=System.InterLockedExchangeAdd(addr,0);
end;

function load_acq_rel(Var addr:Integer):Integer; inline;
begin
 Result:=System.InterLockedExchangeAdd(addr,0);
end;
{$ENDIF}

Procedure store_release(Var addr:Pointer;v:Pointer); inline;
begin
 WriteBarrier;
 addr:=v;
end;

Procedure store_release(Var addr:SizeUInt;v:SizeUInt); inline;
begin
 WriteBarrier;
 addr:=v;
end;

{$IF defined(CPUX86_64)}
Procedure store_release(Var addr:DWORD;v:DWORD); inline;
begin
 WriteBarrier;
 addr:=v;
end;

Procedure store_release(Var addr:Integer;v:Integer); inline;
begin
 WriteBarrier;
 addr:=v;
end;
{$ENDIF}

Procedure store_seq_cst(Var addr:Pointer;v:Pointer); inline;
begin
 System.InterLockedExchange(addr,v);
end;

Procedure store_seq_cst(Var addr:SizeUInt;v:SizeUInt); inline;
begin
 store_seq_cst(Pointer(addr),Pointer(v));
end;

{$IF defined(CPUX86_64)}
Procedure store_seq_cst(Var addr:DWORD;v:DWORD); inline;
begin
 System.InterLockedExchange(addr,v);
end;

Procedure store_seq_cst(Var addr:Integer;v:Integer); inline;
begin
 System.InterLockedExchange(addr,v);
end;
{$ENDIF}

function _CAS(Var addr:Pointer;Comp,New:Pointer):Pointer; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp);
end;

function _CAS(Var addr:SizeUInt;Comp,New:SizeUInt):SizeUInt; inline;
begin
 Result:=SizeUInt(system.InterlockedCompareExchange(Pointer(addr),Pointer(New),Pointer(Comp)));
end;

{$IF defined(CPUX86_64)}
function _CAS(Var addr:DWORD;Comp,New:DWORD):DWORD; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp);
end;

function _CAS(Var addr:Integer;Comp,New:Integer):Integer; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp);
end;
{$ENDIF}

function CAS(Var addr:Pointer;Comp,New:Pointer):Boolean; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp)=Comp;
end;

function CAS(Var addr:SizeUInt;Comp,New:SizeUInt):Boolean; inline;
begin
 Result:=system.InterlockedCompareExchange(Pointer(addr),Pointer(New),Pointer(Comp))=Pointer(Comp);
end;

{$IF defined(CPUX86_64)}
function CAS(Var addr:DWORD;Comp,New:DWORD):Boolean; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp)=Comp;
end;

function CAS(Var addr:Integer;Comp,New:Integer):Boolean; inline;
begin
 Result:=system.InterlockedCompareExchange(addr,New,Comp)=Comp;
end;
{$ENDIF}

function XCHG(Var addr:Pointer;New:Pointer):Pointer; inline;
begin
 Result:=System.InterLockedExchange(addr,New);
end;

function XCHG(Var addr:SizeUInt;New:SizeUInt):SizeUInt; inline;
begin
 Result:=SizeUInt(System.InterLockedExchange(Pointer(addr),Pointer(New)));
end;

{$IF defined(CPUX86_64)}
function XCHG(Var addr:DWORD;New:DWORD):DWORD; inline;
begin
 Result:=System.InterLockedExchange(addr,New);
end;

function XCHG(Var addr:Integer;New:Integer):Integer; inline;
begin
 Result:=System.InterLockedExchange(addr,New);
end;
{$ENDIF}

function fetch_add(Var addr:SizeUInt;i:SizeUInt):SizeUInt; inline;
begin
 Result:=SizeUInt(System.InterLockedExchangeAdd(Pointer(addr),Pointer(i)));
end;

{$IF defined(CPUX86_64)}
function fetch_add(Var addr:DWORD;i:DWORD):DWORD; inline;
begin
 Result:=System.InterLockedExchangeAdd(addr,i);
end;

function fetch_add(Var addr:Integer;i:Integer):Integer; inline;
begin
 Result:=System.InterLockedExchangeAdd(addr,i);
end;
{$ENDIF}

function fetch_sub(Var addr:SizeUInt;i:SizeUInt):SizeUInt; inline;
begin
 Result:=fetch_add(addr,SizeUInt(-SizeInt(i)));
end;

{$IF defined(CPUX86_64)}
function fetch_sub(Var addr:DWORD;i:DWORD):DWORD; inline;
begin
 Result:=fetch_add(addr,DWORD(-Integer(i)));
end;

function fetch_sub(Var addr:Integer;i:Integer):Integer; inline;
begin
 Result:=fetch_add(addr,-i);
end;
{$ENDIF}

//xor

{$IFDEF CPU386}
function fetch_xor(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock xor %edx,(%ecx)
 setz %al
end;
{$ELSE}
{$IFDEF CPUX86_64}
function fetch_xor(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock xor %rdx,(%rcx)
 setz %al
end;

function fetch_xor(var Target:DWORD;mask:DWORD):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock xor %edx,(%rcx)
 setz %al
end;
{$ELSE}
function fetch_xor(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default;
Var
 P,N:SizeUInt;
begin
 repeat
  P:=load_consume(Target);
  N:=P xor mask;
 until CAS(Target,P,N);
 Result:=(N=0);
end;
{$ENDIF}
{$ENDIF}

//or

{$IFDEF CPU386}
function fetch_or(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock or %edx,(%ecx)
 setz %al
end;
{$ELSE}
{$IFDEF CPUX86_64}
function fetch_or(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock or %rdx,(%rcx)
 setz %al
end;

function fetch_or(var Target:DWORD;mask:DWORD):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock or %edx,(%rcx)
 setz %al
end;
{$ELSE}
function fetch_or(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default;
Var
 P,N:SizeUInt;
begin
 repeat
  P:=load_consume(Target);
  N:=P or mask;
 until CAS(Target,P,N);
 Result:=(N=0);
end;
{$ENDIF}
{$ENDIF}

//and

{$IFDEF CPU386}
function fetch_and(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock and %edx,(%ecx)
 setz %al
end;
{$ELSE}
{$IFDEF CPUX86_64}
function fetch_and(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock and %rdx,(%rcx)
 setz %al
end;

function fetch_and(var Target:DWORD;mask:DWORD):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock and %edx,(%rcx)
 setz %al
end;
{$ELSE}
function fetch_and(var Target:SizeUInt;mask:SizeUInt):Boolean; ms_abi_default;
Var
 P,N:SizeUInt;
begin
 repeat
  P:=load_consume(Target);
  N:=P and mask;
 until CAS(Target,P,N);
 Result:=(N=0);
end;
{$ENDIF}
{$ENDIF}

//bts

{$IFDEF CPU386}
function test_and_set(var Target:SizeUInt;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock bts %edx,(%ecx)
 setc %al
end;
{$ELSE}
{$IFDEF CPUX86_64}
function test_and_set(var Target:SizeUInt;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock bts %rdx,(%rcx)
 setc %al
end;

function test_and_set(var Target:DWORD;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock bts %edx,(%rcx)
 setc %al
end;
{$ELSE}
function test_and_set(var Target:SizeUInt;bit:byte):Boolean; ms_abi_default;
Var
 P,N,M:SizeUInt;
begin
 M:=1 shl bit;
 repeat
  P:=load_consume(Target);
  N:=P or M;
 until CAS(Target,P,N);
 Result:=(P and M)<>0;
end;
{$ENDIF}
{$ENDIF}

//btr

{$IFDEF CPU386}
function test_and_reset(var Target:qword;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock btr %edx,(%ecx)
 setc %al
end;
{$ELSE}
{$IFDEF CPUX86_64}
function test_and_reset(var Target:qword;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock btr %rdx,(%rcx)
 setc %al
end;

function test_and_reset(var Target:DWORD;bit:byte):Boolean; ms_abi_default; assembler; nostackframe;
asm
 lock btr %edx,(%rcx)
 setc %al
end;
{$ELSE}
function test_and_reset(var Target:SizeUInt;bit:byte):Boolean; ms_abi_default;
Var
 P,N,M:SizeUInt;
begin
 M:=not (1 shl bit);
 repeat
  P:=load_consume(Target);
  N:=P and M;
 until CAS(Target,P,N);
 Result:=(P and M)<>0;
end;
{$ENDIF}
{$ENDIF}

function marked_ptr(P:Pointer;B:SizeUInt=0):Pointer; inline;
begin
 Result:=Pointer(SizeUInt(P) or B);
end;

function ptr1(P:Pointer):Pointer; inline;
begin
 Result:=Pointer(SizeUInt(P) and (not SizeUInt(1)));
end;

function bits1(P:Pointer):SizeUInt; inline;
begin
 Result:=SizeUInt(P) and SizeUInt(1);
end;

function bits1(P:SizeUInt):SizeUInt; inline;
begin
 Result:=SizeUInt(P) and SizeUInt(1);
end;

{$if defined(CPU386) or defined(CPUX86_64)}
procedure spin_pause; assembler; nostackframe;
asm
 pause
end;
{$ELSE}
procedure spin_pause; inline;
begin
end;
{$ENDIF}

end.

