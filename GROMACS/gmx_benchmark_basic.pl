#!/usr/bin/perl -w
use strict;

# Practically the last part of the script gmx_benchmark.pl; in case the force
# field parameters are not available in the gromacs default gromacs force field
# directory ../gromacs/share/gromacs/top/, i.e. (currently) carbohydrates or 
# other unusual molecules, one can generate the gromacs tpr file for the 
# benchmark run manually and this Perl script will handle the rest.
#
# Written by Xiaohu Hu (hux2@ornl.gov), Jan 2012.
# 
# Required inputs:
#  - a gromacs tpr file
#  - force field, i.e. charmm27, amber99sb, ...
#  - a system name whatever you want to name your system

# gromacs needs to be installed and user needs to specify the path of gromacs 
# tools binaries here:
my $gmx_path="/usr/local/gromacs/bin";


# some global variables
my $tpr_file;
my $forcefield;
my $system_name;

my $command; 
my $output;

my @raw_data;
my $line;

my $natoms;

# parse the command line input
my $nargs=@ARGV;

if ($nargs!=2) { 
        die "\nSynthax error: 2 arguments required!\n".
            "Example: ./gmx_benchmark_basic.pl filename.tpr system_name\n\n";
}

$tpr_file = $ARGV[0];
if ($tpr_file !~ /[A-Za-z0-9-]+.tpr/) {
    die "\nInput error: GROMACS tpr file name is incorrect\n\n!";
}

$system_name = $ARGV[1];
if ($system_name !~ /[A-Za-z0-9-]/) {
    die "\nInput error: system name must be a string\n\n!";
}

# run benchmark
$command = "$gmx_path/mdrun -s $tpr_file";
$output = `$command`;
print"$output\n";

# get the total atom number from the default structure output "confout.gro"
open(STRUCT, "< confout.gro");
@raw_data=<STRUCT>;
$natoms = $raw_data[1];
close(STRUCT);

# read out the energies
$command = "echo 1 2 3 4 5 6 7 8 9 10 | g_energy ".
           "-f ener.edr -o tmp_ener.xvg > ener.tmp";
$output = `$command`;
print "$output\n";

open(ENER, "< ener.tmp")
    or die ("#@# Error: Cannot open file \"ener.tmp\"\n\n");
@raw_data = <ENER>;
close(ENER);

my $ener = 0.0;
my $bond = 0.0;
my $angl = 0.0;
my $urey = 0.0;
my $dihe = 0.0;
my $impr = 0.0;
my $lj = 0.0;
my $lj14 = 0.0;
my $vdw = 0.0;
my $elec = 0.0;
my $coulomb = 0.0;
my $coulomb14 = 0.0;
my $cmap = 0.0;

# extract the energy value and convert from kJ/mol (gromacs energy unit) into 
# kcal/mol
foreach $line (@raw_data) {

    my $s1;
    my $s2;
    my $s3;
    my $s4;

    if ($line =~ m/Bond/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $bond = $s2*0.239001;
    }

    if ($line =~ m/Angle/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $angl = $s2*0.239001;
    }

    if ($line =~ m/Potential/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $ener = $s2*0.239001;
    }

    if ($line =~ m/U-B/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $urey = $s2*0.239001;
    }

    if ($line =~ m/Proper Dih/) {
        ($s1,$s2,$s3,$s4) = split(" ", $line);
        $dihe = $s3*0.239001;
    }

    if ($line =~ m/Improper Dih/) {
        ($s1,$s2,$s3,$s4) = split(" ", $line);
        $impr = $s3*0.239001;
    }

    if ($line =~ m/CMAP Dih/) {
        ($s1,$s2,$s3,$s4) = split(" ", $line);
        $cmap = $s3*0.239001;
    }

    if ($line =~ m/LJ \(SR\)/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $lj = $s3*0.239001;
    }

    if ($line =~ m/LJ-14/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $lj14 = $s2*0.239001;
    }

    if ($line =~ m/Coulomb \(SR\)/) {
        ($s1,$s2,$s3,$s4) = split(" ", $line);
        $coulomb = $s3*0.239001;
    }

    if ($line =~ m/Coulomb-14/) {
        ($s1,$s2,$s3) = split(" ", $line);
        $coulomb14 = $s2*0.239001;
    }
}

$vdw = $lj + $lj14;
$elec = $coulomb + $coulomb14;

# write out forces
$command = "echo 0 | g_traj ".
           "-f traj.trr ".
           "-s benchmark.tpr ".
           "-af forces.xvg";
$output = `$command`;
print("$output\n");

open(FORCES, "< forces.xvg") 
    or die "#@# Error: Cannot open the file \"forces.xvg\"\n\n";
@raw_data = <FORCES>;
close(FORCES);

# Write out the results
open(OUTPUT, "> $system_name\_$forcefield.frcdmp");
printf(OUTPUT "NATOM %7d\n", $natoms);
printf(OUTPUT "ENERGY\n");
printf(OUTPUT "  ENER    %7.15e\n", $ener) if ($ener != 0);
printf(OUTPUT "  BOND    %7.15e\n", $bond) if ($bond != 0);
printf(OUTPUT "  ANGL    %7.15e\n", $angl) if ($angl != 0);
printf(OUTPUT "  UREY    %7.15e\n", $urey) if ($urey != 0);
printf(OUTPUT "  DIHE    %7.15e\n", $dihe) if ($dihe != 0);
printf(OUTPUT "  IMPR    %7.15e\n", $impr) if ($impr != 0);
printf(OUTPUT "  VDW     %7.15e\n", $vdw) if ($vdw != 0);
printf(OUTPUT "  ELEC    %7.15e\n", $elec) if ($elec != 0);
printf(OUTPUT "  CMAP    %7.15e\n", $cmap) if ($cmap != 0);
printf(OUTPUT "FORCE\n");

foreach $line (@raw_data) {

    my $atomid;
    my $force_x;
    my $force_y;
    my $force_z;

    if ($line !~ m/@/ && $line !~ m/#/) {
        ($atomid,$force_x,$force_y,$force_z) = split(" ",$line);

        # Convert kJ/(mol*nm) (gromacs force unit) to kcal/(mol*A)
        $force_x = $force_x * 0.0239001;
        $force_y = $force_y * 0.0239001;
        $force_z = $force_z * 0.0239001;

        printf(OUTPUT "%7d   %7.15e   %7.15e   %7.15e \n",$atomid,$force_x,$force_y,$force_z);
    }
}

close(OUTPUT);

# clean up
system("rm tmp_ener.xvg ener.tmp force.pdb");
system("rm \\\#*") unless (-d "\\\#*");

# END OF THE PROGRAM
