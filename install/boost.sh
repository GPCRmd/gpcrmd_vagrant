#! /usr/bin/bash
OLD_PWD=$(pwd -L)
mkdir -p /usr/local/src
# version 1.61
tar -xvjf boost.tar.bz2 -C /usr/local/src
cd /usr/local/src/boost*

PY_LIBRARY_PATHS=("/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu/"
                  "/usr/lib64/")
for path in ${PY_LIBRARY_PATHS[@]}; do
  if [ -d "$path" ]; then
    PY_LIBRARY_PATH="$path"
  fi
done

./bootstrap.sh --with-python-version=3.4 --with-python=/env/bin/python3 --with-python-root=/env --with-libraries=python,regex,thread,serialization
perl -pi  -e "my \$line = 'using python : 3.4 : /env/bin/python3 : /usr/include/python3.4m : \"$PY_LIBRARY_PATH\" ;';\
  s/^(import\s+python\s*;)\s*$/\1\n\$line\n/" /usr/local/src/boost*/project-config.jam
#perl -pi  -e "my \$line = 'using python : 3.4 : /env/bin/python3 : /usr/include/python3.4m : \"$PY_LIBRARY_PATH\" ;';\
#   s/^\s*using\s+python\s+.*$/\$line/" /usr/local/src/boost*/project-config.jam
./b2 install -a cxxflags=-fPIC cflags=-fPIC #Flags for enabling shared and static linking



cd $OLD_PWD
ldconfig
