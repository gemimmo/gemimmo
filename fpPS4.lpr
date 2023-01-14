
uses
 {$IFDEF Linux}
 cmem,
 cthreads,
 {$ENDIF}
 cpu,
 windows,
 seh64,
 Classes,
 sysutils,
 stub_manager,
 sys_crt,
 sys_types,
 sys_pthread,
 sys_path,
 ps4libdoc,
 ps4_libkernel,
 ps4_libSceLibcInternal,
 ps4_libSceScreenShot,
 ps4_libSceRtc,
 ps4_libSceNpSignaling,
 ps4_libSceNpMatching2,
 ps4_libSceRemoteplay,
 ps4_libSceAjm,
 ps4_libSceMouse,
 ps4_libSceIme,
 ps4_libSceMove,
 ps4_libScePlayGo,
 ps4_libSceDiscMap,
 ps4_libSceAppContent,
 ps4_libSceNet,
 ps4_libSceHttp,
 ps4_libSceGnmDriver,
 ps4_libSceNpScore,
 ps4_libSceNpTrophy,
 ps4_libSceSystemService,
 ps4_libSceNpManager,
 ps4_libSceNpGameIntent,
 ps4_libSceSaveData,
 ps4_libSceDialogs,
 ps4_libSceUserService,
 ps4_libSceAudioOut,
 ps4_libSceVoice,
 ps4_libSceVideoOut,
 ps4_libScePad,
 ps4_libSceNpWebApi,
 ps4_libSceRudp,
 ps4_libSceRandom,
 ps4_elf,
 ps4_pthread,
 ps4_program,
 ps4_elf_tls,

 ps4_videodrv,
 vMemory,
 vImageManager,
 vFlip,

 trace_manager;

function ParseCmd:Boolean;
var
 i,n:Integer;
label
 promo;
begin
 if (ParamCount=0) then
 begin
  promo:
  Writeln('fpPS4 (',{$I tag.inc},')');
  Writeln('Copyright (c) 2021-2022 by Red_prig');
  Writeln('PS4 compatibility layer (emulator) on Free Pascal '+{$I %FPCVERSION%});
  Writeln(' Parameters:');
  Writeln('  -e <name>  //decrypted elf or self file name');
  Writeln('  -f <name>  //folder of app   (/app0)');
  Writeln('  -p <name>  //folder of patch (/app1)');
  Writeln('  -s <name>  //savedata path');

  Writeln('  -h <name>  //enable hack');
  Writeln('     DEPTH_DISABLE_HACK   //disable depth buffer');
  Writeln('     COMPUTE_DISABLE_HACK //disable compute shaders');
  Writeln('     MEMORY_BOUND_HACK    //limit the amount of GPU allocated memory (iGPU)');
  Writeln('     IMAGE_TEST_HACK      //always mark that the texture has changed');
  Writeln('     IMAGE_LOAD_HACK      //never reload texture');
  Writeln('     DISABLE_SRGB_HACK    //disables hacked display of SRGB');

  Exit(False);
 end;

 n:=-1;
 For i:=1 to ParamCount do
 begin
  case LowerCase(ParamStr(i)) of
    '-e':n:=0;
    '-f':n:=1;
    '-p':n:=2;
    '-s':n:=3;
    '-h':n:=4;
   else
     if (n<>-1) then
     begin
      Case n of
       0:begin
          if (ps4_app.app0_file<>'') then Goto promo;
          ps4_app.app0_file:=Trim(ParamStr(i));
          if (ps4_app.app0_path='') then
          begin
           ps4_app.app0_path:=ExtractFileDir(ps4_app.app0_file);
           if (ExcludeLeadingPathDelimiter(ps4_app.app0_path)='') then ps4_app.app0_path:=GetCurrentDir;
          end;
         end;
       1:begin
          ps4_app.app0_path:=Trim(ParamStr(i));
          if (ExcludeLeadingPathDelimiter(ps4_app.app0_path)='') then ps4_app.app0_path:=GetCurrentDir;
         end;
       2:begin
          ps4_app.app1_path:=Trim(ParamStr(i));
          if (ExcludeLeadingPathDelimiter(ps4_app.app1_path)='') then ps4_app.app1_path:=GetCurrentDir;
         end;
       3:begin
          ps4_app.save_path:=Trim(ParamStr(i));
         end;
       4:begin
          case UpperCase(ParamStr(i)) of
           'DEPTH_DISABLE_HACK'  :ps4_videodrv.DEPTH_DISABLE_HACK:=True;
           'COMPUTE_DISABLE_HACK':ps4_videodrv.COMPUTE_DISABLE_HACK:=True;
           'MEMORY_BOUND_HACK'   :vMemory.MEMORY_BOUND_HACK:=True;
           'IMAGE_TEST_HACK'     :vImageManager.IMAGE_TEST_HACK:=True;
           'IMAGE_LOAD_HACK'     :vImageManager.IMAGE_LOAD_HACK:=True;
           'DISABLE_SRGB_HACK'   :vFlip.SRGB_HACK:=False;
           else;
          end;
         end;
      end;
      n:=-1;
     end;
  end;
 end;

 if (ps4_app.app0_file='') or (ps4_app.app0_path='') or (ps4_app.save_path='') then Goto promo;

 if (ps4_app.app1_path=ps4_app.app0_path) then
 begin
  ps4_app.app1_path:='';
 end;

 if not FileExists(ps4_app.app0_file) then
 begin
  Writeln(StdErr,'File not found:',ps4_app.app0_file);
  Writeln;
  Goto promo;
 end;

 if not DirectoryExists(ps4_app.app0_path) then
 begin
  Writeln(StdErr,'Path not found:',ps4_app.app0_path);
  Writeln;
  Goto promo;
 end;

 if (ps4_app.app1_path<>'') then
 if not DirectoryExists(ps4_app.app1_path) then
 begin
  Writeln(StdErr,'Path not found:',ps4_app.app1_path);
  Writeln;
  Goto promo;
 end;

 Result:=True;
