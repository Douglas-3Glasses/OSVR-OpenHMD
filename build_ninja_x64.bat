rd /S /Q .build
mkdir .build
cd .build
@call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat"
cmake ^
  -DOSVR_ADD_PLUGIN_CPP:BOOL=True  ^
  -DCMAKE_PREFIX_PATH:PATH="D:\projects\OSVR\OSVR-Core-Snapshot-v0.6-2118"  ^
  -DBoost_INCLUDE_DIR:PATH="C:/local/boost_1_68_0"  ^
  -DHIDAPI_DIR:PATH="D:\projects\OSVR\OSVR-OpenHMD\vendor\hidapi"  ^
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo  ^
  -GNinja ..
ninja
