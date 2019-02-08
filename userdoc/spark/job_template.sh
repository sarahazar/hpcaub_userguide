#BSUB -J spark
#BSUB -n 32
#BSUB -q 6-hours
#BSUB -oo lsf_spark.o%J
#BSUB -eo lsf_spark.e%J
#BSUB -N
#BSUB -u foo0@aub.edu.lb
#BSUB -R "span[ptile=16]"

## WARNING: please change these port number to
##   anything larger than 10000, other than the
##   values set below
export SPARK_MASTER_PORT=11083
export SPARK_MASTER_WEBUI_PORT=11099
export JUPYTER_PORT=11087


####################################################
## do not modify the script below here unless you ##
## know what you are doing                        ##
####################################################
SPARK_HOME=${HOME}/spark-2.3.2-bin-hadoop2.7
source ${SPARK_HOME}/conf/spark-env.sh

# generate the hostnames file with the infiniband hostnames
SPARK_HOSTS=spark_hosts.out
rm -f ${SPARK_HOSTS}
for line in `cat ${LSB_DJOB_RANKFILE} | uniq` ; do
    echo ${line}-ib0 >> ${SPARK_HOSTS}
done

export SPARK_MASTER_HOST=$(head -n 1 ${SPARK_HOSTS})
export SPARK_SLAVES=${SPARK_HOSTS}

echo "spark_job_userspace.sh: launch the master"
start-master.sh --host ${SPARK_MASTER_HOST}
echo "spark_job_userspace.sh: launch the slaves"
start-slaves.sh

echo "create the reverse tunnel for the master web ui"
ssh -R localhost:${SPARK_MASTER_WEBUI_PORT}:localhost:${SPARK_MASTER_WEBUI_PORT} head2 -N -f

module load python/3
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
PYTHONPATH=${SPARK_HOME}/python:${PYTHONPATH}
PYTHONPATH=${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip:${PYTHONPATH}
export PYTHONPATH
jupyter-lab  --no-browser --port=${JUPYTER_PORT} > jupyter.log 2>&1 &
ssh -R localhost:${JUPYTER_PORT}:localhost:${JUPYTER_PORT} head2 -N -f

sleep infinity
