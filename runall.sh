cd /home/kjetil/projects/across/workflow/across_review/;
./installdir/bin/hq server stop --server-dir /home/kjetil/.hq-server
killall dask-scheduler
killall dask-worker
ps aux|grep machine_learning_across.py|awk '{system("kill -9 "$2)}'
rm -r generated_highres_spe1
python generate_case/generate_case.py -x 2 -y 2 -z 10 # -x 32 -y 32 -z 30 #-x 2 -y 2 -z 10 #
cp generated_highres_spe1/FLOW ./
rm -rf outputdir
mkdir -p outputdir
cd outputdir
bash ../workflow_bash/run_workflow_from_generated.sh ../installdir/ $(realpath ../generated_highres_spe1/)
cd -
