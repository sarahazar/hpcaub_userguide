Scientific computing with Spark
-------------------------------

The current ``spark`` configuration should be set up by users via the existing
scheduler that runs on the HPC cluster. The instructions can be used to deploy a
spark server (cluster) that runs through the HPC cluster's scheduler. The
scheduler allocates the machines where the spark cluster will run. Beyond that
these allocated resources are managed by spark.

Setup the spark environment and launch the spark cluster
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

To launch a spark cluster with a jupyter notebook and pyspark the following
commands should be executed:

.. code-block:: bash

    cd ~/
    tar -xzvf /gpfs1/apps/sw/spark/spark-2.3.2-bin-hadoop2.7-userspace.tgz
    mv spark-2.3.2-bin-hadoop2.7-userspace spark-2.3.2-bin-hadoop2.7
    mkdir ~/workdir
    cd ~/workdir
    cp /gpfs1/apps/sw/spark/*.sh /gpfs1/apps/sw/spark/*.ipynb ~/workdir
    mv job_template.sh job.sh
    # edit the port numbers in job.sh and the email address
    bsub < job.sh

Connect to the spark web ui and jupyter notebook server
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

To connect to the spark master web UI and to the jupter notebook, create tunnels
by forwarding the local network traffic to the spark master port and the jupyter
server ports that are specified in ``job.sh``. The url for the jupter notebook
is dumped to ``jupyter.log`` in the ``workdir``.

.. code-block:: text

     # spark master web ui
     http://localhost:[PORT_USED_FOR_THE_WEBUI]
     # jupyter notebook with pyspark enabled
     http://localhost:[PORT_USED_FOR_JUPYTER]/?token=[TOKEN_FROM_jupyter.log]

Cleanup the spark master and slaves
+++++++++++++++++++++++++++++++++++

To terminate the spark cluster execute:

.. code-block:: bash

     ~/workdir/killall_java.sh

note that this command is just a simple wrapper that kills all java processess
for the user on all the compute nodes. This is a temporary solution. In the
future this script will be replaced by the appropriate spark calls for
terminating the master and the slaves.

It is recommended to check the disk usage of the directories
``${SPARKHOME}/log`` and ``${SPARKHOME}/work`` and wipe them if their size
becomes too big or if the logs and the data in the ``work`` dir are not needed.

The content of the template job script
++++++++++++++++++++++++++++++++++++++

.. literalinclude:: spark/job_template.sh
   :linenos:
   :language: bash