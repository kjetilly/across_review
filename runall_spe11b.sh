# Yes, we still call this SPE11C_RESOLUTION
export ACROSS_SPE11C_RESOLUTION='840,1,120' 

cd /home/kjetil/projects/across/workflow/across_review/;
./installdir/bin/hq server stop --server-dir /home/kjetil/.hq-server
killall dask-scheduler
killall dask-worker
ps aux|grep machine_learning_across.py|awk '{system("kill -9 "$2)}'
rm -rf outputdir_spe11b
mkdir -p outputdir_spe11b
cd outputdir_spe11b
cp -r ../spe11b ./spe11b
bash ../workflow_bash/run_workflow_from_spe11.sh ../installdir/ $(realpath spe11b)
cd -
