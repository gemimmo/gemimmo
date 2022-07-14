unit ps4_libSceAjm;

{$mode objfpc}{$H+}

interface

uses
  ps4_program,
  ps4_handles,
  Classes,
  SysUtils;

implementation

{$I ajm_error.inc}

const
 SCE_AJM_CODEC_MP3_DEC  =0;
 SCE_AJM_CODEC_AT9_DEC  =1;
 SCE_AJM_CODEC_M4AAC_DEC=2;
 SCE_AJM_CODEC_CELP8_DEC=3;
 SCE_AJM_CODEC_CELP8_ENC=4;
 SCE_AJM_CODEC_CELP_DEC =12;
 SCE_AJM_CODEC_CELP_ENC =13;

var
 FAjmMap:TIntegerHandles;

type
 PSceAjmContextId=^SceAjmContextId;
 SceAjmContextId=Integer;
 SceAjmCodecType=Integer;

 pSceAjmInstanceId=^SceAjmInstanceId;
 SceAjmInstanceId=DWORD;

 SceAjmResult=Integer;
 pSceAjmSidebandResult=^SceAjmSidebandResult;
 SceAjmSidebandResult=packed record
  iResult        :SceAjmResult;
  iInternalResult:SceAjmResult;
 end;

 pSceAjmBuffer=^SceAjmBuffer;
 SceAjmBuffer=packed record
  pAddress:Pointer;
  szSize  :qword;
 end;

type
 pSceAjmBatchId=^SceAjmBatchId;
 SceAjmBatchId=DWORD;

 pSceAjmBatchError=^SceAjmBatchError;
 SceAjmBatchError=packed record
  iErrorCode:Integer;      //Detailed error code
  align1:Integer;
  pJobAddress:Pointer;     //For internal use only
  uiCommandOffset:Integer; //For internal use only
  align2:Integer;
  pJobOriginRa:Pointer;    //For internal use only
 end;

 TAjmContext=class(TClassHandle)
  AJM_CODEC_MP3_DEC  :Pointer;
  AJM_CODEC_AT9_DEC  :Pointer;
  AJM_CODEC_M4AAC_DEC:Pointer;
  AJM_CODEC_CELP8_DEC:Pointer;
  AJM_CODEC_CELP8_ENC:Pointer;
  AJM_CODEC_CELP_DEC :Pointer;
  AJM_CODEC_CELP_ENC :Pointer;
 end;


function ps4_sceAjmInitialize(iReserved:QWORD;pContext:PSceAjmContextId):Integer; SysV_ABI_CDecl;
Var
 H:TAjmContext;
begin
 if (pContext=nil) then Exit(SCE_AJM_ERROR_INVALID_PARAMETER);
 H:=TAjmContext.Create;
 pContext^:=-1;
 FAjmMap.New(H,pContext^);
 H.Release;
 Result:=0;
end;

function ps4_sceAjmModuleRegister(uiContext:SceAjmContextId;uiCodec:SceAjmCodecType;iReserved:QWORD):Integer; SysV_ABI_CDecl;
Var
 H:TAjmContext;
