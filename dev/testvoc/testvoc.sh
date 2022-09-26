echo "==French->Languedocien Occitan==========================";
bash inconsistency.sh fra-oci ../../../apertium-fra/.deps/fra.dix > /tmp/fra-oci.testvoc; bash inconsistency-summary.sh /tmp/fra-oci.testvoc fra-oci
echo ""
echo "==French->Gascon Occitan==========================";
bash inconsistency.sh fra-oci_gascon ../../../apertium-fra/.deps/fra.dix > /tmp/fra-oci_gascon.testvoc; bash inconsistency-summary.sh /tmp/fra-oci_gascon.testvoc fra-oci_gascon
echo ""
echo "==Languedocien Occitan->French===========================";
bash inconsistency.sh oci-fra ../../../apertium-oci/.deps/oci.dix > /tmp/oci-fra.testvoc; bash inconsistency-summary.sh /tmp/oci-fra.testvoc oci-fra
echo ""
echo "==Gascon Occitan->French===========================";
bash inconsistency.sh oci_gascon-fra ../../../apertium-oci/.deps/oci@gascon.dix > /tmp/oci_gascon-fra.testvoc; bash inconsistency-summary.sh /tmp/oci_gascon-fra.testvoc oci_gascon-fra
