#!/bin/ksh
# Nov. 2014: S. Steinig, W. Park
set -ex
typeset -Z4 yr1 yr2 yr 
typeset -Z2 mm dd
#
CDO=$HOME/bin/cdo
cdr=~smomw014/prg/CDFTOOLS_3.0/bin
varlist="moc psi mhst"
mmlist="01 02 03 04 05 06 07 08 09 10 11 12"
set -A dd_month 00 31 28 31 30 31 30 31 31 30 31 30 31
#
#
happy ( )
{
explist=$1 ; yr1=$2 ; yr2=$3 ; expdir=$4 ; mntdir=$5 ; tm=$6 ; res=$7

for exp in ${explist} ; do
odr=$WORK/wrk/cdf/${exp}
#odr=$WORK/wrk/cdf/${exp}_${tm}
if [ ! -d ${odr}/save ] ; then
  mkdir -p ${odr}/save
fi

opa9dir=$mntdir/prism/${expdir}/${exp}/outdata/opa9

if [ ${tm} = "1m" ] ; then
  idr=${opa9dir}
elif [ ${tm} = "ym" ] ; then
  idr=${opa9dir}/${tm}
  mmlist="01"
else
  echo ' === error: check directory ==='
  exit
fi

cd ${odr}

if [ $res = 'orca2' ] ; then
  ln -fs ${opa9dir}/mesh_mask.nc .
else
  if [ ! -f mesh_mask.nc ] ; then
    nccopy -k 1 ${opa9dir}/mesh_mask.nc mesh_mask.nc
  fi
fi

#${CDO} -r chname,atlmsk_nomed,tmaskatl,indmsk,tmaskind,pacmsk,tmaskpac -delname,atlmsk /gfs/home/smomw014/prg/CDFTOOLS_3.0/dat/orca2_subbasins.nc orca2_subbasins.nc
ln -fs /sfs/fs6/home-geomar/smomw014/prg/CDFTOOLS_3.0/dat/${res}_subbasins_kcm.nc ${res}_subbasins.nc 

yr=${yr1}
while [ ${yr} -le ${yr2} ] ; do

for mm in ${mmlist} ; do
  if [ ${tm} = "1m" ] ; then
    dd=${dd_month[$mm]}
    date=${yr}${mm}01_${yr}${mm}${dd}
    if [ ${mm} = "02" ] && [ ! -f ${idr}/${exp}_${tm}_${date}_grid_T.nc ]; then
      date=${yr}${mm}01_${yr}${mm}29
    fi
  else
    date=${yr}_${yr}
  fi
  inid=${exp}_${tm}_${date}

  if [ $res = 'orca2' ] ; then
    ln -fs ${idr}/${inid}_grid_T.nc .
    ln -fs ${idr}/${inid}_grid_U.nc .
    ln -fs ${idr}/${inid}_grid_V.nc .
#  else
#    nccopy -k 1 ${idr}/${inid}_grid_T.nc ${inid}_grid_T.nc 
#    nccopy -k 1 ${idr}/${inid}_grid_U.nc ${inid}_grid_U.nc 
#    nccopy -k 1 ${idr}/${inid}_grid_V.nc ${inid}_grid_V.nc 
  fi

for var in ${varlist} ; do
  outid=${exp}_${tm}_${yr1}-${yr2}.${var}

  if [ ${yr} -eq ${yr1} ] && [ ${mm} = "01" ] ; then
   rm -f ${outid}.nc
  fi

cp -p ~smomw014/prg/CDFTOOLS_3.0/namelist/nam_cdf_names_kcm nam_cdf_names_kcm
sed -e "s/CN_FBASINS      = orca2_subbasins.nc/CN_FBASINS      = ${res}_subbasins.nc/" \
     nam_cdf_names_kcm > nam_cdf_names_${res}
#    -e "s/CN_T    = time/CN_T    = time_counter/" \

case ${var} in
  moc)
     if [ ! -f save/${inid}.${var}.nc ] ; then
       cp -p nam_cdf_names_${res} nam_cdf_names
       if [ ! -f ${inid}_grid_V.nc ]; then
         nccopy -k 1 ${idr}/${inid}_grid_V.nc ${inid}_grid_V.nc 
       fi
       ${cdr}/cdf${var} ${inid}_grid_V.nc
       mv moc.nc ${inid}.${var}.nc
     fi
  ;;
  psi)
     if [ ! -f save/${inid}.${var}.nc ] ; then
       cp -p ~smomw014/prg/CDFTOOLS_3.0/namelist/nam_cdf_names_kcm nam_cdf_names_kcm
       sed -e "s/CN_Z    = depthv/CN_Z    = depthu/" \
           -e "s/CN_VDEPTHV      = depthv/CN_VDEPTHV      = depthu/" \
           nam_cdf_names_${res} > nam_cdf_names
       if [ ! -f ${inid}_grid_U.nc ]; then
         nccopy -k 1 ${idr}/${inid}_grid_U.nc ${inid}_grid_U.nc
       fi
       if [ ! -f ${inid}_grid_V.nc ]; then
         nccopy -k 1 ${idr}/${inid}_grid_V.nc ${inid}_grid_V.nc
       fi
       ${cdr}/cdf${var} ${inid}_grid_U.nc ${inid}_grid_V.nc
       mv psi.nc ${inid}.${var}.nc
     fi
  ;;
  mhst)
     if [ ! -f save/${inid}.${var}.nc ] ; then
       cp -p ~smomw014/prg/CDFTOOLS_3.0/namelist/nam_cdf_names_kcm nam_cdf_names_kcm
       sed -e "s/CN_Z    = depthv/CN_Z    = deptht/" \
           -e "s/CN_VDEPTHV      = depthv/CN_VDEPTHV      = deptht/" \
           nam_cdf_names_${res} > nam_cdf_names
       if [ ! -f ${inid}_grid_T.nc ]; then
         nccopy -k 1 ${idr}/${inid}_grid_T.nc ${inid}_grid_T.nc
       fi  
       if [ ! -f ${inid}_grid_V.nc ]; then
         nccopy -k 1 ${idr}/${inid}_grid_V.nc ${inid}_grid_V.nc
       fi  
       ${cdr}/cdfvT ${exp}_${tm} ${date}
       ${cdr}/cdf${var} vt.nc
       mv mhst.nc ${inid}.${var}.nc
       rm vt.nc
     fi
  ;;
  *) echo "error: check cdftools functions"
  exit
esac

if [ -f save/${inid}.${var}.nc ]; then
  ${CDO} -r cat save/${inid}.${var}.nc ${outid}.nc
else
  ${CDO} -r cat ${inid}.${var}.nc ${outid}.nc
  mv ${inid}.${var}.nc save/.
fi

done #var

if [ $res = 'orca2' ] ; then
  unlink ${inid}_grid_T.nc
  unlink ${inid}_grid_U.nc
  unlink ${inid}_grid_V.nc
else
  rm -f ${inid}_grid_T.nc
  rm -f ${inid}_grid_U.nc
  rm -f ${inid}_grid_V.nc
fi
done #mm

yr=`expr ${yr} + 1`
done #yr
done #exp
echo '=== SUCCESSFUL END ==='

}

#happy P15 0800 0886 EXP2 $WORK ym orca2
#happy P16 0800 1005 EXP2 $WORK ym orca2
#happy P17 0800 0999 EXP2 $WORK ym orca2
#happy P19 0002 0049 EXP2 $WORK 1m orca05
#happy P20 0030 0049 EXP2 $WORK 1m orca05
#happy P21 0002 0019 EXP2 $WORK 1m orca05
happy P22 0002 0019 EXP2 $WORK 1m orca05
