unit vDevice;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  Math,
  atomic,
  spinlock,
  Vulkan;

type
 TVulkanApp=class
  FInstance:TVkInstance;
  FPhysicalDevice:TVkPhysicalDevice;
  //
  FGFamily:TVkUInt32;
  FCFamily:TVkUInt32;
  FTFamily:TVkUInt32;
  //
  FGFamilyCount:TVkUInt32;
  FCFamilyCount:TVkUInt32;
  FTFamilyCount:TVkUInt32;
  //
  FDeviceFeature:TVkPhysicalDeviceFeatures;
  Constructor Create(debug,printf,validate:Boolean);
  Destructor  Destroy; override;
  Procedure   LoadFamily; virtual;
  function    InstanceLayersIsExist(P:PChar):Boolean;
 end;

 TvDebugReport=class
  FHandle:TVkDebugReportCallbackEXT;
  FCreateDebugReportCallback:TvkCreateDebugReportCallbackEXT;
  FDestroyDebugReportCallback:TvkDestroyDebugReportCallbackEXT;
  Constructor Create;
  Destructor  Destroy; override;
  procedure   ReportCallback(flags:TVkDebugReportFlagsEXT;
                             objectType:TVkDebugReportObjectTypeEXT;
                             object_:TVkUInt64;
                             location:DWORD;
                             pLayerPrefix:PVkChar;
                             pMessage:PVkChar); virtual;
 end;

 TvSurface=class
  FHandle:TVkSurfaceKHR;
  FPFamily:TVkUInt32;
  Fformat:TVkSurfaceFormatKHR;
  FModes:array[0..2] of TVkPresentModeKHR;
  Constructor Create(Handle:THandle);
  Destructor  Destroy; override;
  Procedure   LoadFamily; virtual;
  Procedure   LoadFormat; virtual;
  Procedure   LoadModes; virtual;
  function    GetSize:TVkExtent2D; virtual;
 end;

 TSortQueueRec=record
  FIndex:TVkUInt32;
  pQueue:PVkQueue;
 end;

 PAbstractFeature=^TAbstractFeature;
 TAbstractFeature=record
  sType:TVkStructureType;
  pNext:PVkVoid;
 end;

 TvDeviceQueues=class
  data:array of TSortQueueRec;
  exts:array of Pchar;
  pFeature:PVkVoid;
  procedure   add_queue(Index:TVkUInt32;Queue:PVkQueue);
  procedure   add_ext(P:Pchar);
  procedure   add_feature(P:PVkVoid);
 end;

 TvDevice=class
  FHandle:TVkDevice;
  Constructor Create(Queues:TvDeviceQueues);
  Destructor  Destroy; override;
 end;

 TvQueue=class
  FHandle:TVkQueue;
  FLock:Pointer;
  function QueueSubmit(submitCount:TVkUInt32;const pSubmits:PVkSubmitInfo;fence:TVkFence):TVkResult;
  function QueueWaitIdle:TVkResult;
  function QueuePresentKHR(const pPresentInfo:PVkPresentInfoKHR):TVkResult;
 end;

 TvCmdPool=class
  FHandle:TVkCommandPool;
  Constructor Create(FFamily:TVkUInt32);
  Destructor  Destroy; override;
  function    Alloc:TVkCommandBuffer;
  procedure   Free(cmd:TVkCommandBuffer);
 end;

 TvFence=class
  FHandle:TVkFence;
  Constructor Create(signaled:Boolean);
  Destructor  Destroy; override;
  function    Reset:TVkResult;
  function    Wait(timeout:TVkUInt64):TVkResult;
  function    Status:TVkResult;
 end;

 TvSemaphore=class
  FHandle:TVkSemaphore;
  Constructor Create;
  Destructor  Destroy; override;
 end;

 TvEvent=class
  FHandle:TVkEvent;
  Constructor Create;
  Destructor  Destroy; override;
  function    SetEvent:TVkResult;
  function    ResetEvent:TVkResult;
  function    Status:TVkResult;
 end;

procedure PrintInstanceExtension;
procedure PrintDeviceExtension(physicalDevice:TVkPhysicalDevice);
procedure PrintQueueFamily(physicalDevice:TVkPhysicalDevice);

const
 SubresColor:TVkImageSubresourceRange=(
  aspectMask:TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  baseMipLevel:0;
  levelCount:1;
  baseArrayLayer:0;
  layerCount:1
 );

procedure vkImageMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   image:TVkImage;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
	   oldImageLayout:TVkImageLayout;
	   newImageLayout:TVkImageLayout;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags;
	   subresourceRange:TVkImageSubresourceRange);

procedure vkBufferMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   buffer:TVkBuffer;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
           offset,size:TVkDeviceSize;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);

procedure vkMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);

procedure vkBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);

var
 VulkanApp:TVulkanApp;
 DebugReport:TVDebugReport;
 Device:TvDevice;

 FlipQueue:TvQueue;
 RenderQueue:TvQueue;

Procedure InitVulkan;
function  IsInitVulkan:Boolean;

function  shaderStorageImageExtendedFormats:Boolean;
function  shaderStorageImageReadWithoutFormat:Boolean;
function  shaderStorageImageWriteWithoutFormat:Boolean;
function  shaderInt64:Boolean;
function  shaderInt16:Boolean;

var
 limits:record

  VK_KHR_swapchain               :Boolean;
  VK_EXT_external_memory_host    :Boolean;

  VK_KHR_16bit_storage           :Boolean;
  VK_KHR_8bit_storage            :Boolean;
  VK_KHR_push_descriptor         :Boolean;
  VK_KHR_shader_non_semantic_info:Boolean;
  VK_EXT_index_type_uint8        :Boolean;
  VK_EXT_scalar_block_layout     :Boolean;

  VK_AMD_device_coherent_memory  :Boolean;

  maxUniformBufferRange:TVkUInt32;
  maxStorageBufferRange:TVkUInt32;
  maxPushConstantsSize:TVkUInt32;
  maxSamplerLodBias:TVkFloat;
  maxSamplerAnisotropy:TVkFloat;

  minMemoryMapAlignment:TVkSize;
  minTexelBufferOffsetAlignment:TVkDeviceSize;
  minUniformBufferOffsetAlignment:TVkDeviceSize;
  minStorageBufferOffsetAlignment:TVkDeviceSize;

  framebufferColorSampleCounts:TVkSampleCountFlags;
  framebufferDepthSampleCounts:TVkSampleCountFlags;
  framebufferStencilSampleCounts:TVkSampleCountFlags;

  sampledImageColorSampleCounts:TVkSampleCountFlags;
  sampledImageIntegerSampleCounts:TVkSampleCountFlags;
  sampledImageDepthSampleCounts:TVkSampleCountFlags;
  sampledImageStencilSampleCounts:TVkSampleCountFlags;
  storageImageSampleCounts:TVkSampleCountFlags;

  maxComputeWorkGroupInvocations:TVkUInt32;
  maxComputeWorkGroupSize:TVkOffset3D;

  minImportedHostPointerAlignment:TVkDeviceSize;
 end;

