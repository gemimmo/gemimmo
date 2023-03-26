unit vm;

{$mode ObjFPC}{$H+}
{$CALLING SysV_ABI_CDecl}

interface

type
 cap_rights_t=QWORD;

 p_vm_offset_t=^vm_offset_t;
 vm_offset_t =QWORD;

 p_vm_ooffset_t=^vm_ooffset_t;
 vm_ooffset_t=Int64;

 vm_size_t   =QWORD;

 segsz_t     =QWORD;
 caddr_t     =Pointer;

 vm_inherit_t=type Byte;

 p_vm_prot_t=^vm_prot_t;
 vm_prot_t  =type Byte;

 p_vm_pindex_t=^vm_pindex_t;
 vm_pindex_t =DWORD;

 p_vm_paddr_t=^vm_paddr_t;
 vm_paddr_t=DWORD;

const
 VM_INHERIT_SHARE  =vm_inherit_t(0);
 VM_INHERIT_COPY   =vm_inherit_t(1);
 VM_INHERIT_NONE   =vm_inherit_t(2);
 VM_INHERIT_DEFAULT=VM_INHERIT_COPY;

 VM_PROT_NONE      =vm_prot_t($00);
 VM_PROT_READ      =vm_prot_t($01);
 VM_PROT_WRITE     =vm_prot_t($02);
 VM_PROT_EXECUTE   =vm_prot_t($04);
 VM_PROT_COPY      =vm_prot_t($08);
 VM_PROT_GPU_READ  =vm_prot_t($10);
 VM_PROT_GPU_WRITE =vm_prot_t($20);
 VM_PROT_GPU_ALL   =vm_prot_t($30);

 VM_PROT_ALL    =(VM_PROT_READ or VM_PROT_WRITE or VM_PROT_EXECUTE or VM_PROT_GPU_ALL);
 VM_PROT_RW     =(VM_PROT_READ or VM_PROT_WRITE);
 VM_PROT_DEFAULT=VM_PROT_ALL;

const
 //Return values from the VM routines.
 KERN_SUCCESS           =0;
 KERN_INVALID_ADDRESS   =1;
 KERN_PROTECTION_FAILURE=2;
 KERN_NO_SPACE          =3;
 KERN_INVALID_ARGUMENT  =4;
 KERN_FAILURE           =5;
 KERN_RESOURCE_SHORTAGE =6;
 KERN_NOT_RECEIVER      =7;
 KERN_NO_ACCESS         =8;

 // General file I/O.
 CAP_READ     =$0000000000000001; // read/recv
 CAP_WRITE    =$0000000000000002; // write/send
 CAP_MMAP     =$0000000000000004; // mmap
 CAP_MAPEXEC  =$0000000000000008; // mmap(2) as exec
 CAP_FEXECVE  =$0000000000000010;
 CAP_FSYNC    =$0000000000000020;
 CAP_FTRUNCATE=$0000000000000040;
 CAP_SEEK     =$0000000000000080;

 // VFS methods.
 CAP_FCHFLAGS =$0000000000000100;
 CAP_FCHDIR   =$0000000000000200;
 CAP_FCHMOD   =$0000000000000400;
 CAP_FCHOWN   =$0000000000000800;
 CAP_FCNTL    =$0000000000001000;
 CAP_FPATHCONF=$0000000000002000;
 CAP_FLOCK    =$0000000000004000;
 CAP_FSCK     =$0000000000008000;
 CAP_FSTAT    =$0000000000010000;
 CAP_FSTATFS  =$0000000000020000;
 CAP_FUTIMES  =$0000000000040000;
 CAP_CREATE   =$0000000000080000;
 CAP_DELETE   =$0000000000100000;
 CAP_MKDIR    =$0000000000200000;
 CAP_RMDIR    =$0000000000400000;
 CAP_MKFIFO   =$0000000000800000;

const
 MAP_SHARED      =$0001; // share changes
 MAP_PRIVATE     =$0002; // changes are private
 MAP_FIXED       =$0010; // map addr must be exactly as requested
 MAP_NO_OVERWRITE=$0080; // don't overwrite memory with MAP_FIXED
 MAP_VOID        =$0100; // reserve addr

 MAP_STACK       =$0400; // region grows down, like a stack
 MAP_NOSYNC      =$0800; // page to but do not sync underlying file

 MAP_FILE        =$0000;    // map from file (default)
 MAP_ANON        =$1000;    // allocated from memory, swap space
 MAP_ANONYMOUS   =MAP_ANON; // For compatibility.
 MAP_SYSTEM      =$2000;
 MAP_ALLAVAILABLE=$4000;

 MAP_SELF        =$80000; // map decryped SELF file

 MAP_ALIGNMENT_BIT  =24;
 MAP_ALIGNMENT_SHIFT=$1f000000;
 MAP_ALIGNMENT_MASK =$ff shl MAP_ALIGNMENT_BIT;
 MAP_ALIGNED_SUPER  =$01 shl MAP_ALIGNMENT_BIT;
 //MAP_ALIGNED(n) ((n) << MAP_ALIGNMENT_SHIFT)

 MCL_CURRENT=$0001; // Lock only current memory
 MCL_FUTURE =$0002; // Lock all future memory as well

 MS_SYNC      =$0000; // msync synchronously
 MS_ASYNC     =$0001; // return immediately
 MS_INVALIDATE=$0002; // invalidate all cached data

 MAP_NOCORE       =$20000; // dont include these pages in a coredump
 MAP_PREFAULT_READ=$40000; // prefault mapping for reading

 //Advice to madvise
 _MADV_NORMAL    =0; // no further special treatment
 _MADV_RANDOM    =1; // expect random page references
 _MADV_SEQUENTIAL=2; // expect sequential page references
 _MADV_WILLNEED  =3; // will need these pages
 _MADV_DONTNEED  =4; // dont need these pages

 MADV_NORMAL    =_MADV_NORMAL;
 MADV_RANDOM    =_MADV_RANDOM;
 MADV_SEQUENTIAL=_MADV_SEQUENTIAL;
 MADV_WILLNEED  =_MADV_WILLNEED;
 MADV_DONTNEED  =_MADV_DONTNEED;
 MADV_FREE      = 5; // dont need these pages, and junk contents
 MADV_NOSYNC    = 6; // try to avoid flushes to physical media
 MADV_AUTOSYNC  = 7; // revert to default flushing strategy
 MADV_NOCORE    = 8; // do not include these pages in a core file
 MADV_CORE      = 9; // revert to including pages in a core file
 MADV_PROTECT   =10; // protect process from pageout kill

function is_gpu(prot:vm_prot_t):Boolean; inline;
function round_page(x:QWORD):QWORD; inline;
function trunc_page(x:QWORD):QWORD; inline;
function roundup(addr:QWORD;alignment:QWORD):QWORD; inline;

implementation

uses
 vmparam;

function is_gpu(prot:vm_prot_t):Boolean; inline;
begin
 Result:=(prot and VM_PROT_GPU_ALL)<>0;
end;

function round_page(x:QWORD):QWORD; inline;
begin
 Result:=(x+PAGE_MASK) and (not PAGE_MASK);
end;

function trunc_page(x:QWORD):QWORD; inline;
begin
 Result:=x and (not PAGE_MASK);
end;

function roundup(addr:QWORD;alignment:QWORD):QWORD; inline;
var
 tmp:QWORD;
begin
 if (alignment=0) then Exit(addr);
 tmp:=addr+QWORD(alignment-1);
 Result:=tmp-(tmp mod alignment)
end;




end.

