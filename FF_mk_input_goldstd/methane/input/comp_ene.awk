BEGIN{impr=0.0000}
/ENER INTERN>/{
  cbnd=$3;
  cang=$4;
  cub=$5;
  cdih=$6;
  cimpr=$7;
#  print "charmm", $3,$4,$5,$6,$7;
}
/ENER EXTERN/{cvdw=$3;celec=$4;}

/ BOND /{bnd=$3; ang=$6; dih=$9}
/1-4/ {nb14=$4;ee14=$8;vdw=$11;}
/EELEC/{elec=$3;}

END{
    printf( "            amb         chm    difference \n");
    printf( "BOND  %10.4f %10.4f %10.4f \n",bnd,cbnd,bnd-cbnd);
    printf ("ANGLE %10.4f %10.4f %10.4f          ang,ub  %10.4f %10.4f \n",
	    ang,cang+cub,ang-cang-cub,cang,cub);
    printf ("DIHED %10.4f %10.4f %10.4f \n",dih,cdih,dih-cdih);
    printf ("IMPR  %10.4f %10.4f %10.4f \n",impr,cimpr,impr-cimpr);
    printf ("ELEC  %10.4f %10.4f %10.4f    amb elec,ee14 %10.4f %10.4f\n",
	    celec,elec+ee14 ,celec-elec-ee14 ,elec,ee14 );
    printf ("VDW   %10.4f %10.4f %10.4f    amb vdw,14vdw %10.4f %10.4f\n",
	    cvdw,vdw+nb14,cvdw-vdw-nb14, vdw,nb14);
  print "   " 
}