implementation

uses
 vMemory;

function shaderStorageImageExtendedFormats:Boolean;
begin
 Result:=Boolean(VulkanApp.FDeviceFeature.shaderStorageImageExtendedFormats);
end;

function shaderStorageImageReadWithoutFormat:Boolean;
begin
 Result:=Boolean(VulkanApp.FDeviceFeature.shaderStorageImageReadWithoutFormat);
end;

function shaderStorageImageWriteWithoutFormat:Boolean;
begin
 Result:=Boolean(VulkanApp.FDeviceFeature.shaderStorageImageWriteWithoutFormat);
end;

function shaderInt64:Boolean;
begin
 Result:=Boolean(VulkanApp.FDeviceFeature.shaderInt64);
end;

function shaderInt16:Boolean;
begin
 Result:=Boolean(VulkanApp.FDeviceFeature.shaderInt16);
end;

procedure FillDeviceProperties(physicalDevice:TVkPhysicalDevice);
var
 prop:TVkPhysicalDeviceProperties2;
 memh:TVkPhysicalDeviceExternalMemoryHostPropertiesEXT;
begin
 prop:=Default(TVkPhysicalDeviceProperties2);
 prop.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
 prop.pNext:=@memh;

 memh:=Default(TVkPhysicalDeviceExternalMemoryHostPropertiesEXT);
 memh.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_HOST_PROPERTIES_EXT;

 vkGetPhysicalDeviceProperties2(physicalDevice,@prop);

 limits.maxUniformBufferRange          :=prop.properties.limits.maxUniformBufferRange;
 limits.maxStorageBufferRange          :=prop.properties.limits.maxStorageBufferRange;
 limits.maxPushConstantsSize           :=prop.properties.limits.maxPushConstantsSize;
 limits.maxSamplerLodBias              :=prop.properties.limits.maxSamplerLodBias;
 limits.maxSamplerAnisotropy           :=prop.properties.limits.maxSamplerAnisotropy;

 limits.minMemoryMapAlignment          :=prop.properties.limits.minMemoryMapAlignment;
 limits.minTexelBufferOffsetAlignment  :=prop.properties.limits.minTexelBufferOffsetAlignment;
 limits.minUniformBufferOffsetAlignment:=prop.properties.limits.minUniformBufferOffsetAlignment;
 limits.minStorageBufferOffsetAlignment:=prop.properties.limits.minStorageBufferOffsetAlignment;

 limits.framebufferColorSampleCounts   :=prop.properties.limits.framebufferColorSampleCounts;
 limits.framebufferDepthSampleCounts   :=prop.properties.limits.framebufferDepthSampleCounts;
 limits.framebufferStencilSampleCounts :=prop.properties.limits.framebufferStencilSampleCounts;

 limits.sampledImageColorSampleCounts  :=prop.properties.limits.sampledImageColorSampleCounts;
 limits.sampledImageIntegerSampleCounts:=prop.properties.limits.sampledImageIntegerSampleCounts;
 limits.sampledImageDepthSampleCounts  :=prop.properties.limits.sampledImageDepthSampleCounts;
 limits.sampledImageStencilSampleCounts:=prop.properties.limits.sampledImageStencilSampleCounts;
 limits.storageImageSampleCounts       :=prop.properties.limits.storageImageSampleCounts;

 limits.maxComputeWorkGroupInvocations :=prop.properties.limits.maxComputeWorkGroupInvocations;
 limits.maxComputeWorkGroupSize        :=TVkOffset3D(prop.properties.limits.maxComputeWorkGroupSize);

 limits.minImportedHostPointerAlignment:=memh.minImportedHostPointerAlignment;
end;

procedure FillDeviceExtension(physicalDevice:TVkPhysicalDevice);
var
 i,count:TVkUInt32;
 pProperties:PVkExtensionProperties;
begin
 Writeln;
 count:=0;
 vkEnumerateDeviceExtensionProperties(physicalDevice,nil,@count,nil);
 if (count<>0) then
 begin
  pProperties:=GetMem(count*SizeOf(TVkExtensionProperties));
  vkEnumerateDeviceExtensionProperties(physicalDevice,nil,@count,pProperties);
  For i:=0 to count-1 do
  begin
   Case String(pProperties[i].extensionName) of
    VK_KHR_SWAPCHAIN_EXTENSION_NAME               :limits.VK_KHR_swapchain               :=True;
    VK_EXT_EXTERNAL_MEMORY_HOST_EXTENSION_NAME    :limits.VK_EXT_external_memory_host    :=True;
    VK_KHR_16BIT_STORAGE_EXTENSION_NAME           :limits.VK_KHR_16bit_storage           :=True;
    VK_KHR_8BIT_STORAGE_EXTENSION_NAME            :limits.VK_KHR_8bit_storage            :=True;
    VK_KHR_PUSH_DESCRIPTOR_EXTENSION_NAME         :limits.VK_KHR_push_descriptor         :=True;
    VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME:limits.VK_KHR_shader_non_semantic_info:=True;
    VK_EXT_INDEX_TYPE_UINT8_EXTENSION_NAME        :limits.VK_EXT_index_type_uint8        :=True;
    VK_EXT_SCALAR_BLOCK_LAYOUT_EXTENSION_NAME     :limits.VK_EXT_scalar_block_layout     :=True;

    VK_AMD_DEVICE_COHERENT_MEMORY_EXTENSION_NAME  :limits.VK_AMD_device_coherent_memory  :=True;
   end;
  end;
  FreeMem(pProperties);
 end;
end;

type
 TSortIndex=object
  max:Integer;
  data:array of TVkDeviceQueueCreateInfo;
  procedure add(Index:TVkUInt32);
 end;

procedure PrintInstanceExtension;
var
 i,count:TVkUInt32;
 pProperties:PVkExtensionProperties;
begin
 Writeln;
 count:=0;
 vkEnumerateInstanceExtensionProperties(nil,@count,nil);
 if (count<>0) then
 begin
  pProperties:=GetMem(count*SizeOf(TVkExtensionProperties));
  vkEnumerateInstanceExtensionProperties(nil,@count,pProperties);
  For i:=0 to count-1 do
  begin
   Writeln(pProperties[i].extensionName);
  end;
  FreeMem(pProperties);
 end;
end;

procedure PrintDeviceExtension(physicalDevice:TVkPhysicalDevice);
var
 i,count:TVkUInt32;
 pProperties:PVkExtensionProperties;
