unit ps4_libSceNet;

{$mode objfpc}{$H+}

interface

uses
  sockets,
  ps4_program,
  Classes,
  SysUtils;

implementation

type
 SceNetInAddr_t=DWORD;

 pSceNetInAddr=^SceNetInAddr;
 SceNetInAddr=packed record
  s_addr:SceNetInAddr_t;
 end;

const
 SCE_NET_ETHER_ADDR_LEN  =6;
 SCE_NET_ETHER_ADDRSTRLEN=18;

type
 pSceNetEtherAddr=^SceNetEtherAddr;
 SceNetEtherAddr=packed record
  data:array[0..SCE_NET_ETHER_ADDR_LEN-1] of Byte;
 end;

function ps4_sceNetInit:Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceNetTerm:Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

function ps4_sceNetPoolCreate(name:PChar;size,flags:Integer):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceNetPoolCreate:',name,':',size,':',flags);
 Result:=2;
end;

function ps4_sceNetPoolDestroy(memid:Integer):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceNetPoolDestroy:',memid);
 Result:=0;
end;

function ps4_sceNetResolverCreate(name:PChar;memid,flags:Integer):Integer; SysV_ABI_CDecl;
begin
 Writeln('sceNetResolverCreate:',name,':',memid);
 Result:=111;
end;

const
 AF_INET  = 2;
 AF_INET6 = 10;

 SCE_NET_EAFNOSUPPORT=47;

