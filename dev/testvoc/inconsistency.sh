TMPDIR=/tmp

if [[ $1 = "oci-fra" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../oci-fra.autobil.bin |\
        lrx-proc -m ../../oci-fra.autolex.bin |\
        apertium-transfer -b ../../apertium-fra-oci.oci-fra.t1x  ../../oci-fra.t1x.bin | tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../oci-fra.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

elif [[ $1 = "fra-oci" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../fra-oci.autobil.bin |\
        lrx-proc -m ../../fra-oci.autolex.bin |\
        apertium-transfer -b ../../apertium-fra-oci.fra-oci.t1x  ../../fra-oci.t1x.bin  | tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../fra-oci.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

else
	echo "sh inconsistency.sh <direction>";
fi