begin
 Writeln;
 count:=0;
 vkEnumerateDeviceExtensionProperties(physicalDevice,nil,@count,nil);
 if (count<>0) then
 begin
  pProperties:=GetMem(count*SizeOf(TVkExtensionProperties));
  vkEnumerateDeviceExtensionProperties(physicalDevice,nil,@count,pProperties);
  For i:=0 to count-1 do
  begin
   Writeln(pProperties[i].extensionName);
  end;
  FreeMem(pProperties);
 end;
end;

function getstr_queueFlags(queueFlags:TVkQueueFlags):RawByteString;
begin
 Result:='';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_GRAPHICS_BIT))<>0 then
  Result:=Result+' GRAPHICS';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_COMPUTE_BIT))<>0 then
  Result:=Result+' COMPUTE';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_TRANSFER_BIT))<>0 then
  Result:=Result+' TRANSFER';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_SPARSE_BINDING_BIT))<>0 then
  Result:=Result+' SPARSE_BINDING';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_PROTECTED_BIT))<>0 then
  Result:=Result+' PROTECTED';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_VIDEO_DECODE_BIT_KHR))<>0 then
  Result:=Result+' VIDEO_DECODE';
 if (queueFlags and TVkQueueFlags(VK_QUEUE_VIDEO_ENCODE_BIT_KHR))<>0 then
  Result:=Result+' VIDEO_ENCODE';
end;

procedure PrintQueueFamily(physicalDevice:TVkPhysicalDevice);
var
 i,count:TVkUInt32;
 pFamily:PVkQueueFamilyProperties;
begin
 count:=0;
 vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice,@count,nil);
 if (count=0) then Exit;

 pFamily:=GetMem(count*SizeOf(TVkQueueFamilyProperties));
 vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice,@count,pFamily);

 For i:=0 to count-1 do
 begin
  Write(getstr_queueFlags(pFamily[i].queueFlags));
  Writeln(':',pFamily[i].queueCount);
 end;

 FreeMem(pFamily);
end;

function MyDebugReportCallback(flags:TVkDebugReportFlagsEXT;
                               objectType:TVkDebugReportObjectTypeEXT;
                               object_:TVkUInt64;
                               location:TVkSize;
                               messageCode:TVkInt32;
                               const pLayerPrefix:PVkChar;
                               const pMessage:PVkChar;
                               pUserData:PVkVoid):TVkBool32; {$ifdef Windows}stdcall;{$else}{$ifdef Android}{$ifdef cpuarm}hardfloat;{$else}cdecl;{$endif}{$else}cdecl;{$endif}{$endif}
begin
 TVDebugReport(pUserData).ReportCallback(
   flags,objectType,object_,location,pLayerPrefix,pMessage);
 Result:=TVkBool32(False);
end;

Constructor TVDebugReport.Create;
var
 cinfo:TVkDebugReportCallbackCreateInfoEXT;
 r:TVkResult;
begin

 TPFN_vkVoidFunction(FCreateDebugReportCallback) :=vkGetInstanceProcAddr(VulkanApp.FInstance,'vkCreateDebugReportCallbackEXT');
 TPFN_vkVoidFunction(FDestroyDebugReportCallback):=vkGetInstanceProcAddr(VulkanApp.FInstance,'vkDestroyDebugReportCallbackEXT');

 if (FCreateDebugReportCallback<>nil) then
 begin
  cinfo:=Default(TVkDebugReportCallbackCreateInfoEXT);
  cinfo.sType:=VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT;
  cinfo.flags:=
                            ord(VK_DEBUG_REPORT_INFORMATION_BIT_EXT        ) or
                            ord(VK_DEBUG_REPORT_WARNING_BIT_EXT            ) or
                            ord(VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT) or
                            ord(VK_DEBUG_REPORT_ERROR_BIT_EXT              ){ or
                            ord(VK_DEBUG_REPORT_DEBUG_BIT_EXT              )};




  cinfo.pfnCallback:=@MyDebugReportCallback;
  cinfo.pUserData:=Pointer(Self);
  r:=FCreateDebugReportCallback(VulkanApp.FInstance,@cinfo,nil,@FHandle);
  if (r<>VK_SUCCESS) then
  begin
   Writeln('CreateDebugReportCallback:',r);
   Exit;
  end;
 end;
end;

Destructor TVDebugReport.Destroy;
begin
 if (FDestroyDebugReportCallback<>nil) then
 begin
  FDestroyDebugReportCallback(VulkanApp.FInstance,FHandle,nil);
 end;
end;

procedure TVDebugReport.ReportCallback(flags:TVkDebugReportFlagsEXT;
                           objectType:TVkDebugReportObjectTypeEXT;
                           object_:TVkUInt64;
                           location:DWORD;
                           pLayerPrefix:PVkChar;
                           pMessage:PVkChar);
var
 i:Integer;
begin

 Case objectType of

  VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT:
   Case DWORD(location) of
    $0609A13B:
     begin
      if Pos('not consumed by fragment shader',pMessage)<>0 then Exit;
      if Pos('fragment shader writes to output location 0 with no matching attachment',pMessage)<>0 then Exit;
     end;
   end;

  VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_EXT:
   Case DWORD(location) of

    $A7BB8DB6:if Pos('(Float16)',pMessage)<>0 then Exit;

    $92394C89:
     begin
      i:=Pos('|',pMessage);
      if (i<>0) then
      begin
       pMessage:=@pMessage[i];
       i:=Pos('|',pMessage);
       if (i<>0) then
       begin
        pMessage:=@pMessage[i-1];
       end;
      end;
     end;

    else;
   end;
  else;
 end;

 Writeln(pMessage);

end;

function vkGetPhysicalDevice4Type(pPhysicalDevices:PVkPhysicalDevice;count:TVkUInt32;deviceType:TVkPhysicalDeviceType):TVkPhysicalDevice;
var
 i:TVkUInt32;
 deviceProperties:TVkPhysicalDeviceProperties;
begin
 Result:=VK_NULL_HANDLE;
 if (count<>0) then
 For i:=0 to count-1 do
 begin
  deviceProperties:=Default(TVkPhysicalDeviceProperties);
  vkGetPhysicalDeviceProperties(pPhysicalDevices[i],@deviceProperties);
  if (deviceProperties.deviceType=deviceType) then Exit(pPhysicalDevices[i]);
 end;
end;

function vkGetPhysicalDevice(vkInstance:TVkInstance):TVkPhysicalDevice;
var
 i,count:TVkUInt32;
 pPhysicalDevices:PVkPhysicalDevice;
 deviceProperties:TVkPhysicalDeviceProperties;
