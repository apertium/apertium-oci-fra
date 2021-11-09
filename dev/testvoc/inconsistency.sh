TMPDIR=/tmp

if [[ $1 = "oci-fra" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../oci-fra.autobil.bin |\
        lrx-proc -m ../../oci-fra.autolex.bin |\
        apertium-transfer -b ../../oci-fra.t1x  ../../oci-fra.t1x.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2ax  ../../oci-fra.t2ax.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2bx  ../../oci-fra.t2bx.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2cx  ../../oci-fra.t2cx.bin |\
        apertium-postchunk ../../apertium-oci-fra.oci-fra.t3x  ../../oci-fra.t3x.bin |\
        apertium-transfer -n ../../apertium-oci-fra.oci-fra.t4x  ../../oci-fra.t4x.bin |\
	tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../oci-fra.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

elif [[ $1 = "oci_gascon-fra" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../oci@gascon-fra.autobil.bin |\
        lrx-proc -m ../../oci-fra.autolex.bin |\
        apertium-transfer -b ../../oci@gascon-fra.t1x  ../../oci-fra.t1x.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2ax  ../../oci-fra.t2ax.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2bx  ../../oci-fra.t2bx.bin |\
        apertium-interchunk ../../apertium-oci-fra.oci-fra.t2cx  ../../oci-fra.t2cx.bin |\
        apertium-postchunk ../../apertium-oci-fra.oci-fra.t3x  ../../oci-fra.t3x.bin |\
        apertium-transfer -n ../../apertium-oci-fra.oci-fra.t4x  ../../oci-fra.t4x.bin |\
	tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../oci-fra.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

elif [[ $1 = "fra-oci" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../fra-oci.autobil.bin |\
        lrx-proc -m ../../fra-oci.autolex.bin |\
        apertium-transfer -b ../../fra-oci.t1x  ../../fra-oci.t1x.bin  |\
        apertium-interchunk ../../apertium-oci-fra.fra-oci.t2x  ../../fra-oci.t2x.bin  |\
        apertium-postchunk ../../apertium-oci-fra.fra-oci.t3x  ../../fra-oci.t3x.bin  |\
        apertium-transfer -n ../../apertium-oci-fra.fra-oci.t4x  ../../fra-oci.t4x.bin  |\
	tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../fra-oci.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

elif [[ $1 = "fra-oci_gascon" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../fra-oci@gascon.autobil.bin |\
        lrx-proc -m ../../fra-oci.autolex.bin |\
        apertium-transfer -b ../../fra-oci@gascon.t1x  ../../fra-oci@gascon.t1x.bin  |\
        apertium-interchunk ../../apertium-oci-fra.fra-oci.t2x  ../../fra-oci.t2x.bin  |\
        apertium-interchunk ../../apertium-oci-fra.fra-oci.t2x_supersn  ../../fra-oci@gascon.t2x_supersn.bin  |\
        apertium-interchunk ../../apertium-oci-fra.fra-oci.t2x_enon  ../../fra-oci@gascon.t2x_enon.bin  |\
        apertium-postchunk ../../apertium-oci-fra.fra-oci.t3x  ../../fra-oci.t3x.bin  |\
        apertium-transfer -n ../../apertium-oci-fra.fra-oci.t4x  ../../fra-oci.t4x.bin  |\
	tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../fra-oci.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

else
	echo "sh inconsistency.sh <direction>";
fi