end;

{
type
 _TElf_node=class(TElf_node)
 end;

procedure Print_libs(node:TElf_node);
var
 i,l:SizeInt;
 lib:PLIBRARY;
begin
 l:=Length(_TElf_node(node).aLibs);
 if (l<>0) then
 begin
  For i:=0 to l-1 do
  begin
   lib:=_TElf_node(node).aLibs[i];
   Writeln(hexStr(lib));
   if lib<>nil then
    Writeln(lib^.Import,' ',lib^.strName);
  end;
 end;
end;
}

var
 Stub:TStubMemoryProc;

procedure _nop_stub; assembler; nostackframe;
asm
 xor %rax,%rax
end;

procedure print_stub(nid:QWORD;lib:PLIBRARY); MS_ABI_Default;
begin
 Writeln(StdErr,'nop nid:',lib^.strName,':',HexStr(nid,16),':',ps4libdoc.GetFunctName(nid));
 //DebugBreak;
 Sleep(INFINITE);
 //readln;
 //Print_libs(ps4_app.GetFile('libc.prx'));
end;

function ps4_sceSslInit(poolSize:size_t):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceSslInit:',poolSize);
 Result:=3;
end;

function ps4_sceUltInitialize():Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceGameLiveStreamingInitialize(heapSize:qword):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceGameLiveStreamingInitialize:',heapSize);
 Result:=0;
end;

function ps4_sceSharePlayInitialize(pHeap:Pointer;heapSize:qword):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceSharePlayInitialize:',HexStr(pHeap),':',heapSize);
 Result:=0;
end;

function ResolveImport(elf:Telf_file;Info:PResolveImportInfo;data:Pointer):Pointer;
var
 lib:PLIBRARY;