begin
 Result:=VK_NULL_HANDLE;
 count:=0;
 vkEnumeratePhysicalDevices(vkInstance,@count,nil);
 if (count=0) then Exit;
 pPhysicalDevices:=GetMem(count*SizeOf(TVkPhysicalDevice));
 vkEnumeratePhysicalDevices(vkInstance,@count,pPhysicalDevices);
 For i:=0 to count-1 do
 begin
  deviceProperties:=Default(TVkPhysicalDeviceProperties);
  vkGetPhysicalDeviceProperties(pPhysicalDevices[i],@deviceProperties);
  Writeln(deviceProperties.deviceName);
  Writeln('apiVersion:',VK_VERSION_MAJOR(deviceProperties.apiVersion),'.',
                        VK_VERSION_MINOR(deviceProperties.apiVersion),'.',
                        VK_VERSION_PATCH(deviceProperties.apiVersion));
  Writeln('-----------');
 end;
 Result:=vkGetPhysicalDevice4Type(pPhysicalDevices,count,VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU);
 if (Result=VK_NULL_HANDLE) then
 begin
  Result:=vkGetPhysicalDevice4Type(pPhysicalDevices,count,VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU);
 end;
 if (Result=VK_NULL_HANDLE) then
 begin
  Result:=pPhysicalDevices[0];
 end;
 FreeMem(pPhysicalDevices);

 Writeln('Select GPU:');
 deviceProperties:=Default(TVkPhysicalDeviceProperties);
 vkGetPhysicalDeviceProperties(Result,@deviceProperties);
 Writeln(deviceProperties.deviceName);
 Writeln('apiVersion:',VK_VERSION_MAJOR(deviceProperties.apiVersion),'.',
                       VK_VERSION_MINOR(deviceProperties.apiVersion),'.',
                       VK_VERSION_PATCH(deviceProperties.apiVersion));

end;

function VK_MAKE_API_VERSION(const variant,major,minor,patch:longint):longint;
begin
 result:=(variant shl 29) or (major shl 22) or (minor shl 12) or (patch);
end;

Constructor TVulkanApp.Create(debug,printf,validate:Boolean);
const
 dlayer='VK_LAYER_KHRONOS_validation';
var
 vkApp:TVkApplicationInfo;
 vkExtList:array[0..2] of PChar;
 vkLayer:array[0..0] of PChar;
 vkCInfo:TVkInstanceCreateInfo;
 vkPrintf:TVkValidationFeaturesEXT;
 vkFeature:TVkValidationFeatureEnableEXT;
 r:TVkResult;
begin
 vkApp:=Default(TVkApplicationInfo);
 vkApp.sType             :=VK_STRUCTURE_TYPE_APPLICATION_INFO;
 vkApp.pApplicationName  :='VulkanApp';
 vkApp.applicationVersion:=VK_MAKE_VERSION(1, 0, 0);
 vkApp.pEngineName       :=nil;
 vkApp.engineVersion     :=VK_MAKE_VERSION(1, 0, 0);
 vkApp.apiVersion        :={VK_API_VERSION_1_1;} VK_MAKE_API_VERSION(0, 1, 1, 0);

 vkExtList[0]:=VK_KHR_SURFACE_EXTENSION_NAME;
 vkExtList[1]:=VK_KHR_WIN32_SURFACE_EXTENSION_NAME;
 vkExtList[2]:=VK_EXT_DEBUG_REPORT_EXTENSION_NAME;

 vkCInfo:=Default(TVkInstanceCreateInfo);
 vkCInfo.sType:=VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
 vkCInfo.pApplicationInfo:=@vkApp;
 if debug then
 begin
  vkCInfo.enabledExtensionCount:=Length(vkExtList);
  if validate and InstanceLayersIsExist(dlayer) then
  begin
   vkLayer[0]:=dlayer;
   vkCInfo.enabledLayerCount:=1;
   vkCInfo.ppEnabledLayerNames:=@vkLayer;
  end;
 end else
 begin
  vkCInfo.enabledExtensionCount:=Length(vkExtList)-1;
 end;
 vkCInfo.ppEnabledExtensionNames:=@vkExtList;

 if debug and printf then
 begin
  vkFeature:=VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT;

  vkPrintf:=Default(TVkValidationFeaturesEXT);
  vkPrintf.sType:=VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT;
  vkPrintf.enabledValidationFeatureCount:=1;
  vkPrintf.pEnabledValidationFeatures:=@vkFeature;

  vkCInfo.pNext:=@vkPrintf;;
 end;

 r:=vkCreateInstance(@vkCInfo,nil,@FInstance);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('vkCreateInstance:',r);
  Exit;
 end;

 FPhysicalDevice:=vkGetPhysicalDevice(FInstance);
 if (FPhysicalDevice=VK_NULL_HANDLE) then
 begin
  Writeln('failed to chouse vulkan GPU');
  Exit;
 end;

 FDeviceFeature:=Default(TVkPhysicalDeviceFeatures);
 vkGetPhysicalDeviceFeatures(FPhysicalDevice,@FDeviceFeature);

 LoadFamily;
end;

function TVulkanApp.InstanceLayersIsExist(P:PChar):Boolean;
var
 l1,l2,i,count:TVkUInt32;
 pProperties:PVkLayerProperties;
begin
 Result:=False;
 l1:=StrLen(P);
 count:=0;
 vkEnumerateInstanceLayerProperties(@count,nil);
 if (l1<>0) and (count<>0) then
 begin
  pProperties:=GetMem(count*SizeOf(TVkLayerProperties));
  vkEnumerateInstanceLayerProperties(@count,pProperties);
  For i:=0 to count-1 do
  begin
   l2:=StrLen(pProperties[i].layerName);
   if (l1=l2) and (CompareByte(pProperties[i].layerName,P^,l1)=0) then
   begin
    FreeMem(pProperties);
    Exit(true);
   end;
  end;
  FreeMem(pProperties);
 end;
end;

Destructor TVulkanApp.Destroy;
begin
 vkDestroyInstance(FInstance,nil);
end;

Procedure TVulkanApp.LoadFamily;
var
 i,count:TVkUInt32;
 pQueue:PVkQueueFamilyProperties;
 bLoaded:Set of (gLoad,cLoad,tLoad);
