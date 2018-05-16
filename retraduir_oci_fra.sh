make && cat ../apertium-oci/corpus/jornalet.5000.txt | apertium -d . oci-fra > traduc_nova_oci_fra.txt
diff traduc_act_oci_fra.txt traduc_nova_oci_fra.txt | more
