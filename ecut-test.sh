#!/bin/bash
name="1.ecut"
s=0; 
kmeshs="2,4,3";
for ecut in {65..100..5}  ; do ecutr=$[ecut*8]
cat > $name.$ecut.in << EOF
&CONTROL
    calculation = "scf"
    max_seconds =  8.64000e+04
    outdir      = "./ecut-test/"
    prefix      = "espresso"
    pseudo_dir  = "/home/maple/.burai/.pseudopot"
    title       = "pristine"
    tprnfor     = .TRUE.
    tstress     = .TRUE.
    wf_collect  = .TRUE.
    wfcdir      = "./ecut-test/"
/

&SYSTEM
    a                         =  9.50090e+00
    b                         =  5.51410e+00
    c                         =  6.83290e+00
    cosab                     =  9.25025e-05
    cosac                     =  1.26066e-01
    cosbc                     = -2.11171e-01
    degauss                   =  1.00000e-02
    ecutrho                   =  ${ecutr}
    ecutwfc                   =  ${ecut}
    hubbard_u(1)              =  3.50000e+00
    hubbard_u(4)              =  5.20000e+00
    ibrav                     = 14
    lda_plus_u                = .TRUE.
    nat                       = 38
    nosym                     = .TRUE.
    nspin                     = 2
    ntyp                      = 5
    occupations               = "smearing"
    smearing                  = "gaussian"
    starting_magnetization(1) =  2.00000e-01
    starting_magnetization(2) =  0.00000e+00
    starting_magnetization(3) =  0.00000e+00
    starting_magnetization(4) =  2.00000e-01
    starting_magnetization(5) =  0.00000e+00
/

&ELECTRONS
    conv_thr         =  1.00000e-06
    diago_david_ndim = 4
    diagonalization  = "david"
    electron_maxstep = 200
    mixing_beta      =  4.00000e-01
    mixing_mode      = "plain"
    mixing_ndim      = 8
    startingpot      = "atomic"
    startingwfc      = "atomic+random"
/

K_POINTS {automatic} 
$kmeshs ${s} ${s} ${s} 

ATOMIC_SPECIES
Co     58.93320  Co.pbe-n-kjpaw_psl.1.0.0.UPF
H       1.00794  H.pbe-kjpaw_psl.1.0.0.UPF
Na     22.98977  Na.pbe-spn-kjpaw_psl.1.0.0.UPF
Ni     58.69340  Ni.pbe-n-kjpaw_psl.1.0.0.UPF
O      15.99940  O.pbe-n-kjpaw_psl.1.0.0.UPF

ATOMIC_POSITIONS {angstrom}
Ni      1.801852   3.051974   4.749760
Ni      6.544947   3.052468   4.766980
H       0.906303   0.495424   0.650512
H       3.191878   4.232037   0.663493
H       8.911248   3.165529   0.677534
H       6.685775   1.435244   0.686210
H       0.948140   0.445959   2.207251
H       3.194124   4.218584   2.225531
H       6.708553   1.394884   2.238115
H       8.895519   3.149464   2.240168
Na      3.720749   1.517109   1.421762
Na      6.158189   4.233387   1.473753
Co      8.924220   1.678476   4.754528
Co      8.917340   4.430253   4.755191
Co      4.183909   1.671164   4.757972
Co      4.177668   4.429505   4.759893
Co      1.805991   0.300544   4.760158
Co      6.541989   0.291156   4.763006
O       1.523414   0.546972   1.416133
O       3.738753   3.958733   1.440836
O       8.310436   3.228537   1.454082
O       6.141014   1.156769   1.462229
O       4.961621   0.283885   3.761010
O       2.611571   1.666285   3.762202
O       9.717702   0.296068   3.765580
O       4.958583   3.050973   3.767832
O       9.698833   3.053966   3.769024
O       7.329445   4.441851   3.769090
O       2.592865   4.445667   3.776376
O       7.340379   1.663798   3.778429
O       3.399041   3.047422   5.737185
O       1.008470   1.668878   5.737781
O       1.000338  -1.073610   5.740033
O       8.132591   0.297078   5.743609
O       8.143365   3.056631   5.747053
O       3.394618   0.302662   5.757716
O       5.763696   1.654188   5.759902
O       5.740478  -1.073846   5.760100


EOF
mpirun -np 12 pw.x <$name.$ecut.in> $name.$ecut.out & 
tail -f --pid=$(ps -elf |grep pw.x|grep -v grep |head -n 1 |awk '{print $4}') $name.$ecut.out
echo "ecutwfc=$ecut" >>ecutwfc-energy
grep ! $name.$ecut.out >>ecutwfc-energy
grep time $name.$ecut.out|tail -n 1 >>ecutwfc-energy
done
