unit ps4_libSceSaveData;

{$mode objfpc}{$H+}

interface

uses
  ps4_program,
  Classes,
  SysUtils;

Const
 SCE_SAVE_DATA_TITLE_ID_DATA_SIZE=10;
 SCE_SAVE_DATA_FINGERPRINT_DATA_SIZE=65;

 SCE_SAVE_DATA_TITLE_MAXSIZE   =128;
 SCE_SAVE_DATA_SUBTITLE_MAXSIZE=128;
 SCE_SAVE_DATA_DETAIL_MAXSIZE  =1024;

 SCE_SAVE_DATA_DIRNAME_DATA_MAXSIZE=32;
 SCE_SAVE_DATA_MOUNT_POINT_DATA_MAXSIZE=16;
 SCE_SAVE_DATA_MOUNT_STATUS_CREATED=$00000001;

type
 PSceSaveDataParam=^SceSaveDataParam;
 SceSaveDataParam=packed record
  title:array[0..SCE_SAVE_DATA_TITLE_MAXSIZE-1] of AnsiChar;
  subTitle:array[0..SCE_SAVE_DATA_SUBTITLE_MAXSIZE-1] of AnsiChar;
  detail:array[0..SCE_SAVE_DATA_DETAIL_MAXSIZE-1] of AnsiChar;
  userParam:DWORD;
  align:DWORD;
  mtime:QWORD;
  reserved:array[0..31] of Byte;
 end;

 PSceSaveDataIcon=^SceSaveDataIcon;
 SceSaveDataIcon=packed record
  buf:Pointer;
  bufSize:size_t;
  dataSize:size_t;
  reserved:array[0..31] of Byte;
 end;

 PSceSaveDataMemorySetup2=^SceSaveDataMemorySetup2;
 SceSaveDataMemorySetup2=packed record
  option:DWORD;
  userId:Integer;
  memorySize:size_t;
  iconMemorySize:size_t;
  initParam:PSceSaveDataParam;
  initIcon:PSceSaveDataIcon;
  reserved:array[0..23] of Byte;
 end;

 PSceSaveDataMemorySetupResult=^SceSaveDataMemorySetupResult;
 SceSaveDataMemorySetupResult=packed record
  existedMemorySize:size_t;
  reserved:array[0..15] of Byte;
 end;

 PSceSaveDataMemoryData=^SceSaveDataMemoryData;
 SceSaveDataMemoryData=packed record
  buf:Pointer;
  bufSize:QWORD;
  offset:QWORD;
  reserved:array[0..39] of Byte;
 end;

 PSceSaveDataMemoryGet2=^SceSaveDataMemoryGet2;
 SceSaveDataMemoryGet2=packed record
  userId:Integer;
  padding:array[0..3] of Byte;
  data:PSceSaveDataMemoryData;
  param:PSceSaveDataParam;
  icon:PSceSaveDataIcon;
  slotId:DWORD;
  reserved:array[0..27] of Byte;
 end;

 PSceSaveDataMemorySet2=^SceSaveDataMemorySet2;
 SceSaveDataMemorySet2=packed record
  userId:Integer;
  padding:array[0..3] of Byte;
  data:PSceSaveDataMemoryData;
  param:PSceSaveDataParam;
  icon:PSceSaveDataIcon;
  dataNum:DWORD;
  slotId:DWORD;
  reserved:array[0..23] of Byte;
 end;

 PSceSaveDataMemorySync=^SceSaveDataMemorySync;
 SceSaveDataMemorySync=packed record
  userId:Integer;
  slotId:DWORD;
  option:DWORD; //SceSaveDataMemorySyncOption
  reserved:array[0..27] of Byte;
 end;

 PSceSaveDataDirName=^SceSaveDataDirName;
 SceSaveDataDirName=array[0..SCE_SAVE_DATA_DIRNAME_DATA_MAXSIZE-1] of Char;

 PSceSaveDataMountPoint=^SceSaveDataMountPoint;
 SceSaveDataMountPoint=array[0..SCE_SAVE_DATA_MOUNT_POINT_DATA_MAXSIZE-1] of Char;

 pSceSaveDataTitleId=^SceSaveDataTitleId;
 SceSaveDataTitleId=packed record
  data:array[0..SCE_SAVE_DATA_TITLE_ID_DATA_SIZE-1] of Char;
  padding:array[0..5] of Byte;
 end;

 pSceSaveDataFingerprint=^SceSaveDataFingerprint;
 SceSaveDataFingerprint=packed record
  data:array[0..SCE_SAVE_DATA_FINGERPRINT_DATA_SIZE-1] of Byte;
  padding:array[0..14] of Byte;
 end;

 pSceSaveDataMount=^SceSaveDataMount;
 SceSaveDataMount=packed record
  userId:Integer; //SceUserServiceUserId
  align1:Integer;
  titleId:pSceSaveDataTitleId;
  dirName:PSceSaveDataDirName;
  fingerprint:pSceSaveDataFingerprint;
  blocks:QWORD;    //SceSaveDataBlocks
  mountMode:DWORD; //SceSaveDataMountMode
  reserved:array[0..31] of Byte;
 end;

 PSceSaveDataMount2=^SceSaveDataMount2;
 SceSaveDataMount2=packed record
  userId:Integer;
  align1:Integer;
  dirName:PSceSaveDataDirName;
  blocks:QWORD;
  mountMode:DWORD;
  reserved:array[0..31] of Byte;
  align2:Integer;
 end;

 PSceSaveDataMountResult=^SceSaveDataMountResult;
 SceSaveDataMountResult=packed record
  mountPoint:SceSaveDataMountPoint;
  requiredBlocks:QWORD;
  unused:DWORD;
  mountStatus:DWORD;
  reserved:array[0..27] of Byte;
  align1:Integer;
 end;

 pSceSaveDataMountInfo=^SceSaveDataMountInfo;
 SceSaveDataMountInfo=packed record
  blocks    :QWORD; //SceSaveDataBlocks
  freeBlocks:QWORD; //SceSaveDataBlocks
  reserved:array[0..31] of Byte;
 end;

 pSceSaveDataDirNameSearchCond=^SceSaveDataDirNameSearchCond;
 SceSaveDataDirNameSearchCond=packed record
  userId:Integer;
  _align:Integer;
  titleId:pSceSaveDataTitleId;
  dirName:pSceSaveDataDirName;
  key:DWORD;   //SceSaveDataSortKey
  order:DWORD; //SceSaveDataSortOrder
  reserved:array[0..31] of Byte;
 end;

 pSceSaveDataSearchInfo=^SceSaveDataSearchInfo;
 SceSaveDataSearchInfo=packed record
  blocks:QWORD;     //SceSaveDataBlocks
  freeBlocks:QWORD; //SceSaveDataBlocks
  reserved:array[0..31] of Byte;
 end;

 pSceSaveDataDirNameSearchResult=^SceSaveDataDirNameSearchResult;
 SceSaveDataDirNameSearchResult=packed record
  hitNum:DWORD;
  _align:Integer;
  dirNames:pSceSaveDataDirName;
  dirNamesNum:DWORD;
  setNum:DWORD;
  params:pSceSaveDataParam;
  infos:pSceSaveDataSearchInfo;
  reserved:array[0..11] of Byte;
  _align2:Integer;
 end;

