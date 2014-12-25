#! /bin/bash
echo "Fetch mshadow..."
git clone https://github.com/tqchen/mshadow.git
make -j 8 $1