begin
 count:=0;
 vkGetPhysicalDeviceQueueFamilyProperties(FPhysicalDevice,@count,nil);
 if (count=0) then Exit;
 bLoaded:=[];
 pQueue:=GetMem(count*SizeOf(TVkQueueFamilyProperties));
 vkGetPhysicalDeviceQueueFamilyProperties(FPhysicalDevice,@count,pQueue);
 For i:=0 to count-1 do
 begin
  if (pQueue[i].queueFlags and ord(VK_QUEUE_GRAPHICS_BIT))<>0 then
  begin
   if not (gLoad in bLoaded) then
   begin
    FGFamily:=i;
    FGFamilyCount:=pQueue[i].queueCount;
    bLoaded:=bLoaded+[gLoad];
   end;
  end else
  if (pQueue[i].queueFlags and ord(VK_QUEUE_COMPUTE_BIT))<>0 then
  begin
   if not (cLoad in bLoaded) then
   begin
    FCFamily:=i;
    FCFamilyCount:=pQueue[i].queueCount;
    bLoaded:=bLoaded+[cLoad];
   end;
  end else
  if (pQueue[i].queueFlags and ord(VK_QUEUE_TRANSFER_BIT))<>0 then
  begin
   if not (tLoad in bLoaded) then
   begin
    FTFamily:=i;
    FTFamilyCount:=pQueue[i].queueCount;
    bLoaded:=bLoaded+[tLoad];
   end;
  end;
 end;
 if not (cLoad in bLoaded) then
 begin
  For i:=0 to count-1 do
  if (pQueue[i].queueFlags and ord(VK_QUEUE_COMPUTE_BIT))<>0 then
  begin
   FCFamily:=i;
   FCFamilyCount:=pQueue[i].queueCount;
   Break;
  end;
 end;
 if not (tLoad in bLoaded) then
 begin
  For i:=0 to count-1 do
  if (pQueue[i].queueFlags and ord(VK_QUEUE_TRANSFER_BIT))<>0 then
  begin
   FTFamily:=i;
   FTFamilyCount:=pQueue[i].queueCount;
   Break;
  end;
 end;
 FreeMem(pQueue);
end;

function vkGetQueuePresentFamily(physicalDevice:TVkPhysicalDevice;Surface:TVkSurfaceKHR;var Family:TVkUInt32):Boolean;
var
 i,count:TVkUInt32;
 presentSupport:TVkBool32;
begin
 Result:=False;
 count:=0;
 vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice,@count,nil);
 if (count=0) then Exit;
 For i:=0 to count-1 do
 begin
  presentSupport:=ord(false);
  vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice,i,Surface,@presentSupport);
  if boolean(presentSupport) then
  begin
   Family:=i;
   Exit(True);
  end;
 end;
end;

Constructor TVSurface.Create(Handle:THandle);
var
 ci:TVkWin32SurfaceCreateInfoKHR;
 r:TVkResult;
begin
 ci:=Default(TVkWin32SurfaceCreateInfoKHR);
 ci.sType     :=VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
 ci.hwnd_     :=TVkHWND(Handle);
 ci.hinstance_:=System.HINSTANCE;
 r:=vkCreateWin32SurfaceKHR(VulkanApp.FInstance,@ci,nil,@FHandle);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('vkCreateWin32SurfaceKHR:',r);
  Exit;
 end;
 LoadFamily;
 LoadFormat;
 LoadModes;
end;

Destructor TVSurface.Destroy;
begin
 vkDestroySurfaceKHR(VulkanApp.FInstance,FHandle,nil);
end;

Procedure TVSurface.LoadFamily;
begin
 FPFamily:=0;
 if not vkGetQueuePresentFamily(VulkanApp.FPhysicalDevice,FHandle,FPFamily) then
 begin
  Writeln('failed to chouse QueuePresentFamily');
  Exit;
 end;
end;

Procedure TVSurface.LoadFormat;
var
 count:TVkUInt32;
 formats:PVkSurfaceFormatKHR;
 r:TVkResult;

 function TryFind(format:TVkFormat):Boolean;
 var
  i:TVkUInt32;
 begin
  Result:=false;
  For i:=0 to count-1 do
  begin
   if (formats[i].format=format) then
   begin
    Fformat:=formats[i];
    Exit(true);
   end;
  end;
 end;

begin
 count:=0;
 r:=vkGetPhysicalDeviceSurfaceFormatsKHR(VulkanApp.FPhysicalDevice,FHandle,@count,nil);
 if (r=VK_SUCCESS) and (count<>0) then
 begin
  repeat
   formats:=GetMem(count*SizeOf(TVkSurfaceFormatKHR));
   vkGetPhysicalDeviceSurfaceFormatsKHR(VulkanApp.FPhysicalDevice,FHandle,@count,formats);
   if TryFind(VK_FORMAT_R8G8B8A8_SRGB)         then Break;
   if TryFind(VK_FORMAT_B8G8R8A8_SRGB)         then Break;
   if TryFind(VK_FORMAT_A8B8G8R8_SRGB_PACK32)  then Break;
   if TryFind(VK_FORMAT_R8G8B8A8_UNORM)        then Break;
   if TryFind(VK_FORMAT_B8G8R8A8_UNORM)        then Break;
   if TryFind(VK_FORMAT_A8B8G8R8_UNORM_PACK32) then Break;
   if (Fformat.format=VK_FORMAT_UNDEFINED) then
   begin
    Fformat:=formats[0];
   end;
  until true;
  FreeMem(formats);
 end;
end;

Procedure TVSurface.LoadModes;
var
 i,count:TVkUInt32;
 presentModes:PVkPresentModeKHR;
 r:TVkResult;
begin
 count:=0;
 FModes[0]:=VK_PRESENT_MODE_IMMEDIATE_KHR;
 FModes[1]:=VK_PRESENT_MODE_FIFO_KHR;
 FModes[2]:=VK_PRESENT_MODE_FIFO_KHR;
 r:=vkGetPhysicalDeviceSurfacePresentModesKHR(VulkanApp.FPhysicalDevice,FHandle,@count,nil);
 if (r=VK_SUCCESS) and (count<>0) then
 begin
  presentModes:=GetMem(count*SizeOf(TVkPresentModeKHR));
  vkGetPhysicalDeviceSurfacePresentModesKHR(VulkanApp.FPhysicalDevice,FHandle,@count,presentModes);
  For i:=0 to count-1 do
  begin
   if (presentModes[i]=VK_PRESENT_MODE_MAILBOX_KHR) then
   begin
    FModes[2]:=VK_PRESENT_MODE_MAILBOX_KHR;
    Break;
   end;
  end;
  FreeMem(presentModes);
 end;
end;

function TVSurface.GetSize:TVkExtent2D;
var
 Fcap:TVkSurfaceCapabilitiesKHR;
begin
 Fcap:=Default(TVkSurfaceCapabilitiesKHR);
 vkGetPhysicalDeviceSurfaceCapabilitiesKHR(VulkanApp.FPhysicalDevice,FHandle,@Fcap);
 Result:=Fcap.currentExtent;
end;

procedure TvDeviceQueues.add_queue(Index:TVkUInt32;Queue:PVkQueue);
var
 i,count:Integer;
 r:Boolean;
begin
 count:=Length(data);
 if (count<>0) then
 begin
  r:=false;
  For i:=0 to count-1 do
  begin
   if (data[i].FIndex=Index) then
   begin
    r:=true;
   end else
   if r then
   begin
    SetLength(data,count+1);
    Move(data[i],data[i+1],SizeOf(TSortQueueRec)*(count-i));
    data[i].FIndex:=Index;
    data[i].pQueue:=Queue;
    Exit;
   end;
  end;
 end;
 SetLength(data,count+1);
 data[count].FIndex:=Index;
 data[count].pQueue:=Queue;
