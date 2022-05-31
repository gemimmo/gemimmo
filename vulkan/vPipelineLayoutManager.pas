unit vPipelineLayoutManager;

{$mode objfpc}{$H+}

interface

uses
 SysUtils,
 RWLock,
 g23tree,
 Vulkan,
 vPipeline;

Function FetchPipelineLayout(const A:AvSetLayout;
                             const B:AvPushConstantRange):TvPipelineLayout;

implementation

type
 TvPipelineLayoutCompare=class
  class function c(a,b:PvPipelineLayoutKey):Integer; static;
 end;

 _TvPipelineLayoutPool=specialize T23treeSet<PvPipelineLayoutKey,TvPipelineLayoutCompare>;
 TvPipelineLayoutPool=object(_TvPipelineLayoutPool)
  lock:TRWLock;
  Procedure Init;
  Procedure Lock_wr;
  Procedure Unlock;
 end;

var
 FPipelineLayoutPool:TvPipelineLayoutPool;

Procedure TvPipelineLayoutPool.Init;
begin
 rwlock_init(lock);
end;

Procedure TvPipelineLayoutPool.Lock_wr;
begin
 rwlock_wrlock(lock);
end;

Procedure TvPipelineLayoutPool.Unlock;
begin
 rwlock_unlock(lock);
end;

Function FetchPipelineLayout(const A:AvSetLayout;
                             const B:AvPushConstantRange):TvPipelineLayout;
var
 key:TvPipelineLayoutKey;

 t:TvPipelineLayout;
 i:TvPipelineLayoutPool.Iterator;
begin
 key:=Default(TvPipelineLayoutKey);
 key.FLayouts   :=A;
 key.FPushConsts:=B;

 FPipelineLayoutPool.Lock_wr;

 i:=FPipelineLayoutPool.find(@key);
 if (i.Item=nil) then
 begin
  t:=TvPipelineLayout.Create;
  t.key:=key;
  FPipelineLayoutPool.Insert(@t.key);
  Result:=t;
 end else
 begin
  t:=TvPipelineLayout(ptruint(i.Item^)-ptruint(@TvPipelineLayout(nil).key));

  Result:=t;
 end;

 FPipelineLayoutPool.Unlock;

 t.Compile;
end;

function ComparePtruint(buf1,buf2:PPtruint;count:PtrUint):Integer;
begin
 Result:=0;
 While (count<>0) do
 begin
  Result:=Integer(buf1^>buf2^)-Integer(buf1^<buf2^);
  if (Result<>0) then Exit;
  Inc(buf1);
  Inc(buf2);
  Dec(count);
 end;
end;

function ComparePushRange(var a,b:TVkPushConstantRange):Integer;
begin
 //1 stageFlags
 Result:=Integer(a.stageFlags>b.stageFlags)-Integer(a.stageFlags<b.stageFlags);
 if (Result<>0) then Exit;
 //2 offset
 Result:=Integer(a.offset>b.offset)-Integer(a.offset<b.offset);
 if (Result<>0) then Exit;
 //3 size
 Result:=Integer(a.size>b.size)-Integer(a.size<b.size);
end;

function ComparePushRanges(var buf1,buf2:AvPushConstantRange;count:PtrUint):Integer;
var
 i:PtrUint;
begin
 Result:=0;
 if (count<>0) then
  For i:=0 to count-1 do
  begin
   Result:=ComparePushRange(buf1[i],buf2[i]);
   if (Result<>0) then Exit;
  end;
end;

class function TvPipelineLayoutCompare.c(a,b:PvPipelineLayoutKey):Integer;
begin
 //1 Length(FLayouts)
 Result:=Integer(Length(a^.FLayouts)>Length(b^.FLayouts))-Integer(Length(a^.FLayouts)<Length(b^.FLayouts));
 if (Result<>0) then Exit;
 //2 Length(FPushConsts)
 Result:=Integer(Length(a^.FPushConsts)>Length(b^.FPushConsts))-Integer(Length(a^.FPushConsts)<Length(b^.FPushConsts));
 if (Result<>0) then Exit;
 //3 FLayouts
 Result:=ComparePtruint(@a^.FLayouts[0],@b^.FLayouts[0],Length(a^.FLayouts));
 if (Result<>0) then Exit;
 //4 FPushConsts
 Result:=ComparePushRanges(a^.FPushConsts,b^.FPushConsts,Length(a^.FPushConsts));
end;

initialization
 FPipelineLayoutPool.Init;

end.

