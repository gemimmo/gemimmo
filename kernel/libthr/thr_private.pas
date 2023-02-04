unit thr_private;

{$mode ObjFPC}{$H+}

interface

uses
 _umtx;

const
 THR_MUTEX_INITIALIZER         =nil;
 THR_ADAPTIVE_MUTEX_INITIALIZER=Pointer(1);
 THR_MUTEX_DESTROYED           =Pointer(2);
 THR_COND_INITIALIZER          =nil;
 THR_COND_DESTROYED            =Pointer(1);
 THR_RWLOCK_INITIALIZER        =nil;
 THR_RWLOCK_DESTROYED          =Pointer(1);

 PMUTEX_FLAG_TYPE_MASK=$0ff;
 PMUTEX_FLAG_PRIVATE  =$100;
 PMUTEX_FLAG_DEFERED  =$200;

 MAX_DEFER_WAITERS    =50;

type
 pthread_mutex_t=^pthread_mutex;
 pthread_mutex=packed record
  //Lock for accesses to this structure.
  m_lock      :umutex;
  m_flags     :Integer;
  magic2      :DWORD;
  m_owner     :Pointer; //pthread
  m_count     :Integer;
  m_spinloops :Integer;
  m_yieldloops:Integer;
  magic1      :DWORD;
  //Link for all mutexes a thread currently owns.
  pNext,pPrev :pthread_mutex_t;
  //
 end;

 pthread_mutex_attr=packed record
  m_type    :Integer;
  m_protocol:Integer;
  m_ceiling :Integer;
 end;

 pthread_cond=packed record
  __has_user_waiters:DWORD;
  __has_kern_waiters:DWORD;
  __flags           :DWORD;
  __clock_id        :DWORD;
  u1,u2,u3          :DWORD;
 end;

 pthread_cond_attr=packed record
  c_pshared:Integer;
  c_clockid:Integer;
 end;

 pthread_barrier=packed record
  b_lock   :umutex;
  b_cv     :ucond;
  b_cycle  :int64;
  b_count  :Integer;
  b_waiters:Integer;
 end;

 pthread_barrierattr=packed record
  pshared:Integer;
 end;

 pthread_spinlock=packed record
  s_lock:umutex;
 end;

const
 //Flags for condition variables.
 COND_FLAGS_PRIVATE=$01;
 COND_FLAGS_INITED =$02;
 COND_FLAGS_BUSY   =$04;

type
 t_routine_proc=procedure(data:Pointer); SysV_ABI_CDecl;

 p_pthread_cleanup=^pthread_cleanup;
 pthread_cleanup=packed record
  prev:p_pthread_cleanup;
  routine:t_routine_proc;
  routine_arg:Pointer;
  onheap:Integer;
 end;

 p_pthread_atfork=^pthread_atfork;
 pthread_atfork=packed record
  qe_prev:p_pthread_atfork;
  qe_next:p_pthread_atfork;
  prepare:TProcedure;
  parent :TProcedure;
  child  :TProcedure;
 end;

 pthread_attr=packed record
  sched_policy  :Integer;
  sched_inherit :Integer;
  prio          :Integer;
  suspend       :Integer;
  flags         :Integer;
  _align        :Integer;
  stackaddr_attr:Pointer;
  stacksize_attr:ptruint;
  guardsize_attr:ptruint;
  cpuset        :ptruint;
  cpusetsize    :ptruint;
 end;

 p_wake_addr=^wake_addr;
 wake_addr=packed record
  link :p_wake_addr;
  value:DWORD;
  pad  :array[0..11] of Byte;
 end;

 //sleepqueue

const
 THR_STACK_USER=$100; // 0xFF reserved for <pthread.h>

 //Thread creation state attributes.
 THR_CREATE_RUNNING  =0;
 THR_CREATE_SUSPENDED=1;

 //Miscellaneous definitions.
 THR_STACK_DEFAULT=(2 * 1024 * 1024);
 THR_STACK_INITIAL=(THR_STACK_DEFAULT * 2);

