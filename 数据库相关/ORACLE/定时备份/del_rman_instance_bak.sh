#Rman定时删除备份
#Author:TiAmo
#Date:20220602
#!/bin/bash
removedir=/data/oracle_baks
dt=`date +%Y%m%d -d "30 day ago"`
Rdir=$removedir
for subdir in `ls $Rdir`
do
subdir=`echo ${subdir//.*/}`
#subdir=`echo ${subdir}`
done
if [ "${subdir}" -lt "${dt}" ]
then
rm -rf $Rdir/$subdir.tar.gz >/dev/null
echo "the directory $Rdir/$subdir has been removed;"
else
echo "The $Rdir/$subdir has not been deleted"
echo "current file time:${subdir} ---- Estimated deletion time:${dt};"
fi
