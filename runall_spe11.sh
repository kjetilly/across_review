cd /home/kjetil/projects/across/workflow/across_review/;
./installdir/bin/hq server stop --server-dir /home/kjetil/.hq-server
killall dask-scheduler
killall dask-worker
ps aux|grep machine_learning_across.py|awk '{system("kill -9 "$2)}'
rm -rf outputdir_spe11
mkdir -p outputdir_spe11
cd outputdir_spe11
cp -r ../spe11 ./spe11
bash ../workflow_bash/run_workflow_from_spe11.sh ../installdir/ $(realpath spe11)
cd -
