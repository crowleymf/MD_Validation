all:
	charmm -i input/methane.inp  | tee output/charmm.out
	charmm -i input/methane2.inp | tee output/charmm.out2

clean:
	-/bin/rm -f  *~ */*~ fort* charmm_output/charmm*


allclean:
	-/bin/rm -f  *~ */*~ \
	   output/* \

