all:
	charmm -i input/ethane.inp  | tee output/charmm.out

clean:
	-/bin/rm -f  *~ */*~ fort* mdout restrt \
	      charmm_output/* \
	      Amber_output/*  \
	      pdb/*.pdb \
	      psf/*.psf 


allclean:
	-/bin/rm -f  *~ */*~ \
	   output/* 

