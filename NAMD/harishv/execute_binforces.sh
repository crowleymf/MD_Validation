#!/bin/sh

vmd -dispdev -text -e genread_binforces.tcl -args -psf triala_xplor.psf -forcefile md.force -logfile md.log -outfile namd_forcedump.dat

