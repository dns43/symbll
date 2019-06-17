# 0) Let's move the examples to /home/vagrant
cp -r 01_harvey 02_firefox 03_panda_rr /home/vagrant


# 1) Install general dependencies
sudo apt-get update
sudo apt-get install -y cmake
sudo apt-get install -y python python-pip
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y libc6-i386 gdb git pkg-config gdb-arm-none-eabi
sudo apt-get install -y libcapstone3 libcapstone-dev
sudo apt-get install -y libgtk-3.0 xorg libffi-dev

# 2) Fetch and install avatar
git clone --branch bar18_avatar2 https://github.com/avatartwo/avatar2.git
sudo pip2 install avatar2/
sudo pip3 install avatar2/

# 2.5) fixup keystone's installation path (c.f. https://github.com/keystone-engine/keystone/issues/235)
sudo cp /usr/local/lib/python2.7/dist-packages/usr/lib/python2.7/dist-packages/keystone/libkeystone.so \
        /usr/local/lib/python2.7/dist-packages/keystone
sudo cp /usr/local/lib/python3.5/dist-packages/usr/lib/python3/dist-packages/keystone/libkeystone.so \
        /usr/local/lib/python3.5/dist-packages/keystone

# 3) build the endpoints
./avatar2/targets/build_panda.sh
#./avatar2/targets/build_qemu.sh # QEMU is not needed for this examples - let's skip it here
sudo pip2 install angr
sudo apt-get install -y openocd

# 4) download and unpack, or build firefox for the second example.
#/vagrant/02_firefox/build_firefox.sh 

wget http://www.s3.eurecom.fr/~muench/data/firefox-52.0.en-US.linux-x86_64.tar.bz2 -P /vagrant/02_firefox/
tar -xvf /vagrant/02_firefox/firefox-52.0.en-US.linux-x86_64.tar.bz2 -C /home/vagrant/
ln -s  /home/vagrant/firefox/firefox-bin /vagrant/02_firefox/firefox

# dns4
# dependencies
sudo apt-get install -y libglib2.0-dev
sudo apt-get install -y  libunwind-dev

# 5) avatar-panda 
# we'll need svn to install LLVM later
sudo apt-get install -y subversion
# project folder
mkdir concolic
cd concolic/
git clone https://github.com/avatartwo/avatar-panda.git
cd avatar-panda
git remote add upstream https://github.com/panda-re/panda
git fetch upstream
git merge upstream/llvm_trace2
git checkout llvm_trace2
sudo apt-get install -y libunwind-dev
sudo apt-get install -y libglib2.2-dev
sudo add-apt-repository ppa:phulin/panda
sudo apt-get update
git submodule update --init pixman
git submodule update --init dtc

sudo apt-get install -y autoconf
sudo apt-get install -y libtool

# dang it, I have to edit this file programmatically
#sudo vim /etc/apt/sources.list
sudo apt-get install -y python-pip git protobuf-compiler protobuf-c-compiler   libprotobuf-c0-dev libprotoc-dev python-protobuf libelf-dev   libcapstone-dev libdwarf-dev python-pycparser llvm-3.3 clang-3.3 libc++-dev


mkdir build && cd build
../panda/scripts/install_ubuntu.sh 

# 6) z3py
cd /home/vagrant/concolic/
git clone https://github.com/Z3Prover/z3.git
cd z3
python scripts/mk_make.py --python
cd build
make
sudo make install

# 7) llvmpy
#sudo pip install --upgrade pip
#sudo LLVM_CONFIG_PATH=/usr/lib/llvm-3.3/bin/llvm-config pip install --user llvmpy
#sudo -H LLVM_CONFIG_PATH=/usryyp/lib/llvm-3.3/bin/llvm-config pip install --user llvmpy
sudo -H LLVM_CONFIG_PATH=/usr/lib/llvm-3.3/bin/llvm-config pip2 install llvmpy

# 8) symbll
cd /home/vagrant/concolic/
git clone https://github.com/dns43/symbll.git
cd symbll
protoc --python_out=. plog.proto

cd /home/vagrant/concolic/
git clone https://github.com/avatartwo/bar18_avatar2
cp bar18_avatar2/03_panda_rr/ bar18_avatar2/04_concolic
cp -r bar18_avatar2/03_panda_rr/ bar18_avatar2/04_concolic
mv symbll/firmware.bin bar18_avatar2/04_concolic/firmware.bin
