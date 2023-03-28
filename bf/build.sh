 #!/bin/sh

bnfc -m bf.cf
make
make clean

./TestBf < test/one.bf

make distclean