end;

procedure TvDeviceQueues.add_ext(P:Pchar);
var
 i:Integer;
begin
 i:=Length(exts);
 SetLength(exts,i+1);
 exts[i]:=P;
end;

procedure TvDeviceQueues.add_feature(P:PVkVoid);
begin
 PAbstractFeature(P)^.pNext:=pFeature;
 pFeature:=P;
end;

procedure TSortIndex.add(Index:TVkUInt32);
var
 i,count:Integer;
begin
 count:=Length(data);
 if (count<>0) then
  For i:=0 to count-1 do
   if (data[i].queueFamilyIndex=Index) then
   begin
    Inc(data[i].queueCount);
    if (max<data[i].queueCount) then max:=data[i].queueCount;
    Exit;
   end;
 SetLength(data,count+1);
 data[count]:=Default(TVkDeviceQueueCreateInfo);
 data[count].sType           :=VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
 data[count].queueFamilyIndex:=Index;
 data[count].queueCount      :=1;
 if (max<1) then max:=1;
end;

Constructor TvDevice.Create(Queues:TvDeviceQueues);
Var
 DeviceFeature:TVkPhysicalDeviceFeatures;
 SortIndex:TSortIndex;
 Priority:array of Single;
 DeviceInfo:TVkDeviceCreateInfo;
 r:TVkResult;
 i,p,w:Integer;
begin
 DeviceFeature:=VulkanApp.FDeviceFeature;
 DeviceFeature.robustBufferAccess:=0;

 DeviceInfo:=Default(TVkDeviceCreateInfo);
 DeviceInfo.sType:=VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
 DeviceInfo.pEnabledFeatures:=@DeviceFeature;
 DeviceInfo.pNext:=Queues.pFeature;

 DeviceInfo.enabledExtensionCount:=Length(Queues.exts);
 if (DeviceInfo.enabledExtensionCount<>0) then
 begin
  DeviceInfo.ppEnabledExtensionNames:=@Queues.exts[0];
 end;

 SortIndex:=Default(TSortIndex);
 For i:=0 to Length(Queues.data)-1 do
 begin
  SortIndex.add(Queues.data[i].FIndex);
 end;

 DeviceInfo.queueCreateInfoCount:=Length(SortIndex.data);
 DeviceInfo.pQueueCreateInfos:=@SortIndex.data[0];

 Priority:=nil;
 SetLength(Priority,SortIndex.max);
 For i:=0 to High(Priority) do Priority[i]:=1;

 For i:=0 to High(SortIndex.data) do
 begin
  SortIndex.data[i].pQueuePriorities:=@Priority[0];
 end;

 r:=vkCreateDevice(VulkanApp.FPhysicalDevice,@DeviceInfo,nil,@FHandle);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('vkCreateDevice:',r);
  Exit;
 end;

 p:=0;
 For i:=0 to DeviceInfo.queueCreateInfoCount-1 do
  For w:=0 to SortIndex.data[i].queueCount-1 do
  begin
   vkGetDeviceQueue(FHandle,SortIndex.data[i].queueFamilyIndex,w,Queues.data[p].pQueue);
   Inc(p);
  end;
end;

Destructor TvDevice.Destroy;
begin
 vkDestroyDevice(FHandle,nil);
end;

//

function TvQueue.QueueSubmit(submitCount:TVkUInt32;const pSubmits:PVkSubmitInfo;fence:TVkFence):TVkResult;
begin
 spin_lock(FLock);
 Result:=vkQueueSubmit(FHandle,submitCount,pSubmits,fence);
 spin_unlock(FLock);
end;

function TvQueue.QueueWaitIdle:TVkResult;
begin
 spin_lock(FLock);
 Result:=vkQueueWaitIdle(FHandle);
 spin_unlock(FLock);
end;

function TvQueue.QueuePresentKHR(const pPresentInfo:PVkPresentInfoKHR):TVkResult;
begin
 spin_lock(FLock);
 Result:=vkQueuePresentKHR(FHandle,pPresentInfo);
 spin_unlock(FLock);
end;

//

Constructor TvCmdPool.Create(FFamily:TVkUInt32);
var
 cinfo:TVkCommandPoolCreateInfo;
 r:TVkResult;
begin
 cinfo:=Default(TVkCommandPoolCreateInfo);
 cinfo.sType           :=VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
 cinfo.queueFamilyIndex:=FFamily;
 cinfo.flags:=ord(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT);
 r:=vkCreateCommandPool(Device.FHandle,@cinfo,nil,@FHandle);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('failed to create command pool!');
  exit;
 end;
end;

Destructor TvCmdPool.Destroy;
begin
 vkDestroyCommandPool(Device.FHandle,FHandle,nil);
end;

function TvCmdPool.Alloc:TVkCommandBuffer;
var
 ainfo:TVkCommandBufferAllocateInfo;
 r:TVkResult;
begin
 ainfo:=Default(TVkCommandBufferAllocateInfo);
 ainfo.sType      :=VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
 ainfo.commandPool:=FHandle;
 ainfo.level      :=VK_COMMAND_BUFFER_LEVEL_PRIMARY;
 ainfo.commandBufferCount:=1;
 Result:=VK_NULL_HANDLE;
 r:=vkAllocateCommandBuffers(Device.FHandle,@ainfo,@Result);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('failed to allocate command buffers!');
  Exit;
 end;
end;

procedure TvCmdPool.Free(cmd:TVkCommandBuffer);
begin
 vkFreeCommandBuffers(Device.FHandle,FHandle,1,@cmd);
end;

//

Constructor TvFence.Create(signaled:Boolean);
var
 cinfo:TVkFenceCreateInfo;
 r:TVkResult;
begin
 cinfo:=Default(TVkFenceCreateInfo);
 cinfo.sType:=VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
 if signaled then cinfo.flags:=ord(VK_FENCE_CREATE_SIGNALED_BIT);
 r:=vkCreateFence(Device.FHandle,@cinfo,nil,@FHandle);
 if (r<>VK_SUCCESS) then
 begin
  Writeln('vkCreateFence:',r);
  Exit;
 end;
end;

Destructor TvFence.Destroy;
begin
 vkDestroyFence(Device.FHandle,FHandle,nil);
end;

function TvFence.Reset:TVkResult;
begin
 Result:=vkResetFences(Device.FHandle,1,@FHandle);
end;

function TvFence.Wait(timeout:TVkUInt64):TVkResult;
begin
 Result:=vkWaitForFences(Device.FHandle,1,@FHandle,VK_TRUE,timeout);
