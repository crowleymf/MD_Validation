all:
	charmm -i input/methane.inp  | tee output/charmm.out
	charmm -i input/methane2.inp | tee output/charmm.out2

clean:
	-/bin/rm -f  *~ */*~ fort* mdout restrt \
	     charmm_output/charmm* \
	     charmm_output/*frcdmp \
             Amber_output/*        \
             pdb/*                \
             psf/*                


allclean:
	-/bin/rm -f  *~ */*~ \
	   output/* \

