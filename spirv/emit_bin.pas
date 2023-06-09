unit emit_bin;

{$mode ObjFPC}{$H+}

interface

uses
  SySutils,
  Classes,
  spirv,
  srNode,
  srType,
  srTypes,
  srConst,
  srVariable,
  srOp,
  srOpUtils,
  srCapability,
  srRefId,
  emit_fetch;

type
 TSPIRVHeader=packed record
  MAGIC:DWORD;
  VERSION:packed record
   MINOR:WORD;
   MAJOR:WORD;
  end;
  TOOL_VERSION:WORD;
  TOOL_ID:WORD;
  BOUND:DWORD;
  SCHEMA:DWORD;
 end;

 PSPIRVInstruction=^TSPIRVInstruction;
 TSPIRVInstruction=packed record
  OP:WORD;
  COUNT:WORD;
 end;

type
 TSVInstrBuffer=object
  Data:array of DWORD;
  COUNT:DWORD;
  Procedure AllocData;
  Procedure NewOp(OpId:WORD);
  Procedure Reset;
  Procedure Flush(Stream:TStream);
  procedure AddParam(P:DWORD);
  procedure AddNode(node:PsrNode);
 end;

 TSprvEmit_bin=class(TEmitFetch)
  procedure SaveToStream(Stream:TStream);
  procedure SaveHeader(Stream:TStream;var Header:TSPIRVHeader);
  procedure SaveCaps(Stream:TStream);
  procedure SaveOpBlock(Stream:TStream;pBlock:PsrOpBlock);
  procedure SaveHeaderInfo(Stream:TStream);
  procedure SaveTypes(Stream:TStream);
  procedure SaveConst(Stream:TStream);
  procedure SaveVariable(Stream:TStream);
  procedure SaveFunc(Stream:TStream);
  procedure SaveOp(Stream:TStream;node:PSpirvOp);
 end;

implementation

Procedure TSVInstrBuffer.AllocData;
begin
 if (Length(Data)<COUNT) then
 begin
  SetLength(Data,COUNT);
 end;
end;

Procedure TSVInstrBuffer.NewOp(OpId:WORD);
var
 I:TSPIRVInstruction;
begin
 Assert(COUNT=0,'prev op not flushed');

 COUNT:=1;
 AllocData;

 I.OP:=OpId;
 I.COUNT:=0;

 Data[0]:=DWORD(I);
end;

Procedure TSVInstrBuffer.Reset;
begin
 COUNT:=0;
end;

Procedure TSVInstrBuffer.Flush(Stream:TStream);
begin
 if (Stream=nil) or (COUNT=0) then Exit;
 TSPIRVInstruction(Data[0]).COUNT:=COUNT;
 Stream.Write(Data[0],COUNT*SizeOf(DWORD));
 Reset;
end;

procedure TSVInstrBuffer.AddParam(P:DWORD);
var
 I:DWORD;
begin
 Assert(COUNT<>0,'new op not created');
 I:=COUNT;
 Inc(COUNT);
 AllocData;
 Data[i]:=P;
end;

procedure TSVInstrBuffer.AddNode(node:PsrNode);
var
 R:PsrRefId;
 I,L,D:DWORD;
begin
 Assert(node<>nil);
 Assert(COUNT<>0,'new op not created');

 R:=node^.GetRef;
 if (R<>nil) then
 begin
  I:=COUNT;
  Inc(COUNT);
  AllocData;
  Data[i]:=R^.ID;
 end else
 begin
  L:=node^.GetData(nil);          //get size
  D:=(L+(SizeOf(DWORD)-1)) div 4; //align
  Assert(D<>0,'AddNode:'+node^.ntype.ClassName);

  I:=COUNT;
  COUNT:=COUNT+D;
  AllocData;

  FillDWord(Data[i],D,0);
  node^.GetData(@Data[i]);
 end;
end;

procedure TSprvEmit_bin.SaveToStream(Stream:TStream);
var
 Header:TSPIRVHeader;
begin
 if (Stream=nil) then Exit;

 Header:=Default(TSPIRVHeader);

       Header.MAGIC       :=MagicNumber;
 DWORD(Header.VERSION)    :=Config.SpvVersion;
       Header.TOOL_VERSION:=2;
       Header.TOOL_ID     :=0;
       Header.BOUND       :=RefIdAlloc.GetSpirvIDBound;
       Header.SCHEMA      :=0;

 SaveHeader(Stream,Header);

 SaveCaps(Stream);
 SaveHeaderInfo(Stream);
 SaveTypes(Stream);
 SaveConst(Stream);
 SaveVariable(Stream);
 SaveFunc(Stream);
end;

procedure TSprvEmit_bin.SaveHeader(Stream:TStream;var Header:TSPIRVHeader);
begin
 Stream.Write(Header,SizeOf(TSPIRVHeader));
