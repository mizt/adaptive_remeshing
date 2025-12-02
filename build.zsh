cd "$(dirname "$0")"
set -eu

PLUGIN_NAME="adaptive_remeshing"
PLUGIN_PATH="./${PLUGIN_NAME}.plugin"

mkdir -p ${PLUGIN_PATH}/Contents/MacOS
clang++ -std=c++23 -Wc++23-extensions -bundle -fobjc-arc -O3 -framework Cocoa \
-I ./ \
-I./eigen/3.4.0_1/include/eigen3 \
./pmp/surface_mesh.cpp \
./pmp/algorithms/*.cpp \
./${PLUGIN_NAME}.mm \
-o ${PLUGIN_PATH}/Contents/MacOS/${PLUGIN_NAME}
cp ./Info.plist ${PLUGIN_PATH}/Contents/

echo "** BUILD SUCCEEDED **"

