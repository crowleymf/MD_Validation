#!/usr/bin/perl -w
use strict;


# Notes from Xiaohu Hu (x.hu1982@gmail.com):
# gromacs needs to be installed and user needs to specify the path of gromacs 
# tools binaries first.
my $gmx_path="/usr/local/gromacs/bin";


# some global variables
my $input_struct;
my $forcefield;
my $system_name;

my $command; 
my $output;

my @raw_data;
my $line;

my $natoms;

# parse the command line input
my $nargs=@ARGV;

if ($nargs!=3) { 
        die "\nSynthax error: 3 arguments required!\n".
            "Example: ./do_benchmark struct.gro force_field system_name\n\n";
}

$input_struct = $ARGV[0];
if ($input_struct !~ /[A-Za-z0-9-]+.pdb/) {
    die "\nInput error: input structure must be a *.gro file\n\n!";
}

$forcefield = $ARGV[1];
if ($forcefield !~ /[A-Za-z0-9-]/) {
    die "\nInput error: force field name must be a string\n\n!";
}

$system_name = $ARGV[2];
if ($system_name !~ /[A-Za-z0-9-]/) {
    die "\nInput error: system name must be a string\n\n!";
}

# create gromacs toplogy  and structure files
$command = "echo 6 | $gmx_path/pdb2gmx ".
           "-f $input_struct ".
           "-ff $forcefield ".
           "-p $system_name\_$forcefield.top ".
           "-o $system_name\_$forcefield.gro";
$output = `$command`;
print "$output\n";

# get the total atom number
open(STRUCT, "< $system_name\_$forcefield.gro");
@raw_data=<STRUCT>;
$natoms = $raw_data[1];
close(STRUCT);

# create the md protocol file for the benchmark run
$command = "integrator = md \n".
           "nsteps = 0 \n".
           "nstlog = 1 \n".
           "nstenergy = 1 \n".
           "nstfout = 1 \n".
           "nstxout = 1 \n".
           "nstvout = 1 \n".
           "rlist = 99 \n".
           "coulombtype = cutoff \n".
           "rcoulomb = 99 \n".
           "vdw-type = switch \n".
           "rvdw_switch = 98 \n".
           "rvdw = 99 \n".
           "pbc = no \n".
           "tcoupl = no \n".
           "gen_vel = yes \n".
           "gen_seed = 73927 \n".
           "gen_temp = 300 \n";

open(MDP, "> benchmark.mdp")
    or die "\nCannot write \"benchmark.mdp\": $!\n\n";
printf(MDP "$command");
close(MDP);

# create the gromacs tpr file
$command = "$gmx_path/grompp ".
           "-f benchmark.mdp ".
           "-p $system_name\_$forcefield.top ".
           "-c $system_name\_$forcefield.gro ".
           "-o benchmark.tpr";
$output=`$command`;
print "$output\n";

# run benchmark only if tpr file generation successful
die "Error: grompp failed to generate the tpr file\n\n" if ($? != 0); 
$command = "$gmx_path/mdrun -s benchmark.tpr";
$output = `$command`;
print"$output\n";

# read out the energies
$command = "echo 1 2 3 4 5 6 7 8 9 10 | g_energy ".
           "-f ener.edr -o tmp_ener.xvg > ener.tmp";
$output = `$command`;
print "$output\n";

open(ENER, "< ener.tmp")
    or die ("Error: Cannot open file \"ener.tmp\"\n\n");
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

# extract the energy value and convert from kJ/mol (gromacs energy unit) into kcal/mol
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
    or die "Error: Cannot open the file \"forces.xvg\"\n\n";
@raw_data = <FORCES>;
close(FORCES);

# Write out the results
open(OUTPUT, "> $system_name\_$forcefield.frcdmp");
printf(OUTPUT "NATOM %7d\n", $natoms);
printf(OUTPUT "ENERGY\n");
printf(OUTPUT "  ENER    %7.15e\n", $ener);
printf(OUTPUT "  BOND    %7.15e\n", $bond);
printf(OUTPUT "  ANGL    %7.15e\n", $angl);
printf(OUTPUT "  UREY    %7.15e\n", $urey);
printf(OUTPUT "  DIHE    %7.15e\n", $dihe);
printf(OUTPUT "  IMPR    %7.15e\n", $impr);
printf(OUTPUT "  VDW     %7.15e\n", $vdw);
printf(OUTPUT "  ELEC    %7.15e\n", $elec);
printf(OUTPUT "  CMAP    %7.15e\n", $cmap);
printf(OUTPUT "FORCE\n");

foreach $line (@raw_data) {

    my $atomid;
    my $force_x;
    my $force_y;
    my $force_z;

    if ($line !~ m/@/ && $line !~ m/#/) {
        ($atomid,$force_x,$force_y,$force_z) = split(" ",$line);
        printf(OUTPUT "%7d   %7.15e   %7.15e   %7.15e \n",$atomid,$force_x,$force_y,$force_z);
    }
}

close(OUTPUT);

# delete all temp. files
system("rm tmp_ener.xvg ener.tmp forces.xvg force.pdb");

# END OF THE PROGRAM