implementation

uses
 sys_signal;

function ps4_sceSaveDataInitialize(params:Pointer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataInitialize2(params:Pointer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataInitialize3(params:Pointer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataTerminate:Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataSetupSaveDataMemory(
           userId:Integer;
           memorySize:QWORD;
           param:PSceSaveDataParam):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataSetupSaveDataMemory2(
           setupParam:PSceSaveDataMemorySetup2;
           _result:PSceSaveDataMemorySetupResult):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataGetSaveDataMemory(
           userId:Integer;
           buf:Pointer;
           bufSize:size_t;
           offset:QWORD):Integer; SysV_ABI_CDecl;
begin
 if (buf<>nil) then
 begin
  FillChar(buf^,bufSize,0);
 end;
 Result:=0;
end;

function ps4_sceSaveDataGetSaveDataMemory2(
           getParam:PSceSaveDataMemoryGet2):Integer; SysV_ABI_CDecl;
begin
 if (getParam<>nil) then
 begin
  if (getParam^.data<>nil) then
  begin
   if (getParam^.data^.buf<>nil) then
   begin
    FillChar(getParam^.data^.buf^,getParam^.data^.bufSize,0);
   end;
  end;
 end;
 Result:=0;
end;

function ps4_sceSaveDataSetSaveDataMemory(
           userId:Integer;
           buf:Pointer;
           bufSize:size_t;
           offset:QWORD):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataSetSaveDataMemory2(
           setParam:PSceSaveDataMemorySet2):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataSyncSaveDataMemory(
           syncParam:PSceSaveDataMemorySync):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

const
 SCE_SAVE_DATA_ERROR_PARAMETER  =-2137063424; // 0x809F0000
 SCE_SAVE_DATA_ERROR_EXISTS     =-2137063417; // 0x809F0007
 SCE_SAVE_DATA_ERROR_MOUNT_FULL =-2137063412; // 0x809F000C
 SCE_SAVE_DATA_ERROR_NOT_MOUNTED=-2137063420; // 0x809F0004

 SCE_SAVE_DATA_MOUNT_MODE_RDONLY      =1;  //Read-only
 SCE_SAVE_DATA_MOUNT_MODE_RDWR        =2;  //Read/write-enabled
 SCE_SAVE_DATA_MOUNT_MODE_CREATE      =4;  //Create new (error if save data directory already exists)
 SCE_SAVE_DATA_MOUNT_MODE_DESTRUCT_OFF=8;  //Turn off corrupt flag (not recommended)
 SCE_SAVE_DATA_MOUNT_MODE_COPY_ICON   =16; //Copy save_data.png in package as icon when newly creating save data
 SCE_SAVE_DATA_MOUNT_MODE_CREATE2     =32; //Create new (mount save data directory if it already exists)

function ps4_sceSaveDataMount(mount:pSceSaveDataMount;mountResult:pSceSaveDataMountResult):Integer; SysV_ABI_CDecl;
begin
 if (mount=nil) or (mountResult=nil) then Exit(SCE_SAVE_DATA_ERROR_PARAMETER);
 mountResult^:=Default(SceSaveDataMountResult);

 _sig_lock;
 Result:=FetchMount(PChar(mount^.dirName),@mountResult^.mountPoint,mount^.mountMode);
 _sig_unlock;

 if (Result=0) and
    ((mount^.mountMode and (SCE_SAVE_DATA_MOUNT_MODE_CREATE or SCE_SAVE_DATA_MOUNT_MODE_CREATE2))<>0) then
 begin
  mountResult^.mountStatus:=SCE_SAVE_DATA_MOUNT_STATUS_CREATED;
 end;

end;

function ps4_sceSaveDataMount2(mount:PSceSaveDataMount2;mountResult:PSceSaveDataMountResult):Integer; SysV_ABI_CDecl;
begin
 if (mount=nil) or (mountResult=nil) then Exit(SCE_SAVE_DATA_ERROR_PARAMETER);
 mountResult^:=Default(SceSaveDataMountResult);

 _sig_lock;
 Result:=FetchMount(PChar(mount^.dirName),@mountResult^.mountPoint,mount^.mountMode);
 _sig_unlock;

 if (Result=0) and
    ((mount^.mountMode and (SCE_SAVE_DATA_MOUNT_MODE_CREATE or SCE_SAVE_DATA_MOUNT_MODE_CREATE2))<>0) then
 begin
  mountResult^.mountStatus:=SCE_SAVE_DATA_MOUNT_STATUS_CREATED;
 end;

end;

function ps4_sceSaveDataUmount(mountPoint:PSceSaveDataMountPoint):Integer; SysV_ABI_CDecl;
begin
 _sig_lock;
 Result:=UnMountPath(PChar(mountPoint));
 _sig_unlock;
end;

function ps4_sceSaveDataGetMountInfo(mountPoint:PSceSaveDataMountPoint;
                                     info:pSceSaveDataMountInfo):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 if (info<>nil) then
 begin
  info^:=Default(SceSaveDataMountInfo);
  info^.blocks    :=100000;
  info^.freeBlocks:=100000;
 end;
end;

const
 SCE_SAVE_DATA_SORT_KEY_DIRNAME    =0;
 SCE_SAVE_DATA_SORT_KEY_USER_PARAM =1;
 SCE_SAVE_DATA_SORT_KEY_BLOCKS     =2;
 SCE_SAVE_DATA_SORT_KEY_MTIME      =3;
 SCE_SAVE_DATA_SORT_KEY_FREE_BLOCKS=4;

 SCE_SAVE_DATA_SORT_ORDER_ASCENT =0;
 SCE_SAVE_DATA_SORT_ORDER_DESCENT=1;

function _convert_dir_name_search(P:PChar):RawByteString;
var
 i:Integer;
begin
 Result:=RawByteString(P); //copy
 if (Length(Result)=0) then
 begin
  Result:='*';
 end else
 For i:=1 to Length(Result) do
 begin
  Case Result[i] of
   '%':Result[i]:='*';
   '_':Result[i]:='#';
   else;
  end;
 end;
end;

function StringListAscCompare(List:TStringList;Index1,Index2:Integer):Integer;
begin
 Result:=CompareStr(List[Index1],List[Index2]);
end;

function StringListDscCompare(List:TStringList;Index1,Index2:Integer):Integer;
begin
 Result:=CompareStr(List[Index2],List[Index1]);
end;

function ps4_sceSaveDataDirNameSearch(cond:pSceSaveDataDirNameSearchCond;
                                      sres:pSceSaveDataDirNameSearchResult):Integer; SysV_ABI_CDecl;
var
 ROut:TRawByteSearchRec;
 S,F:RawByteString;
 List:TStringList;
 i,n:Integer;
begin
 Result:=0;

 if (cond=nil) then Exit(SCE_SAVE_DATA_ERROR_PARAMETER);
 if (sres=nil) then Exit(SCE_SAVE_DATA_ERROR_PARAMETER);

 Case cond^.order of
  SCE_SAVE_DATA_SORT_ORDER_ASCENT :;
  SCE_SAVE_DATA_SORT_ORDER_DESCENT:;
  else
   Exit(SCE_SAVE_DATA_ERROR_PARAMETER);
 end;

 Assert(cond^.key  =SCE_SAVE_DATA_SORT_KEY_DIRNAME);

 s:=IncludeTrailingPathDelimiter(ps4_app.save_path)+_convert_dir_name_search(@cond^.dirName);

 ROut:=Default(TRawByteSearchRec);
 if (FindFirst(s,faDirectory,ROut)=0) then
 begin
  List:=TStringList.Create;
  repeat
   if (ROut.FindData.dwFileAttributes and faDirectory)=faDirectory then
   begin
    F:=UTF8Encode(WideString(ROut.FindData.cFileName));
    Case F of
     '.','..':;
     else
      List.Add(F);
    end;
   end;
  until (FindNext(ROut)<>0);
  FindClose(ROut);

  sres^.hitNum:=List.Count;
  if (List.Count<>0) and (sres^.dirNamesNum<>0) then
  begin
   Case cond^.order of
    SCE_SAVE_DATA_SORT_ORDER_ASCENT :List.CustomSort(@StringListAscCompare);
    SCE_SAVE_DATA_SORT_ORDER_DESCENT:List.CustomSort(@StringListDscCompare);
    else;
   end;

   n:=List.Count;
   if (n>sres^.dirNamesNum) then n:=sres^.dirNamesNum;

   sres^.setNum:=n;

   For i:=0 to n-1 do
   begin
    s:=List[i];

    if (sres^.dirNames<>nil) then
    begin
     sres^.dirNames[i]:=Default(SceSaveDataDirName);
     MoveChar0(PChar(s)^,sres^.dirNames[i],SCE_SAVE_DATA_DIRNAME_DATA_MAXSIZE);
    end;

    if (sres^.params<>nil) then
    begin
     sres^.params[i]:=Default(SceSaveDataParam);
    end;

    if (sres^.infos<>nil) then
    begin
     sres^.infos[i]:=Default(SceSaveDataSearchInfo);
     sres^.infos[i].blocks    :=100000;
     sres^.infos[i].freeBlocks:=100000;
    end;

   end;

  end else
  begin
   sres^.setNum:=0;
  end;

  FreeAndNil(List);

 end;

end;

type
 SceSaveDataParamType=DWORD;

function ps4_sceSaveDataSetParam(mountPoint:PSceSaveDataMountPoint;
                                 paramType:SceSaveDataParamType;
                                 paramBuf:Pointer;
                                 paramBufSize:size_t):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceSaveDataSaveIcon(mountPoint:PSceSaveDataMountPoint;
                                 param:pSceSaveDataIcon):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function Load_libSceSaveData(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;

 lib:=Result._add_lib('libSceSaveData');

 lib^.set_proc($664661B2408F5C5C,@ps4_sceSaveDataInitialize);
 lib^.set_proc($9753660DE0E93465,@ps4_sceSaveDataInitialize2);
 lib^.set_proc($4F2C2B14A0A82C66,@ps4_sceSaveDataInitialize3);
 lib^.set_proc($C8A0F2F12E722C0D,@ps4_sceSaveDataTerminate);
 lib^.set_proc($BFB00000CA342F3E,@ps4_sceSaveDataSetupSaveDataMemory);
 lib^.set_proc($A10C921147E05D10,@ps4_sceSaveDataSetupSaveDataMemory2);
 lib^.set_proc($EC1B79A410BF01CA,@ps4_sceSaveDataGetSaveDataMemory);
 lib^.set_proc($43038EEEF7A09D5F,@ps4_sceSaveDataGetSaveDataMemory2);
 lib^.set_proc($8776144735C64954,@ps4_sceSaveDataSetSaveDataMemory);
 lib^.set_proc($71DBB2F6FE18993E,@ps4_sceSaveDataSetSaveDataMemory2);
 lib^.set_proc($C224FD8DE0BBC4FC,@ps4_sceSaveDataSyncSaveDataMemory);
 lib^.set_proc($DF61D0010770336A,@ps4_sceSaveDataMount);
 lib^.set_proc($D33E393C81FE48D2,@ps4_sceSaveDataMount2);
 lib^.set_proc($04C47817F51E9371,@ps4_sceSaveDataUmount);
 lib^.set_proc($EB9547D1069ACFAB,@ps4_sceSaveDataGetMountInfo);
 lib^.set_proc($7722219D7ABFD123,@ps4_sceSaveDataDirNameSearch);
 lib^.set_proc($F39CEE97FFDE197B,@ps4_sceSaveDataSetParam);
 lib^.set_proc($73CF18CB9E0CC74C,@ps4_sceSaveDataSaveIcon);
end;

initialization
 ps4_app.RegistredPreLoad('libSceSaveData.prx',@Load_libSceSaveData);

end.