begin
 Result:=nil;

 //cache
 Result:=Info^.lib^.get_proc(Info^.nid);
 if (Result<>nil) then
 begin
  //Writeln('Cache^:',Info^.lib^.strName,':',ps4libdoc.GetFunctName(Info^.Nid));
  Exit;
 end;

 lib:=ps4_app.GetLib(Info^.lib^.strName);
 if (lib<>nil) then
 begin
  Result:=lib^.get_proc(Info^.Nid);
 end;

 //Writeln('Resolve:',Info^.lib^.strName,':',ps4libdoc.GetFunctName(Info^.Nid));

 if (Result=nil) then
 begin
  Case Info^.lib^.strName of

   'libSceSsl':
    Case Info^.nid of
     QWORD($85DA551140C55B7B):Result:=@ps4_sceSslInit;
    end;

    'libSceUlt':
    Case Info^.nid of
     QWORD($859220D44586B073):Result:=@ps4_sceUltInitialize;
    end;

    'libSceGameLiveStreaming':
    Case Info^.nid of
     QWORD($92F604C369419DD9):Result:=@ps4_sceGameLiveStreamingInitialize;
    end;

    'libSceSharePlay':
    Case Info^.nid of
     QWORD($8ACAEEAAD86961CC):Result:=@ps4_sceSharePlayInitialize;
    end;

  end;
 end;

 {
 if (Result<>nil) and ((Info^.sType=STT_FUN) or (Info^.sType=STT_SCE)) then //trace
 begin

 Case Info^.lib^.strName of
  'libSceNpToolkit':;
  'libSceSaveDataDialog':;
  'libSceVideoOut':;
  'libSceSystemService':;
  'libSceUserService':;
  'libSceNetCtl':;
  'libSceNpManager':;
  'libSceNpManagerForToolkit':;
  'libScePad':;
  'libSceFios2':;
  'libSceGnmDriver':;
  'libSceAjm':;
  'libSceAudioOut':;
  'libc':;
  'libSceLibcInternal':;
  'libScePosix':;
  'libSceDiscMap':;
  else
   Case RawByteString(ps4libdoc.GetFunctName(Info^.Nid)) of

    'scePadGetControllerInformation':;
    'scePadRead':;
    'scePadSetVibration':;

    'sceUserServiceGetLoginUserIdList':;
    'sceSystemServiceGetStatus':;

    'sceKernelDebugRaiseException':;
    'sceKernelDebugRaiseExceptionOnReleaseMode':;
    '_sigprocmask':;
    '__error':;
    'sceKernelClearEventFlag':;
    'sceKernelWaitEventFlag':;
    'sceKernelSetEventFlag':;
    'sceNetCtlCheckCallbackForNpToolkit':;
    'sceKernelReadTsc':;
    'scePthreadCondSignal':;
    'scePthreadCondTimedwait':;
    'scePthreadYield':;
    'nanosleep':;
    'sceKernelGetProcessTime':;
    'sceKernelGetProcessTimeCounter':;
    'clock_gettime':;
    'pthread_mutex_init':;
    'sceKernelLseek':;
    'scePthreadMutexDestroy':;
    'sceKernelRead':;
    'sceKernelSignalSema':;
    'sceKernelWaitSema':;
    'scePthreadMutexInit':;
    'scePthreadMutexattrInit':;
    'scePthreadMutexattrDestroy':;
    'scePthreadMutexattrSettype':;
    'scePthreadMutexTrylock':;
    'scePthreadMutexLock':;
    'scePthreadMutexUnlock':;
    'pthread_self':;
    'scePthreadSelf':;
    'scePthreadEqual':;
    'sceKernelGettimeofday':;
    'sceKernelClockGettime':;
    'pthread_mutex_lock':;
    'pthread_mutex_unlock':;
    'sceKernelPread':;
    'sceKernelClose':;
    'sceDiscMapIsRequestOnHDD':;
    //'Unknow':;
    'sceFiosIOFilterPsarcDearchiver':;
    'sceFiosFHReadSync':;
    'sceFiosFHTell':;
    'sceNgs2VoiceGetState':;
    'sceNgs2SystemRender':;
    'sceAudioOutOutputs':;
    '__tls_get_addr':;
    'scePthreadRwlockRdlock':;
    'scePthreadRwlockUnlock':;
    'scePthreadCondBroadcast':;
    'sceFiosFHCloseSync':;
    'sceKernelStat':;
    'sceKernelOpen':;
    'sceKernelUsleep':;
    '_write':;
    else
     begin
      Result:=TStubMemoryTrace(Stub).NewTraceStub(Info^.Nid,Info^.lib,Result,@_trace_enter,@_trace_exit);
     end;
   end;
 end;

 end;
 }

 if (Result=nil) then
 begin
  if (Info^.sType=STT_FUN) or (Info^.sType=STT_SCE) then
  begin
   Result:=Stub.NewNopStub(Info^.Nid,Info^.lib,@print_stub);
  end else
  if (Info^.sBind<>STB_WEAK) then
  begin
   Writeln(StdErr,'Warn^:',Info^.lib^.strName,':',ps4libdoc.GetFunctName(Info^.Nid),':',HexStr(Info^.Nid,16));
  end;

 end;

 if (Result<>nil) then //cache
 begin
  Info^.lib^.set_proc(Info^.nid,Result);
 end;