end;

function TvFence.Status:TVkResult;
begin
 Result:=vkGetFenceStatus(Device.FHandle,FHandle);
end;

//

Constructor TvSemaphore.Create;
var
 cinfo:TVkSemaphoreCreateInfo;
begin
 cinfo:=Default(TVkSemaphoreCreateInfo);
 cinfo.sType:=VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
 vkCreateSemaphore(Device.FHandle,@cinfo,nil,@FHandle);
end;

Destructor TvSemaphore.Destroy;
begin
 vkDestroySemaphore(Device.FHandle,FHandle,nil);
end;

//

Constructor TvEvent.Create;
var
 cinfo:TVkEventCreateInfo;
begin
 cinfo:=Default(TVkEventCreateInfo);
 cinfo.sType:=VK_STRUCTURE_TYPE_EVENT_CREATE_INFO;
 vkCreateEvent(Device.FHandle,@cinfo,nil,@FHandle);
end;

Destructor TvEvent.Destroy;
begin
 vkDestroyEvent(Device.FHandle,FHandle,nil);
end;

function TvEvent.SetEvent:TVkResult;
begin
 Result:=vkSetEvent(Device.FHandle,FHandle);
end;

function TvEvent.ResetEvent:TVkResult;
begin
 Result:=vkResetEvent(Device.FHandle,FHandle);
end;

function TvEvent.Status:TVkResult;
begin
 Result:=vkGetEventStatus(Device.FHandle,FHandle);
end;

//

procedure vkImageMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   image:TVkImage;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
	   oldImageLayout:TVkImageLayout;
	   newImageLayout:TVkImageLayout;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags;
	   subresourceRange:TVkImageSubresourceRange);
var
 info:TVkImageMemoryBarrier;
begin
 info:=Default(TVkImageMemoryBarrier);
 info.sType           :=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 info.srcAccessMask   :=srcAccessMask;
 info.dstAccessMask   :=dstAccessMask;
 info.oldLayout       :=oldImageLayout;
 info.newLayout       :=newImageLayout;
 info.image           :=image;
 info.subresourceRange:=subresourceRange;

 vkCmdPipelineBarrier(
 	cmdbuffer,
 	srcStageMask,
 	dstStageMask,
 	0,
 	0, nil,
 	0, nil,
 	1, @info);
end;

procedure vkBufferMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   buffer:TVkBuffer;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
           offset,size:TVkDeviceSize;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);
var
 info:TVkBufferMemoryBarrier;
begin
 info:=Default(TVkBufferMemoryBarrier);
 info.sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
 info.srcAccessMask:=srcAccessMask;
 info.dstAccessMask:=dstAccessMask;
 //info.srcQueueFamilyIndex:TVkUInt32;
 //info.dstQueueFamilyIndex:TVkUInt32;
 info.buffer:=buffer;
 info.offset:=offset;
 info.size:=size;

 vkCmdPipelineBarrier(
 	cmdbuffer,
 	srcStageMask,
 	dstStageMask,
 	0,
        0, nil,
 	1, @info,
 	0, nil);

end;

procedure vkMemoryBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   srcAccessMask:TVkAccessFlags;
	   dstAccessMask:TVkAccessFlags;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);
var
 info:TVkMemoryBarrier;
begin
 info:=Default(TVkMemoryBarrier);
 info.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
 info.srcAccessMask:=dstAccessMask;
 info.dstAccessMask:=dstAccessMask;

 vkCmdPipelineBarrier(cmdbuffer,
  srcStageMask,
  dstStageMask,
  0,
  1,
  @info,
  0,
  nil,
  0,
  nil);
end;

procedure vkBarrier(
	   cmdbuffer:TVkCommandBuffer;
	   srcStageMask:TVkPipelineStageFlags;
	   dstStageMask:TVkPipelineStageFlags);
begin
 vkCmdPipelineBarrier(cmdbuffer,
  srcStageMask,
  dstStageMask,
  0,
  0,
  nil,
  0,
  nil,
  0,
  nil);
end;

var
 _lazy_init:Integer=0;
 _lazy_wait:Integer=0;

function IsInitVulkan:Boolean;
begin
 Result:=(load_acq_rel(_lazy_wait)<>0);
end;

Function TestFFF(F:TVkFormatFeatureFlags):RawByteString;
begin
 Result:='';
 if (ord(F) and ord(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT                 ))<>0 then Result:=Result+'|SAMPLED_IMAGE';
 if (ord(F) and ord(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT                 ))<>0 then Result:=Result+'|STORAGE_IMAGE';
 if (ord(F) and ord(VK_FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT          ))<>0 then Result:=Result+'|STORAGE_IMAGE_ATOMIC';
 if (ord(F) and ord(VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT          ))<>0 then Result:=Result+'|UNIFORM_TEXEL_BUFFER';
 if (ord(F) and ord(VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT          ))<>0 then Result:=Result+'|STORAGE_TEXEL_BUFFER';
 if (ord(F) and ord(VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT   ))<>0 then Result:=Result+'|STORAGE_TEXEL_BUFFER_ATOMIC';
 if (ord(F) and ord(VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT                 ))<>0 then Result:=Result+'|VERTEX_BUFFER';
 if (ord(F) and ord(VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT              ))<>0 then Result:=Result+'|COLOR_ATTACHMENT';
 if (ord(F) and ord(VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT        ))<>0 then Result:=Result+'|COLOR_ATTACHMENT_BLEND';
 if (ord(F) and ord(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT      ))<>0 then Result:=Result+'|DEPTH_STENCIL_ATTACHMENT';
 if (ord(F) and ord(VK_FORMAT_FEATURE_BLIT_SRC_BIT                      ))<>0 then Result:=Result+'|BLIT_SRC';
 if (ord(F) and ord(VK_FORMAT_FEATURE_BLIT_DST_BIT                      ))<>0 then Result:=Result+'|BLIT_DST';
 if (ord(F) and ord(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT   ))<>0 then Result:=Result+'|SAMPLED_IMAGE_FILTER_LINEAR';
 if (ord(F) and ord(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG))<>0 then Result:=Result+'|SAMPLED_IMAGE_FILTER_CUBIC';
 if (ord(F) and ord(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT                  ))<>0 then Result:=Result+'|TRANSFER_SRC';
 if (ord(F) and ord(VK_FORMAT_FEATURE_TRANSFER_DST_BIT                  ))<>0 then Result:=Result+'|TRANSFER_DST';
end;

Procedure InitVulkan;
var
 DeviceQueues:TvDeviceQueues;
 //ImgProp:TVkFormatProperties;

 features_Shader8 :TVkPhysicalDeviceShaderFloat16Int8Features;
 features_Storage8:TVkPhysicalDevice8BitStorageFeaturesKHR;

 features_Storage16:TVkPhysicalDevice16BitStorageFeatures;

 features_Scalar:TVkPhysicalDeviceScalarBlockLayoutFeatures;

 features_Coherent:TVkPhysicalDeviceCoherentMemoryFeaturesAMD;

