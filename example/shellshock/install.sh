function download_install () { wget $1 ; sudo dpkg -i $2; rm $2; }

download_install "http://ftp.osuosl.org/pub/ubuntu/pool/universe/f/fonts-adf/fonts-adf-accanthis_0.20110505-1_all.deb" "fonts-adf-accanthis_0.20110505-1_all.deb"
sleep 5
download_install "http://mirrors.kernel.org/ubuntu/pool/main/j/java-common/java-common_0.63ubuntu1~02_all.deb" "java-common_0.63ubuntu1~02_all.deb"
sleep 8
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/a/arc/arc_5.21q-5_amd64.deb" "arc_5.21q-5_amd64.deb"
sleep 3
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/s/sx/sx_2.0+ds-4build2_amd64.deb" "sx_2.0+ds-4build2_amd64.deb"
sleep 12
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/e/edb/edb_1.31-3_all.deb" "edb_1.31-3_all.deb"
sleep 7
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/c/carmetal/carmetal_3.5.2+dfsg-1.1_all.deb" "carmetal_3.5.2+dfsg-1.1_all.deb"
sleep 10
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/s/spl-linux/spl_0.7.5-1ubuntu2_amd64.deb" "spl_0.7.5-1ubuntu2_amd64.deb"
sleep 7
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/a/aurora/aurora_1.9.3-0ubuntu1_amd64.deb" "aurora_1.9.3-0ubuntu1_amd64.deb"
sleep 1
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/j/jzmq/libzmq-java_3.1.0-10_amd64.deb" "libzmq-java_3.1.0-10_amd64.deb"
sleep 6
download_install "https://github.com/angryip/ipscan/releases/download/3.5.5/ipscan_3.5.5_amd64.deb" "ipscan_3.5.5_amd64.deb"
sleep 4
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/x/xmlto/xmlto_0.0.28-2_amd64.deb" "xmlto_0.0.28-2_amd64.deb"
sleep 16
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/p/plexus-languages/libplexus-languages-java_0.9.5-2_all.deb" "libplexus-languages-java_0.9.5-2_all.deb"
sleep 1
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/z/zathura-pdf-poppler/zathura-pdf-poppler_0.2.8-1_amd64.deb" "zathura-pdf-poppler_0.2.8-1_amd64.deb"
sleep 7
download_install "http://mirrors.kernel.org/ubuntu/pool/universe/f/fasd/fasd_1.0.1-1_all.deb" "fasd_1.0.1-1_all.deb"
sleep 7
