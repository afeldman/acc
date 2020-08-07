 #!/bin/sh

bnfc -m whitespace.cf 
make 
make clean 
 
sed "s/ //g;s|//.*||g;s/\\n//g" test/hello_world.ws | tr -d '\n' | sed "s/l/ /g;s/t/\t/g;s/u/\n/g" > ./tmp.ws

./TestWhitespace ./tmp.ws

make distclean
rm ./tmp.ws 