end;

procedure TSprvEmit_bin.SaveCaps(Stream:TStream);
var
 buf:TSVInstrBuffer;
 node:PsrCapability;
begin
 buf:=Default(TSVInstrBuffer);
 node:=CapabilityList.First;
 While (node<>nil) do
 begin
  buf.NewOp(Op.OpCapability);
  buf.AddParam(node^.ID);
  buf.Flush(Stream);
  node:=CapabilityList.Next(node);
 end;
end;

procedure TSprvEmit_bin.SaveOpBlock(Stream:TStream;pBlock:PsrOpBlock);
var
 node:PSpirvOp;
begin
 if (pBlock=nil) then Exit;
 node:=pBlock^.First;

 While (node<>nil) do
 begin
  if node^.IsType(ntOp) then
  begin
   SaveOp(Stream,node);
  end;
  node:=flow_down_next_up(node);
 end;
end;

procedure TSprvEmit_bin.SaveHeaderInfo(Stream:TStream);
begin
 SaveOpBlock(Stream,@HeaderList);
 SaveOpBlock(Stream,@DebugInfoList);
 SaveOpBlock(Stream,@DecorateList);
end;

procedure TSprvEmit_bin.SaveTypes(Stream:TStream);
var
 buf:TSVInstrBuffer;
 node:PsrType;
 i:Word;
begin
 node:=TypeList.First;
 While (node<>nil) do
 begin
  buf.NewOp(node^.OpId);
  buf.AddNode(node);

  if (node^.ItemCount<>0) then
  begin
   For i:=0 to node^.ItemCount-1 do
   begin
    buf.AddNode(node^.GetItem(i));
   end;
  end;

  buf.Flush(Stream);

  node:=node^.Next;
 end;
end;

procedure TSprvEmit_bin.SaveConst(Stream:TStream);
var
 buf:TSVInstrBuffer;
 node:PsrConst;
 i:Word;
begin
 buf:=Default(TSVInstrBuffer);
 node:=ConstList.FList.pHead;
 While (node<>nil) do
 begin
  if (node^.dtype<>dtUnknow) then
  begin
   buf.NewOp(node^.OpId);
   buf.AddNode(node^.pType);
   buf.AddNode(node);

   if (node^.dtype<>dtBool) and (node^.ItemCount<>0) then
   begin
    For i:=0 to node^.ItemCount-1 do
    begin
     buf.AddNode(node^.GetItem(i));
    end;
   end;

   buf.Flush(Stream);
  end;
  node:=node^.Next;
 end;
end;

procedure TSprvEmit_bin.SaveVariable(Stream:TStream);
var
 buf:TSVInstrBuffer;
 node:PsrVariable;
begin
 buf:=Default(TSVInstrBuffer);
 node:=VariableList.First;
 While (node<>nil) do
 begin
  if (node^.pType<>nil) then
  begin
   buf.NewOp(Op.OpVariable);
   buf.AddNode(node^.pType);
   buf.AddNode(node);
   buf.AddParam(node^.GetStorageClass);

   buf.Flush(Stream);
  end;
  node:=node^.Next;
 end;
end;

procedure TSprvEmit_bin.SaveFunc(Stream:TStream);
var
 pFunc:PSpirvFunc;
begin
 pFunc:=FuncList.First;
 While (pFunc<>nil) do
 begin
  SaveOpBlock(Stream,pFunc^.pTop);
  pFunc:=pFunc^.Next;
 end;
end;

procedure TSprvEmit_bin.SaveOp(Stream:TStream;node:PSpirvOp);
var
 buf:TSVInstrBuffer;
 Param:POpParamNode;
 Info:Op.TOpInfo;
begin
 if (node=nil) then Exit;
 buf:=Default(TSVInstrBuffer);

 Info:=Op.GetInfo(node^.OpId);

 buf.NewOp(node^.OpId);

 if Info.rstype then //dst type
 begin
  Assert(node^.pType<>nil,'SaveOp$1');
  if (node^.pType<>nil) then
  begin
   buf.AddNode(node^.pType);
  end else
  begin
   buf.Reset;
   Exit;
  end;
 end;

 if Info.result then //dst
 begin
  Assert(node^.pDst<>nil,'SaveOp$2');
  if (node^.pDst<>nil) then
  begin
   buf.AddNode(node^.pDst);
  end else
  begin
   buf.Reset;
   Exit;
  end;
 end else
 begin  //no dst
  if (node^.pDst<>nil) then
  begin
   buf.AddNode(node^.pDst);
  end;
 end;

 Param:=node^.ParamFirst;
 While (Param<>nil) do
 begin
  buf.AddNode(Param^.Value);
  Param:=Param^.Next;
 end;

 buf.Flush(Stream);
end;

end.



