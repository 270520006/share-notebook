#Rman增量备份
#Author:TiAmo
#Date:20220602
#! /bin/bash
export NLS_LANG='AMERICAN_AMERICA.ZHS16GBK'
source /home/oracle/.bash_profile
current_day=`date +%Y%m%d`
if [ ! -d /data/oracle_baks/$current_day ]
then
    mkdir -p /data/oracle_baks/$current_day
rman target / <<EOF
run{
allocate channel d1 type disk;
allocate channel d2 type disk;
backup as compressed backupset incremental level 1 cumulative database format '/data/oracle_baks/$current_day/ORCL_L1_incr_%s_%d_%T_%u.bkp';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup archivelog all format '/data/oracle_baks/$current_day/ORCL_arclog_incr_%s_%d_%T_%u.bkp' not backed up 1 times;
backup spfile format '/data/oracle_baks/$current_day/ORCL_spfile_incr_%s_%d_%T_%u.bkp';
backup current controlfile format '/data/oracle_baks/$current_day/ORCL_controlfile_incr_%s_%d_%T_%u.bkp';
delete noprompt ARCHIVELOG until time 'SYSDATE-7';
crosscheck archivelog all;
delete noprompt expired archivelog all;
crosscheck backup;
delete expired backup;
release channel d1;
release channel d2;
}
EOF
else
    echo "Database incremental backup on $current_day has been completed;"
fi
cd /data/oracle_baks
tar -zcvf $current_day.tar.gz $current_day
rm -rf $current_day
