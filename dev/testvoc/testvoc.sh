echo "==French->Occitan==========================";
bash inconsistency.sh fra-oci ../../../apertium-fra/.deps/fra.dix > /tmp/fra-oci.testvoc; bash inconsistency-summary.sh /tmp/fra-oci.testvoc fra-oci 
echo ""
echo "==Occitan->French===========================";
bash inconsistency.sh oci-fra ../../../apertium-oci/apertium-oci.oci.dix > /tmp/oci-fra.testvoc; bash inconsistency-summary.sh /tmp/oci-fra.testvoc oci-fra