begin
 Result:=0;

 H:=TAjmContext(FAjmMap.Acqure(uiContext));
 if (H=nil) then Exit(SCE_AJM_ERROR_INVALID_CONTEXT);

 Case uiCodec of
  SCE_AJM_CODEC_MP3_DEC  :
    begin
     if (H.AJM_CODEC_MP3_DEC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_MP3_DEC:=Pointer(1);
    end;
  SCE_AJM_CODEC_AT9_DEC  :
    begin
     if (H.AJM_CODEC_AT9_DEC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_AT9_DEC:=Pointer(1);
    end;
  SCE_AJM_CODEC_M4AAC_DEC:
    begin
     if (H.AJM_CODEC_M4AAC_DEC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_M4AAC_DEC:=Pointer(1);
    end;
  SCE_AJM_CODEC_CELP8_DEC:
    begin
     if (H.AJM_CODEC_CELP8_DEC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP8_DEC:=Pointer(1);
    end;
  SCE_AJM_CODEC_CELP8_ENC:
    begin
     if (H.AJM_CODEC_CELP8_ENC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP8_ENC:=Pointer(1);
    end;
  SCE_AJM_CODEC_CELP_DEC :
    begin
     if (H.AJM_CODEC_CELP_DEC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP_DEC:=Pointer(1);
    end;
  SCE_AJM_CODEC_CELP_ENC :
    begin
     if (H.AJM_CODEC_CELP_ENC<>nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_ALREADY_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP_ENC:=Pointer(1);
    end;
  else
    begin
     Result:=SCE_AJM_ERROR_INVALID_PARAMETER;
     H.Release;
     Exit;
    end;
 end;

 Case uiCodec of
  SCE_AJM_CODEC_MP3_DEC  :Writeln('SCE_AJM_CODEC_MP3_DEC  ');
  SCE_AJM_CODEC_AT9_DEC  :Writeln('SCE_AJM_CODEC_AT9_DEC  ');
  SCE_AJM_CODEC_M4AAC_DEC:Writeln('SCE_AJM_CODEC_M4AAC_DEC');
  SCE_AJM_CODEC_CELP8_DEC:Writeln('SCE_AJM_CODEC_CELP8_DEC');
  SCE_AJM_CODEC_CELP8_ENC:Writeln('SCE_AJM_CODEC_CELP8_ENC');
  SCE_AJM_CODEC_CELP_DEC :Writeln('SCE_AJM_CODEC_CELP_DEC ');
  SCE_AJM_CODEC_CELP_ENC :Writeln('SCE_AJM_CODEC_CELP_ENC ');
 end;

 H.Release;
end;

function ps4_sceAjmModuleUnregister(uiContext:SceAjmContextId;uiCodec:SceAjmCodecType):Integer; SysV_ABI_CDecl;
Var
 H:TAjmContext;
begin
 Result:=0;

 H:=TAjmContext(FAjmMap.Acqure(uiContext));
 if (H=nil) then Exit(SCE_AJM_ERROR_INVALID_CONTEXT);

 Case uiCodec of
  SCE_AJM_CODEC_MP3_DEC  :
    begin
     if (H.AJM_CODEC_MP3_DEC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_MP3_DEC:=nil;
    end;
  SCE_AJM_CODEC_AT9_DEC  :
    begin
     if (H.AJM_CODEC_AT9_DEC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_AT9_DEC:=nil;
    end;
  SCE_AJM_CODEC_M4AAC_DEC:
    begin
     if (H.AJM_CODEC_M4AAC_DEC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_M4AAC_DEC:=nil;
    end;
  SCE_AJM_CODEC_CELP8_DEC:
    begin
     if (H.AJM_CODEC_CELP8_DEC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP8_DEC:=nil;
    end;
  SCE_AJM_CODEC_CELP8_ENC:
    begin
     if (H.AJM_CODEC_CELP8_ENC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP8_ENC:=nil;
    end;
  SCE_AJM_CODEC_CELP_DEC :
    begin
     if (H.AJM_CODEC_CELP_DEC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP_DEC:=nil;
    end;
  SCE_AJM_CODEC_CELP_ENC :
    begin
     if (H.AJM_CODEC_CELP_ENC=nil) then
     begin
      Result:=SCE_AJM_ERROR_CODEC_NOT_REGISTERED;
      H.Release;
      Exit;
     end;
     H.AJM_CODEC_CELP_ENC:=nil;
    end;
  else
    begin
     Result:=SCE_AJM_ERROR_INVALID_PARAMETER;
     H.Release;
     Exit;
    end;
 end;

 H.Release;
end;

function ps4_sceAjmFinalize(uiContext:SceAjmContextId):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 if not FAjmMap.Delete(uiContext) then Result:=SCE_AJM_ERROR_INVALID_CONTEXT;
end;

function ps4_sceAjmInstanceCreate(uiContext:SceAjmContextId;
                                  uiCodec:SceAjmCodecType;
                                  uiFlags:QWORD;
                                  pInstance:pSceAjmInstanceId):Integer; SysV_ABI_CDecl;
Var
 H:TAjmContext;
begin
 Result:=0;

 H:=TAjmContext(FAjmMap.Acqure(uiContext));
 if (H=nil) then Exit(SCE_AJM_ERROR_INVALID_CONTEXT);

 Case uiCodec of
  SCE_AJM_CODEC_MP3_DEC  ,
  SCE_AJM_CODEC_AT9_DEC  ,
  SCE_AJM_CODEC_M4AAC_DEC,
  SCE_AJM_CODEC_CELP8_DEC,
  SCE_AJM_CODEC_CELP8_ENC,
  SCE_AJM_CODEC_CELP_DEC ,
  SCE_AJM_CODEC_CELP_ENC :
   begin
    //fake instance
    pInstance^:=1;
   end;
  else
    begin
     Result:=SCE_AJM_ERROR_INVALID_PARAMETER;
     H.Release;
     Exit;
    end;
 end;

 H.Release;
end;

function ps4_sceAjmBatchJobControlBufferRa(
          pBatchPosition:Pointer;
          uiInstance:SceAjmInstanceId;
          uiFlags:qword;
          pSidebandInput:Pointer;
          szSidebandInputSize:qword;
          pSidebandOutput:Pointer;
          szSidebandOutputSize:qword;
          pReturnAddress:PPointer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 if (pSidebandOutput<>nil) then
 begin
  FillChar(pSidebandOutput^,szSidebandOutputSize,0);
 end;
end;

function ps4_sceAjmBatchJobRunSplitBufferRa(
          pBatchPosition:Pointer;
          uiInstance:SceAjmInstanceId;
          uiFlags:qword;
          pDataInputBuffers:pSceAjmBuffer;
          szNumDataInputBuffers:qword;
          pDataOutputBuffers:pSceAjmBuffer;
          szNumDataOutputBuffers:qword;
          pSidebandOutput:Pointer;
          szSidebandOutputSize:qword;
          pReturnAddress:PPointer):Integer; SysV_ABI_CDecl;
var
 i:qword;
begin
 Result:=0;
 if (pSidebandOutput<>nil) then
 begin
  FillChar(pSidebandOutput^,szSidebandOutputSize,0);
 end;

 if (pDataOutputBuffers<>nil) and (szNumDataOutputBuffers<>0) then
 begin
  For i:=0 to szNumDataOutputBuffers-1 do
  if (pDataOutputBuffers[i].pAddress<>nil) then
  begin
   FillChar(pDataOutputBuffers[i].pAddress^,pDataOutputBuffers[i].szSize,0);
  end;
 end;
end;

function ps4_sceAjmBatchStartBuffer(
          uiContext:SceAjmContextId;
          pBatchCommands:Pointer;
          szBatchSize:qword;
          iPriority:Integer;
          pBatchError:pSceAjmBatchError;
          pBatch:pSceAjmBatchId):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceAjmBatchWait(
          uiContext:SceAjmContextId;
          uiBatch:SceAjmBatchId;
          uiTimeout:DWORD;
          pBatchError:pSceAjmBatchError):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function Load_libSceAjm(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;

 lib:=Result._add_lib('libSceAjm');
 lib^.set_proc($765FB87874B352EE,@ps4_sceAjmInitialize);
 lib^.set_proc($43777216EC069FAE,@ps4_sceAjmModuleRegister);
 lib^.set_proc($5A2EC3B652D5F8A2,@ps4_sceAjmModuleUnregister);
 lib^.set_proc($307BABEAA0AC52EB,@ps4_sceAjmFinalize);
 lib^.set_proc($031A03AC8369E09F,@ps4_sceAjmInstanceCreate);
 lib^.set_proc($7660F26CDFFF167F,@ps4_sceAjmBatchJobControlBufferRa);
 lib^.set_proc($EE37405CAFB67CCA,@ps4_sceAjmBatchJobRunSplitBufferRa);
 lib^.set_proc($7C5164934C5F196B,@ps4_sceAjmBatchStartBuffer);
 lib^.set_proc($FEA2EC7C3032C086,@ps4_sceAjmBatchWait);
end;

initialization
 FAjmMap:=TIntegerHandles.Create;
 ps4_app.RegistredPreLoad('libSceAjm.prx',@Load_libSceAjm);

end.