type
 pthread_prio=packed record
  pri_min    :Integer;
  pri_max    :Integer;
  pri_default:Integer;
 end;

 pthread_rwlockattr=packed record
  pshared:Integer;
 end;

 pthread_rwlock=packed record
  lock:urwlock;
  owner:Pointer; //pthread*
 end;

 sigset_t=array[0..3] of DWORD;

 siginfo_t=packed record
  si_signo :Integer;
  si_errno :Integer;
  si_code  :Integer;
  si_pid   :Integer;
  si_uid   :Integer;
  si_status:Integer;
  si_addr  :Pointer;
  __spare1 :qword;
  __spare2 :array[0..6] of Integer;
 end;

 sigaction_t=packed record
  __sigaction_u:Pointer;
  sa_flags     :Integer;
  sa_mask      :sigset_t;
  _align       :Integer;
 end;

 _Unwind_Exception=packed record
  exception_class  :Int64;
  exception_cleanup:Pointer;
  private_1        :QWORD;
  private_2        :QWORD;
 end;

 td_event_msg_t=array[0..5] of DWORD;

 pthread=packed record
  tid                :Integer;
  _align1            :Integer;
  lock               :umutex;                //Lock for accesses to this thread structure.
  cycle              :Integer;               //Internal condition variable cycle number.
  locklevel          :Integer;               //How many low level locks the thread held.
  critical_count     :Integer;               //Set to non-zero when this thread has entered a critical region.
  sigblock           :Integer;               //Signal blocked counter.
  tle_next           :Pointer;               //link for all threads in process
  tle_prev           :Pointer;               //link for all threads in process
  gcle_next          :Pointer;               //Queue entry for GC lists.
  gcle_prev          :Pointer;               //Queue entry for GC lists.
  hle_next           :Pointer;               //Hash queue entry.
  hle_prev           :Pointer;               //Hash queue entry.
  wle_next           :Pointer;               //Sleep queue entry
  wle_prev           :Pointer;               //Sleep queue entry
  refcount           :Integer;               //Threads reference count.
  _align2            :Integer;
  start_routine      :Pointer;
  arg                :Pointer;
  attr               :pthread_attr;
  cancel_enable      :Integer;               //Cancellation is enabled
  cancel_pending     :Integer;               //Cancellation request is pending
  cancel_point       :Integer;               //Thread is at cancellation point
  no_cancel          :Integer;               //Cancellation is temporarily disabled
  cancel_async       :Integer;               //Asynchronouse cancellation is enabled
  cancelling         :Integer;               //Cancellation is in progress
  sigmask            :sigset_t;              //Thread temporary signal mask.
  unblock_sigcancel  :Integer;               //Thread should unblock SIGCANCEL.
  in_sigsuspend      :Integer;               //In sigsuspend state
  deferred_siginfo   :siginfo_t;             //deferred signal info
  deferred_sigmask   :sigset_t;              //signal mask to restore.
  deferred_sigact    :sigaction_t;           //the sigaction should be used for deferred signal.
  _align3            :Integer;
  deferred_run       :Integer;               //deferred signal delivery is performed, do not reenter.
  force_exit         :Integer;               //Force new thread to exit.
  state              :Integer;               //Thread state
  error              :Integer;               //Error variable used instead of errno.
  _align4            :Integer;
  joiner             :Pointer;               //The joiner is the thread that is joining to this thread.
  flags              :Integer;               //Miscellaneous flags; only set with scheduling lock held.
  tlflags            :Integer;               //Thread list flags; only set with thread list lock held.
  mutexq_next        :Pointer;               //Queue of currently owned NORMAL or PRIO_INHERIT type mutexes.
  mutexq_prev        :Pointer;               //Queue of currently owned NORMAL or PRIO_INHERIT type mutexes.
  pp_mutexq_next     :Pointer;               //Queue of all owned PRIO_PROTECT mutexes.
  pp_mutexq_prev     :Pointer;               //Queue of all owned PRIO_PROTECT mutexes.
  ret                :Pointer;
  specific           :Pointer;
  specific_data_count:Integer;
  rdlock_count       :Integer;               //Number rwlocks rdlocks held.
  rtld_bits          :Integer;               //Current locks bitmap for rtld.
  _align5            :Integer;
  tcb                :Pointer;               //Thread control block
  cleanup            :Pointer;               //Cleanup handlers Link List
  ex                 :_Unwind_Exception;
  unwind_stackend    :Pointer;
  unwind_disabled    :Integer;
  magic              :DWORD;                 //Magic value to help recognize a valid thread structure from an invalid one
  report_events      :Integer;               //Enable event reporting
  event_mask         :Integer;
  event_buf          :td_event_msg_t;        //Event
  wchan              :Pointer;               //Wait channe
  mutex_obj          :Pointer;               //Referenced mutex
  will_sleep         :Integer;               //Thread will sleep
  nwaiter_defer      :Integer;               //Number of threads deferred
  defer_waiters      :array[0..49] of QWORD; //Deferred threads from pthread_cond_signal
  _align6            :Integer;
  wake_addr          :p_wake_addr;
  sleepqueue         :Pointer;               //Sleep queue
 end;

const
 //pthread_state
 PS_RUNNING=0;
 PS_DEAD   =1;

 // Miscellaneous flags; only set with scheduling lock held.
 THR_FLAGS_PRIVATE     =$0001;
 THR_FLAGS_NEED_SUSPEND=$0002; // thread should be suspended
 THR_FLAGS_SUSPENDED   =$0004; // thread is suspended
 THR_FLAGS_DETACHED    =$0008; // thread is detached

 // Thread list flags; only set with thread list lock held.
 TLFLAGS_GC_SAFE  =$0001; // thread safe for cleaning
 TLFLAGS_IN_TDLIST=$0002; // thread in all thread list
 TLFLAGS_IN_GCLIST=$0004; // thread in gc list

 THR_MAGIC=$d09ba115;

implementation

end.