function ps4_sceNetInetPton(af:Integer;
                            src:Pchar;
                            dst:Pointer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 if (src=nil) or (dst=nil) then Exit;

 Case af of
  AF_INET :if TryStrToHostAddr (src, in_addr(dst^)) then Result:=1;
  AF_INET6:if TryStrToHostAddr6(src,in6_addr(dst^)) then Result:=1;
  else;
   //Exit(SCE_NET_EAFNOSUPPORT);
 end;

end;

function ps4_sceNetEtherNtostr(n:pSceNetEtherAddr;
                               str:Pchar;
                               len:QWORD):Integer; SysV_ABI_CDecl;
var
 i,p:Byte;
begin
 Result:=0;
 if (n=nil) or (str=nil) then Exit;
 if (len<SCE_NET_ETHER_ADDRSTRLEN) then Exit;

 p:=0;
 For i:=0 to SCE_NET_ETHER_ADDR_LEN-1 do
 begin
  str[p]:=HexStr(n^.data[i]      ,1)[1]; Inc(p);
  str[p]:=HexStr(n^.data[i] shl 8,1)[1]; Inc(p);
  if (i<>SCE_NET_ETHER_ADDR_LEN-1) then
  begin
   str[p]:=':'; Inc(p);
  end;
 end;

end;

function ps4_sceNetGetMacAddress(addr:pSceNetEtherAddr;
                                 flags:Integer):Integer; SysV_ABI_CDecl;
begin
 Result:=0;
 if (addr=nil) then Exit;
 FillChar(addr^,SizeOf(SceNetEtherAddr),11);
end;


function ps4_sceNetCtlInit:Integer; SysV_ABI_CDecl;
begin
 Result:=0;
end;

const
 SCE_NET_CTL_ERROR_NOT_INITIALIZED =-2143215359; // 0x80412101
 SCE_NET_CTL_ERROR_CALLBACK_MAX    =-2143215357; // 0x80412103
 SCE_NET_CTL_ERROR_ID_NOT_FOUND    =-2143215356; // 0x80412104
 SCE_NET_CTL_ERROR_INVALID_ID      =-2143215355; // 0x80412105
 SCE_NET_CTL_ERROR_INVALID_CODE    =-2143215354; // 0x80412106
 SCE_NET_CTL_ERROR_INVALID_ADDR    =-2143215353; // 0x80412107
 SCE_NET_CTL_ERROR_NOT_CONNECTED   =-2143215352; // 0x80412108
 SCE_NET_CTL_ERROR_NOT_AVAIL       =-2143215351; // 0x80412109
 SCE_NET_CTL_ERROR_NETWORK_DISABLED=-2143215347; // 0x8041210D
 SCE_NET_CTL_ERROR_DISCONNECT_REQ  =-2143215346; // 0x8041210E
 SCE_NET_CTL_ERROR_INVALID_TYPE    =-2143215345; // 0x8041210F
 SCE_NET_CTL_ERROR_INVALID_SIZE    =-2143215343; // 0x80412111
 SCE_NET_CTL_ERROR_ETHERNET_PLUGOUT=-2143215339; // 0x80412115
 SCE_NET_CTL_ERROR_WIFI_DEAUTHED   =-2143215338; // 0x80412116
 SCE_NET_CTL_ERROR_WIFI_BEACON_LOST=-2143215337; // 0x80412117

 // state
 SCE_NET_CTL_STATE_DISCONNECTED=0;
 SCE_NET_CTL_STATE_CONNECTING  =1;
 SCE_NET_CTL_STATE_IPOBTAINING =2;
 SCE_NET_CTL_STATE_IPOBTAINED  =3;

 // event type
 SCE_NET_CTL_EVENT_TYPE_DISCONNECTED=1;
 SCE_NET_CTL_EVENT_TYPE_DISCONNECT_REQ_FINISHED=2;
 SCE_NET_CTL_EVENT_TYPE_IPOBTAINED=3;

 // info code
 SCE_NET_CTL_INFO_DEVICE           = 1;
 SCE_NET_CTL_INFO_ETHER_ADDR       = 2;
 SCE_NET_CTL_INFO_MTU              = 3;
 SCE_NET_CTL_INFO_LINK             = 4;
 SCE_NET_CTL_INFO_BSSID            = 5;
 SCE_NET_CTL_INFO_SSID             = 6;
 SCE_NET_CTL_INFO_WIFI_SECURITY    = 7;
 SCE_NET_CTL_INFO_RSSI_DBM         = 8;
 SCE_NET_CTL_INFO_RSSI_PERCENTAGE  = 9;
 SCE_NET_CTL_INFO_CHANNEL          =10;
 SCE_NET_CTL_INFO_IP_CONFIG        =11;
 SCE_NET_CTL_INFO_DHCP_HOSTNAME    =12;
 SCE_NET_CTL_INFO_PPPOE_AUTH_NAME  =13;
 SCE_NET_CTL_INFO_IP_ADDRESS       =14;
 SCE_NET_CTL_INFO_NETMASK          =15;
 SCE_NET_CTL_INFO_DEFAULT_ROUTE    =16;
 SCE_NET_CTL_INFO_PRIMARY_DNS      =17;
 SCE_NET_CTL_INFO_SECONDARY_DNS    =18;
 SCE_NET_CTL_INFO_HTTP_PROXY_CONFIG=19;
 SCE_NET_CTL_INFO_HTTP_PROXY_SERVER=20;
 SCE_NET_CTL_INFO_HTTP_PROXY_PORT  =21;
 SCE_NET_CTL_INFO_RESERVED1        =22;
 SCE_NET_CTL_INFO_RESERVED2        =23;

function ps4_sceNetCtlGetState(state:PInteger):Integer; SysV_ABI_CDecl;
begin
 if (state=nil) then Exit(SCE_NET_CTL_ERROR_INVALID_ADDR);
 state^:=SCE_NET_CTL_STATE_DISCONNECTED;
 Result:=0;
end;

type
 SceNetCtlCallback=Procedure(eventType:Integer;arg:Pointer); SysV_ABI_CDecl;

var
 NetCtlCb:packed record
  func:SceNetCtlCallback;
  arg:Pointer;
 end;

function ps4_sceNetCtlRegisterCallback(func:SceNetCtlCallback;arg:Pointer;cid:PInteger):Integer; SysV_ABI_CDecl;
begin
 NetCtlCb.func:=func;
 NetCtlCb.arg:=arg;
 if (cid<>nil) then cid^:=0;
 Result:=0;
end;

function ps4_sceNetCtlCheckCallback():Integer; SysV_ABI_CDecl;
begin
 if (NetCtlCb.func<>nil) then
 begin
  //NetCtlCb.func(SCE_NET_CTL_EVENT_TYPE_DISCONNECTED,NetCtlCb.arg);
 end;
 Result:=0;
end;

function ps4_sceNetCtlGetResult(eventType:Integer;errorCode:PInteger):Integer; SysV_ABI_CDecl;
begin
 if (errorCode=nil) then Exit(SCE_NET_CTL_ERROR_INVALID_ADDR);
 errorCode^:=SCE_NET_CTL_ERROR_ETHERNET_PLUGOUT;
 Result:=0;
end;

type
 pSceNetCtlNatInfo=^SceNetCtlNatInfo;
 SceNetCtlNatInfo=packed record
  size:Integer;
  stunStatus:Integer;
  natType:Integer;
  mappedAddr:SceNetInAddr;
 end;

const
 SCE_NET_CTL_NATINFO_STUN_UNCHECKED=0;
 SCE_NET_CTL_NATINFO_STUN_FAILED   =1;
 SCE_NET_CTL_NATINFO_STUN_OK       =2;

 SCE_NET_CTL_NATINFO_NAT_TYPE_1    =1;
 SCE_NET_CTL_NATINFO_NAT_TYPE_2    =2;
 SCE_NET_CTL_NATINFO_NAT_TYPE_3    =3;


function ps4_sceNetCtlGetNatInfo(natInfo:pSceNetCtlNatInfo):Integer; SysV_ABI_CDecl;
begin
 if (natInfo=nil) then Exit(SCE_NET_CTL_ERROR_INVALID_ADDR);
 if (natInfo^.size<>SizeOf(SceNetCtlNatInfo)) then Exit(SCE_NET_CTL_ERROR_INVALID_SIZE);

 natInfo^.stunStatus:=SCE_NET_CTL_NATINFO_STUN_FAILED;
 natInfo^.natType:=SCE_NET_CTL_NATINFO_NAT_TYPE_1;

 Result:=0;
end;

const
 SCE_NET_CTL_SSID_LEN         =(32 + 1);
 SCE_NET_CTL_HOSTNAME_LEN     =(255 + 1);
 SCE_NET_CTL_AUTH_NAME_LEN    =(127 + 1);
 SCE_NET_CTL_IPV4_ADDR_STR_LEN=(16);

type
 pSceNetCtlInfo=^SceNetCtlInfo;
 SceNetCtlInfo=packed record
  Case Byte of
    0:(device:DWORD);
    1:(ether_addr:SceNetEtherAddr);
    2:(mtu:DWORD);
    3:(link:DWORD);
    4:(bssid:SceNetEtherAddr);
    5:(ssid:array[0..SCE_NET_CTL_SSID_LEN-1] of Char);
    6:(wifi_security:DWORD);
    7:(rssi_dbm:Byte);
    8:(rssi_percentage:Byte);
    9:(channel:Byte);
   10:(ip_config:DWORD);
   11:(dhcp_hostname:array[0..SCE_NET_CTL_HOSTNAME_LEN-1] of Char);
   12:(pppoe_auth_name:array[0..SCE_NET_CTL_AUTH_NAME_LEN-1] of Char);
   13:(ip_address:array[0..SCE_NET_CTL_IPV4_ADDR_STR_LEN-1] of Char);
   14:(netmask:array[0..SCE_NET_CTL_IPV4_ADDR_STR_LEN-1] of Char);
   15:(default_route:array[0..SCE_NET_CTL_IPV4_ADDR_STR_LEN-1] of Char);
   16:(primary_dns:array[0..SCE_NET_CTL_IPV4_ADDR_STR_LEN-1] of Char);
   17:(secondary_dns:array[0..SCE_NET_CTL_IPV4_ADDR_STR_LEN-1] of Char);
   18:(http_proxy_config:DWORD);
   19:(http_proxy_server:array[0..SCE_NET_CTL_HOSTNAME_LEN-1] of Char);
   20:(http_proxy_port:WORD);
 end;


function ps4_sceNetCtlGetInfo(code:Integer;info:pSceNetCtlInfo):Integer; SysV_ABI_CDecl;
begin
 if (info=nil) then Exit(SCE_NET_CTL_ERROR_INVALID_ADDR);

 Result:=SCE_NET_CTL_ERROR_NOT_CONNECTED;

 case code of
  SCE_NET_CTL_INFO_DEVICE           :FillChar(info^,SizeOf(SceNetCtlInfo.device           ),0);
  SCE_NET_CTL_INFO_ETHER_ADDR       :FillChar(info^,SizeOf(SceNetCtlInfo.ether_addr       ),0);
  SCE_NET_CTL_INFO_MTU              :FillChar(info^,SizeOf(SceNetCtlInfo.mtu              ),0);
  SCE_NET_CTL_INFO_LINK             :FillChar(info^,SizeOf(SceNetCtlInfo.link             ),0);
  SCE_NET_CTL_INFO_BSSID            :FillChar(info^,SizeOf(SceNetCtlInfo.bssid            ),0);
  SCE_NET_CTL_INFO_SSID             :FillChar(info^,SizeOf(SceNetCtlInfo.ssid             ),0);
  SCE_NET_CTL_INFO_WIFI_SECURITY    :FillChar(info^,SizeOf(SceNetCtlInfo.wifi_security    ),0);
  SCE_NET_CTL_INFO_RSSI_DBM         :FillChar(info^,SizeOf(SceNetCtlInfo.rssi_dbm         ),0);
  SCE_NET_CTL_INFO_RSSI_PERCENTAGE  :FillChar(info^,SizeOf(SceNetCtlInfo.rssi_percentage  ),0);
  SCE_NET_CTL_INFO_CHANNEL          :FillChar(info^,SizeOf(SceNetCtlInfo.channel          ),0);
  SCE_NET_CTL_INFO_IP_CONFIG        :FillChar(info^,SizeOf(SceNetCtlInfo.ip_config        ),0);
  SCE_NET_CTL_INFO_DHCP_HOSTNAME    :FillChar(info^,SizeOf(SceNetCtlInfo.dhcp_hostname    ),0);
  SCE_NET_CTL_INFO_PPPOE_AUTH_NAME  :FillChar(info^,SizeOf(SceNetCtlInfo.pppoe_auth_name  ),0);
  SCE_NET_CTL_INFO_IP_ADDRESS       :FillChar(info^,SizeOf(SceNetCtlInfo.ip_address       ),0);
  SCE_NET_CTL_INFO_NETMASK          :FillChar(info^,SizeOf(SceNetCtlInfo.netmask          ),0);
  SCE_NET_CTL_INFO_DEFAULT_ROUTE    :FillChar(info^,SizeOf(SceNetCtlInfo.default_route    ),0);
  SCE_NET_CTL_INFO_PRIMARY_DNS      :FillChar(info^,SizeOf(SceNetCtlInfo.primary_dns      ),0);
  SCE_NET_CTL_INFO_SECONDARY_DNS    :FillChar(info^,SizeOf(SceNetCtlInfo.secondary_dns    ),0);
  SCE_NET_CTL_INFO_HTTP_PROXY_CONFIG:FillChar(info^,SizeOf(SceNetCtlInfo.http_proxy_config),0);
  SCE_NET_CTL_INFO_HTTP_PROXY_SERVER:FillChar(info^,SizeOf(SceNetCtlInfo.http_proxy_server),0);
  SCE_NET_CTL_INFO_HTTP_PROXY_PORT  :FillChar(info^,SizeOf(SceNetCtlInfo.http_proxy_port  ),0);
  else
   Exit(SCE_NET_CTL_ERROR_INVALID_CODE);
 end;

 case code of
  SCE_NET_CTL_INFO_DEVICE           :Writeln('SCE_NET_CTL_INFO_DEVICE           ');
  SCE_NET_CTL_INFO_ETHER_ADDR       :Writeln('SCE_NET_CTL_INFO_ETHER_ADDR       ');
  SCE_NET_CTL_INFO_MTU              :Writeln('SCE_NET_CTL_INFO_MTU              ');
  SCE_NET_CTL_INFO_LINK             :Writeln('SCE_NET_CTL_INFO_LINK             ');
  SCE_NET_CTL_INFO_BSSID            :Writeln('SCE_NET_CTL_INFO_BSSID            ');
  SCE_NET_CTL_INFO_SSID             :Writeln('SCE_NET_CTL_INFO_SSID             ');
  SCE_NET_CTL_INFO_WIFI_SECURITY    :Writeln('SCE_NET_CTL_INFO_WIFI_SECURITY    ');
  SCE_NET_CTL_INFO_RSSI_DBM         :Writeln('SCE_NET_CTL_INFO_RSSI_DBM         ');
  SCE_NET_CTL_INFO_RSSI_PERCENTAGE  :Writeln('SCE_NET_CTL_INFO_RSSI_PERCENTAGE  ');
  SCE_NET_CTL_INFO_CHANNEL          :Writeln('SCE_NET_CTL_INFO_CHANNEL          ');
  SCE_NET_CTL_INFO_IP_CONFIG        :Writeln('SCE_NET_CTL_INFO_IP_CONFIG        ');
  SCE_NET_CTL_INFO_DHCP_HOSTNAME    :Writeln('SCE_NET_CTL_INFO_DHCP_HOSTNAME    ');
  SCE_NET_CTL_INFO_PPPOE_AUTH_NAME  :Writeln('SCE_NET_CTL_INFO_PPPOE_AUTH_NAME  ');
  SCE_NET_CTL_INFO_IP_ADDRESS       :Writeln('SCE_NET_CTL_INFO_IP_ADDRESS       ');
  SCE_NET_CTL_INFO_NETMASK          :Writeln('SCE_NET_CTL_INFO_NETMASK          ');
  SCE_NET_CTL_INFO_DEFAULT_ROUTE    :Writeln('SCE_NET_CTL_INFO_DEFAULT_ROUTE    ');
  SCE_NET_CTL_INFO_PRIMARY_DNS      :Writeln('SCE_NET_CTL_INFO_PRIMARY_DNS      ');
  SCE_NET_CTL_INFO_SECONDARY_DNS    :Writeln('SCE_NET_CTL_INFO_SECONDARY_DNS    ');
  SCE_NET_CTL_INFO_HTTP_PROXY_CONFIG:Writeln('SCE_NET_CTL_INFO_HTTP_PROXY_CONFIG');
  SCE_NET_CTL_INFO_HTTP_PROXY_SERVER:Writeln('SCE_NET_CTL_INFO_HTTP_PROXY_SERVER');
  SCE_NET_CTL_INFO_HTTP_PROXY_PORT  :Writeln('SCE_NET_CTL_INFO_HTTP_PROXY_PORT  ');
  else;
 end;

end;

function ps4_sceNetCtlRegisterCallbackForNpToolkit(func:SceNetCtlCallback;arg:Pointer;cid:PInteger):Integer; SysV_ABI_CDecl;
begin
 NetCtlCb.func:=func;
 NetCtlCb.arg:=arg;
 if (cid<>nil) then cid^:=0;
 Result:=0;
end;

function ps4_sceNetCtlCheckCallbackForNpToolkit():Integer; SysV_ABI_CDecl;
begin
 if (NetCtlCb.func<>nil) then
 begin
  //NetCtlCb.func(SCE_NET_CTL_EVENT_TYPE_DISCONNECTED,NetCtlCb.arg);
 end;
 Result:=0;
end;

function Load_libSceNet(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;
 lib:=Result._add_lib('libSceNet');
 lib^.set_proc($3657AFECB83C9370,@ps4_sceNetInit);
 lib^.set_proc($7131A473AFD30652,@ps4_sceNetTerm);
 lib^.set_proc($76024169E2671A9A,@ps4_sceNetPoolCreate);
 lib^.set_proc($2BB465AD3908FE6C,@ps4_sceNetPoolDestroy);
 lib^.set_proc($0B85200C71CFBDDC,@ps4_sceNetResolverCreate);
 lib^.set_proc($F0A729E5DFEAD54A,@ps4_sceNetInetPton);
 lib^.set_proc($BFA338B7179C0AEA,@ps4_sceNetEtherNtostr);
 lib^.set_proc($E8E7346CBB0861ED,@ps4_sceNetGetMacAddress);
end;

function Load_libSceNetCtl(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;
 lib:=Result._add_lib('libSceNetCtl');
 lib^.set_proc($824CB4FA868D3389,@ps4_sceNetCtlInit);
 lib^.set_proc($B813E5AF495BBA22,@ps4_sceNetCtlGetState);
 lib^.set_proc($509F99ED0FB8724D,@ps4_sceNetCtlRegisterCallback);
 lib^.set_proc($890C378903E1BD44,@ps4_sceNetCtlCheckCallback);
 lib^.set_proc($D1C06076E3D147E3,@ps4_sceNetCtlGetResult);
 lib^.set_proc($24EE32B93B8CA0A2,@ps4_sceNetCtlGetNatInfo);
 lib^.set_proc($A1BBB17538B0905F,@ps4_sceNetCtlGetInfo);

 lib:=Result._add_lib('libSceNetCtlForNpToolkit');

 lib^.set_proc($C08B0ACBE4DF78BB,@ps4_sceNetCtlRegisterCallbackForNpToolkit);
 lib^.set_proc($BB9A2AB6520FF85C,@ps4_sceNetCtlCheckCallbackForNpToolkit);
end;

initialization
 ps4_app.RegistredPreLoad('libSceNet.prx'   ,@Load_libSceNet);
 ps4_app.RegistredPreLoad('libSceNetCtl.prx',@Load_libSceNetCtl);

end.