begin
 if XCHG(_lazy_init,1)=0 then
 begin
  VulkanApp:=TVulkanApp.Create(true,true,true);
  DebugReport:=TVDebugReport.Create;

  MemManager:=TvMemManager.Create;

  FillDeviceExtension(VulkanApp.FPhysicalDevice);
  FillDeviceProperties(VulkanApp.FPhysicalDevice);

  if not limits.VK_KHR_swapchain then
  begin
   raise Exception.Create('VK_KHR_swapchain not support!');
  end;

  if not limits.VK_EXT_external_memory_host then
  begin
   raise Exception.Create('VK_EXT_external_memory_host not support!');
  end;

  DeviceQueues:=TvDeviceQueues.Create;

  if (VulkanApp.FGFamilyCount>1) then
  begin
   FlipQueue  :=TvQueue.Create;
   RenderQueue:=TvQueue.Create;
   DeviceQueues.add_queue(VulkanApp.FGFamily,@FlipQueue  .FHandle);
   DeviceQueues.add_queue(VulkanApp.FGFamily,@RenderQueue.FHandle);
  end else
  begin
   FlipQueue  :=TvQueue.Create;
   RenderQueue:=FlipQueue;
   DeviceQueues.add_queue(VulkanApp.FGFamily,@FlipQueue  .FHandle);
  end;

  DeviceQueues.add_ext(VK_KHR_SWAPCHAIN_EXTENSION_NAME);

  DeviceQueues.add_ext(VK_KHR_EXTERNAL_MEMORY_EXTENSION_NAME);
  DeviceQueues.add_ext(VK_EXT_EXTERNAL_MEMORY_HOST_EXTENSION_NAME);

  if limits.VK_AMD_device_coherent_memory then
  begin
   DeviceQueues.add_ext(VK_AMD_DEVICE_COHERENT_MEMORY_EXTENSION_NAME);

   features_Coherent:=Default(TVkPhysicalDeviceCoherentMemoryFeaturesAMD);
   features_Coherent.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COHERENT_MEMORY_FEATURES_AMD;
   features_Coherent.deviceCoherentMemory:=VK_TRUE;

   DeviceQueues.add_feature(@features_Coherent);
  end;

  //if limits.VK_KHR_push_descriptor then
  //begin
  // DeviceQueues.add_ext(VK_KHR_PUSH_DESCRIPTOR_EXTENSION_NAME);
  //end;

  if limits.VK_KHR_shader_non_semantic_info then
  begin
   DeviceQueues.add_ext(VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME);
  end;

  if limits.VK_EXT_scalar_block_layout then
  begin
   DeviceQueues.add_ext(VK_EXT_SCALAR_BLOCK_LAYOUT_EXTENSION_NAME);

   features_Scalar:=Default(TVkPhysicalDeviceScalarBlockLayoutFeatures);
   features_Scalar.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SCALAR_BLOCK_LAYOUT_FEATURES;
   features_Scalar.scalarBlockLayout:=VK_TRUE;

   DeviceQueues.add_feature(@features_Scalar);
  end;

  if limits.VK_KHR_8bit_storage then
  begin
   DeviceQueues.add_ext(VK_KHR_8BIT_STORAGE_EXTENSION_NAME);

   features_Shader8:=Default(TVkPhysicalDeviceShaderFloat16Int8Features);
   features_Shader8.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES;
   features_Shader8.shaderInt8:=VK_TRUE;

   features_Storage8:=Default(TVkPhysicalDevice8BitStorageFeaturesKHR);
   features_Storage8.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_8BIT_STORAGE_FEATURES;
   features_Storage8.storageBuffer8BitAccess:=VK_TRUE;
   features_Storage8.uniformAndStorageBuffer8BitAccess:=VK_TRUE;
   //features_Storage8.storagePushConstant8:=VK_TRUE;

   DeviceQueues.add_feature(@features_Shader8);
   DeviceQueues.add_feature(@features_Storage8);
  end;

  if limits.VK_KHR_16bit_storage then
  begin
   DeviceQueues.add_ext(VK_KHR_16BIT_STORAGE_EXTENSION_NAME);

   features_Storage16:=Default(TVkPhysicalDevice16BitStorageFeatures);
   features_Storage16.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES;
   features_Storage16.storageBuffer16BitAccess:=VK_TRUE;
   features_Storage16.uniformAndStorageBuffer16BitAccess:=VK_TRUE;
   //features_Storage16.storagePushConstant16:=VK_TRUE;

   DeviceQueues.add_feature(@features_Storage16);
  end;

  Device:=TvDevice.Create(DeviceQueues);
  DeviceQueues.Free;

  XCHG(_lazy_wait,1);

  //ImgProp:=Default(TVkFormatProperties);
  //vkGetPhysicalDeviceFormatProperties(VulkanApp.FPhysicalDevice,VK_FORMAT_R8G8B8A8_UNORM,@ImgProp);
  //Writeln('R8G8B8A8_UNORM:',TestFFF(ImgProp.optimalTilingFeatures));
  //writeln;
  //vkGetPhysicalDeviceFormatProperties(VulkanApp.FPhysicalDevice,VK_FORMAT_R8G8B8A8_SRGB,@ImgProp);
  //Writeln('R8G8B8A8_SRGB:',TestFFF(ImgProp.optimalTilingFeatures));
  //writeln;
  //vkGetPhysicalDeviceFormatProperties(VulkanApp.FPhysicalDevice,VK_FORMAT_B8G8R8A8_SRGB,@ImgProp);
  //Writeln('B8G8R8A8_SRGB:',TestFFF(ImgProp.optimalTilingFeatures));
  //writeln;
  //vkGetPhysicalDeviceFormatProperties(VulkanApp.FPhysicalDevice,VK_FORMAT_A8B8G8R8_SRGB_PACK32,@ImgProp);
  //Writeln('A8B8G8R8_SRGB:',TestFFF(ImgProp.optimalTilingFeatures));




  //PrintQueueFamily(VulkanApp.FPhysicalDevice);
  //writeln;
  //PrintInstanceExtension;
  //writeln;
  //PrintDeviceExtension(VulkanApp.FPhysicalDevice);
  //writeln;

 end else
 begin
  wait_until_equal(_lazy_wait,0);
 end;
end;

initialization
 if not LoadVulkanLibrary        then raise Exception.Create('LoadVulkanLibrary');
 if not LoadVulkanGlobalCommands then raise Exception.Create('LoadVulkanGlobalCommands');
 SetExceptionMask([exInvalidOp, exDenormalized, exPrecision]);

end.

