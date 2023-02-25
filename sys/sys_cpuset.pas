unit sys_cpuset;

{$mode ObjFPC}{$H+}

interface

uses
 trap,
 kern_cpuset;

type
 p_cpuset_t=kern_cpuset.p_cpuset_t;
 cpuset_t  =kern_cpuset.cpuset_t;

const
 CPU_LEVEL_WHICH =3; // Actual mask/id for which.

 CPU_WHICH_TID   =1; // Specifies a thread id.
 CPU_WHICH_PID   =2; // Specifies a process id.

function cpuset_getaffinity(level,which:Integer;id,cpusetsize:QWORD;mask:p_cpuset_t):Integer;
function cpuset_setaffinity(level,which:Integer;id,cpusetsize:QWORD;mask:p_cpuset_t):Integer;

implementation

function cpuset_getaffinity(level,which:Integer;id,cpusetsize:QWORD;mask:p_cpuset_t):Integer; assembler; nostackframe;
asm
 movq  sys_cpuset_getaffinity,%rax
 call  fast_syscall
end;

function cpuset_setaffinity(level,which:Integer;id,cpusetsize:QWORD;mask:p_cpuset_t):Integer; assembler; nostackframe;
asm
 movq  sys_cpuset_setaffinity,%rax
 call  fast_syscall
end;


end.

