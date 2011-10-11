#Defines specific to the CHARMM install
include ../../../tool/common.mk

#Defines local to the test
TESTNAME=polypro

PSF=$(TESTNAME).psf
COR=$(TESTNAME).pdb

charmm.out $(PSF) $(COR): $(TESTNAME).inp
	@$(CHARMM) < $(TESTNAME).inp > charmm.out

$(COR): charmm.out
$(PSF): charmm.out

clean:
	@rm -f *.psf *.pdb charmm.out *.dat *.cor

install: $(COR) $(PSF)
	mv $(COR) ..
	mv $(PSF) ..
	mv *.dat ..
	mv $(TESTNAME)_xplor.psf ..
	$(MAKE) clean
