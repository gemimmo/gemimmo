unit ps4_libSceAppContent;

{$mode objfpc}{$H+}

interface

uses
  ps4_program,
  Classes,
  SysUtils;

implementation

uses
 sys_path;

type
 PSceAppContentInitParam=^SceAppContentInitParam;
 SceAppContentInitParam=packed record
  reserved:array[0..31] of Byte;
 end;

 PSceAppContentBootParam=^SceAppContentBootParam;
 SceAppContentBootParam=packed record
  reserved1:array[0..3] of Byte;
  attr:DWORD;
  reserved2:array[0..31] of Byte;
 end;

function ps4_sceAppContentInitialize(initParam:PSceAppContentInitParam;bootParam:PSceAppContentBootParam):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceAppContentInitialize');

 if (initParam<>nil) then
 begin
  initParam^:=Default(SceAppContentInitParam);
 end;

 if (bootParam<>nil) then
 begin
  bootParam^:=Default(SceAppContentBootParam);
 end;

 Result:=0;
end;

Const
 SCE_APP_CONTENT_APPPARAM_ID_SKU_FLAG=0;
 SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_1=1;
 SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_2=2;
 SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_3=3;
 SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_4=4;

 SCE_APP_CONTENT_ERROR_PARAMETER=-2133262334;//0x80D90002

 SCE_APP_CONTENT_APPPARAM_SKU_FLAG_TRIAL=1;
 SCE_APP_CONTENT_APPPARAM_SKU_FLAG_FULL =2;

 SCE_APP_CONTENT_ADDCONT_DOWNLOAD_STATUS_INSTALLED=4;

function ps4_sceAppContentAppParamGetInt(paramId:DWORD;value:PInteger):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceAppContentAppParamGetInt:',paramId);
 Case SCE_APP_CONTENT_APPPARAM_ID_SKU_FLAG of
  SCE_APP_CONTENT_APPPARAM_ID_SKU_FLAG:Result:=SCE_APP_CONTENT_APPPARAM_SKU_FLAG_FULL;
  SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_1..
  SCE_APP_CONTENT_APPPARAM_ID_USER_DEFINED_PARAM_4:Result:=0;
  else
   Result:=SCE_APP_CONTENT_ERROR_PARAMETER;
 end;
end;

const
 SCE_NP_UNIFIED_ENTITLEMENT_LABEL_SIZE=17;

type
 SceNpUnifiedEntitlementLabel=packed record
  data:array[0..SCE_NP_UNIFIED_ENTITLEMENT_LABEL_SIZE-1] of AnsiChar;
  padding:array[0..2] of Byte;
 end;

 pSceAppContentAddcontInfo=^SceAppContentAddcontInfo;
 SceAppContentAddcontInfo=packed record
  entitlementLabel:SceNpUnifiedEntitlementLabel;
  status:DWORD; //SceAppContentAddcontDownloadStatus
 end;

function ps4_sceAppContentGetAddcontInfoList(serviceLabel:DWORD; //SceNpServiceLabel
                                             list:pSceAppContentAddcontInfo;
                                             listNum:DWORD;
                                             hitNum:PDWORD):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 Writeln('sceAppContentGetAddcontInfoList:0x',HexStr(serviceLabel,8));
 if (hitNum<>nil) then
 begin
  hitNum^:=0;
 end;
end;

const
 SCE_APP_CONTENT_MOUNTPOINT_DATA_MAXSIZE=16;
 SCE_APP_CONTENT_ADDCONT_MOUNT_MAXNUM   =64;

 //E temporary data option
 SCE_APP_CONTENT_TEMPORARY_DATA_OPTION_NONE  =0;
 SCE_APP_CONTENT_TEMPORARY_DATA_OPTION_FORMAT=1;

type
 pSceAppContentMountPoint=^SceAppContentMountPoint;
 SceAppContentMountPoint=array[0..SCE_APP_CONTENT_MOUNTPOINT_DATA_MAXSIZE-1] of AnsiChar;

function ps4_sceAppContentTemporaryDataFormat(mountPoint:pSceAppContentMountPoint):Integer; SysV_ABI_CDecl;
begin
 Result:=FormatTmpPath(PChar(mountPoint));
end;

function ps4_sceAppContentTemporaryDataMount(mountPoint:pSceAppContentMountPoint):Integer; SysV_ABI_CDecl;
begin
 Result:=FetchTmpMount(PChar(mountPoint),SCE_APP_CONTENT_TEMPORARY_DATA_OPTION_FORMAT);
end;

function ps4_sceAppContentTemporaryDataMount2(option:DWORD;mountPoint:pSceAppContentMountPoint):Integer; SysV_ABI_CDecl;
begin
 Result:=FetchTmpMount(PChar(mountPoint),option);
end;

function Load_libSceAppContent(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;

 lib:=Result._add_lib('libSceAppContent');

 lib^.set_proc($47D940F363AB68DB,@ps4_sceAppContentInitialize);
 lib^.set_proc($F7D6FCD88297A47E,@ps4_sceAppContentAppParamGetInt);
 lib^.set_proc($C6777C049CC0C669,@ps4_sceAppContentGetAddcontInfoList);
 lib^.set_proc($6B937B9401B4CB64,@ps4_sceAppContentTemporaryDataFormat);
 lib^.set_proc($EDB38B5FAE88CFF5,@ps4_sceAppContentTemporaryDataMount);
 lib^.set_proc($6EE61B78B3865A60,@ps4_sceAppContentTemporaryDataMount2);
end;


initialization
 ps4_app.RegistredPreLoad('libSceAppContent.prx',@Load_libSceAppContent);

end.

