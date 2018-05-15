make && cat ../apertium-fra/corpus/wikipedia.5000.txt | time apertium -d . fra-oci > traduc_nova_fra_oci.txt
diff traduc_act_fra_oci.txt traduc_nova_fra_oci.txt | more
