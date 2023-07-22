#!/bin/sh

set -eux
source ./machine-setup.sh > /dev/null 2>&1

if [ $target = gaea ]; then
  source /lustre/f2/dev/role.epic/contrib/Lmod_init.sh
fi

module use ../modulefiles
module load $target
module list


if [ $target = hera ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = orion ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = jet ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = wcoss2 ] ; then
  export FC=ftn
  export F90=ftn
  export CC=icc
elif [ $target != gaea ] ; then
  echo "Unknown machine = $target"
  exit 1
fi

cd ..
if [ -d "build" ]; then
   rm -rf build
fi
mkdir build
cd build
cmake .. -DCMAKE_Fortran_COMPILER=$FC -DCMAKE_C_COMPILER=$CC -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
make -j 8 VERBOSE=1
make install

cd ..

exit
