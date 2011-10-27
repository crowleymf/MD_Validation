#****************************************************************************************
# TCL SCRIPT FOR ENERGY AND FORCE ANALYSIS OF NAMD TRAJECTORIES
# USAGE:reads a NAMD-generated binary force file, and log file for energies
# Eventually we write out forces on every atom and all energy terms; Note: PSF is needed!
# Author: Harish Vashisth (Brooks Group), Oct 2011
# This script runs under VMD but can be made to run under other TCL installations
#*****************************************************************************************


# Read command line arguments
set argc [llength $argv]

if { $argc < 8 } {
    puts "Invoke error: vmd -dispdev text -e \[scriptname\].tcl -args -psf \[filename\] -forcefile \[filename\] -logfile \[filename\] -outfile \[filename\] "
    exit
}

set psf               [lindex $argv 1]
set forcefile         [lindex $argv 3]
set logfile           [lindex $argv 5]
set eforcefile        [lindex $argv 7]

# Load PSF with binary FORCE file
mol load psf $psf namdbin $forcefile

# Making selection of all atoms
set sel [atomselect top "all"]
set natoms "[$sel num]"

# Open output file and write total number of atoms on top
set outfile [open $eforcefile w];
puts $outfile "NATOM\t\t$natoms"



# Extracting and printing all energies
# Note: UREY term is already added into ANGL term in NAMD, likely cannot be separated!

set ENER [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $12)}}]
set BOND [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $3) }}]
set ANGL [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $4) }}]
set UREY " "
set DIHE [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $5) }}]
set IMPR [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $7) }}]
set VDW  [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $9) }}]
set ELEC [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $8) }}]
set CMAP [exec cat $logfile | grep -i "^tcl" | awk {{if ($2==0) print}} | awk {{printf ("% .16E", $6) }}]


puts $outfile "ENERGY"
puts $outfile "\tENER\t$ENER"
puts $outfile "\tBOND\t$BOND"
puts $outfile "\tANGL\t$ANGL"
puts $outfile "\tUREY\t$UREY"
puts $outfile "\tDIHE\t$DIHE"
puts $outfile "\tIMPR\t$IMPR"
puts $outfile "\tVDW\t$VDW"
puts $outfile "\tELEC\t$ELEC"
puts $outfile "\tCMAP\t$CMAP"
puts $outfile "FORCE"


# Extracting and printing forces on all atoms

# Format strings for forces
set fmt1 "%6i"
set fmt2 "% .16E"

for {set m 0 } { $m < $natoms } { incr m } {
      set newsel [atomselect top "index $m"]
      puts -nonewline $outfile "\t[format $fmt1 [expr $m+1]]\t[format $fmt2 [$newsel get x]]\t\t"   
      puts -nonewline $outfile "[format $fmt2 [$newsel get y]]\t\t"
      puts -nonewline $outfile "[format $fmt2 [$newsel get z]]"
      puts $outfile "   "  
 }

close $outfile


exit