end;

function ReloadImport(elf:Telf_file;Info:PResolveImportInfo;data:Pointer):Pointer;
var
 node:Telf_file;
 lib:PLIBRARY;
begin
 //prev
 Result:=Info^.lib^.get_proc(Info^.nid);

 node:=Telf_file(data);

 lib:=ps4_app.GetLib(Info^.lib^.strName);
 if (lib=nil) then Exit(nil); //Don't reload!

 if (lib^.parent<>node) then Exit(nil); //Don't reload!

 Result:=lib^.get_proc(Info^.Nid);

 if (Result=nil) then
 begin
  Writeln(StdErr,'Warn^:',Info^.lib^.strName,':',ps4libdoc.GetFunctName(Info^.Nid),':',HexStr(Info^.Nid,16));
  Exit(nil); //Don't reload!
 end;

 if (Result<>nil) then //cache
 begin
  Info^.lib^.set_proc(Info^.nid,Result);
 end;
end;

var
 main:pthread;

{$R *.res}

procedure LoadProgram;
var
 elf:Telf_file;
 f:RawByteString;
begin
 elf:=nil;

 if (ps4_app.app1_path<>'') then
 begin
  //first try patch
  f:='';
  if (parse_filename('/app1/eboot.bin',f)=PT_FILE) then
  begin
   elf:=Telf_file(LoadPs4ElfFromFile(f));
  end;
 end;

 if (elf=nil) then
 begin
  //second try app0_file
  elf:=Telf_file(LoadPs4ElfFromFile(ps4_app.app0_file));
 end;

 Assert(elf<>nil,'program not loaded!');

 ps4_app.prog:=elf;
end;

begin
 DefaultSystemCodePage:=CP_UTF8;
 DefaultUnicodeCodePage:=CP_UTF8;
 DefaultFileSystemCodePage:=CP_UTF8;
 DefaultRTLFileSystemCodePage:=CP_UTF8;
 UTF8CompareLocale:=CP_UTF8;

 sys_crt_init;

 if not cpu.AVX2Support then
 begin
  Writeln('AVX2 not support!');
  Assert(false,'AVX2 not support!');
 end;

 ps4_app.save_path:=IncludeTrailingPathDelimiter(GetCurrentDir)+'savedata';
 if not ParseCmd then Exit;

 ps4_app.resolve_cb:=@ResolveImport;
 ps4_app.reload_cb :=@ReloadImport;

 LoadProgram;
 ps4_app.prog.Prepare;

 ps4_app.RegistredElf    (ps4_app.prog);
 ps4_app.ResolveDepended (ps4_app.prog);
 ps4_app.LoadSymbolImport(nil);


 Stub.FinStub;
 ps4_app.InitProt;

 _pthread_run_entry(@main,GetSceUserMainThreadName,GetSceUserMainThreadStackSize);

 ps4_libSceVideoOut.App_Run;

 //KillALLThreads TODO
 //readln;
end.



