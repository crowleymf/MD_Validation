compare:
	../ffcompare Amber_output/cello_1_20_wat_amber.frcdmp charmm_output/cello_1_20_wat_chm.frcdmp | tee Compare_300
	../ffcompare Amber_output/cello_1_20_wat_600k_amber.frcdmp charmm_output/cello_1_20_wat_600k_chm.frcdmp | tee Compare_600

clean:
	-/bin/rm -f  *~ */*~ \
	   charmm_output/*   \
	   Amber_output/*    \
	   mdcrd	     \
	   mdinfo	     \
	   mdout	     \
	   pdb/asn.pdb asn_600k.pdb \
	   restrt \
	Compare*
