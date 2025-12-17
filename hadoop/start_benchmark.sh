#!/bin/bash
set -e

sudo service ssh start
sudo chmod o+w /results

NAMENODE_DIR=/opt/hadoop/data/namenode
if [ ! -d "$NAMENODE_DIR/current" ]; then
    hdfs namenode -format
fi

start-dfs.sh
start-yarn.sh

hadoop fs -mkdir /csv
hadoop fs -put *.csv /csv

echo "Initialization completed"

MAPRED_NUM_REDUCE_TASKS_SET=(1 3 5 10 15 20)
SPLIT_MINSIZE_SET=(1024 2048 8192 32768 131072 262144)

for MAPRED_NUM_REDUCE_TASKS in "${MAPRED_NUM_REDUCE_TASKS_SET[@]}"; do
  for SPLIT_MINSIZE in "${SPLIT_MINSIZE_SET[@]}"; do
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    dir=$timestamp-tasks-$MAPRED_NUM_REDUCE_TASKS-split-$SPLIT_MINSIZE

    echo "Running with MAPRED_NUM_REDUCE_TASKS=$MAPRED_NUM_REDUCE_TASKS SPLIT_MINSIZE=$SPLIT_MINSIZE"
    MAPRED_NUM_REDUCE_TASKS="$MAPRED_NUM_REDUCE_TASKS" SPLIT_MINSIZE="$SPLIT_MINSIZE"

    start_time=$(date +%s%N)
    hadoop jar sales-analyzer-1.0.jar org.itmo.MainJob $MAPRED_NUM_REDUCE_TASKS out /csv/*.csv
    end_time=$(date +%s%N)

    duration_ms=$(($((end_time - start_time)) / 1000000))

    mkdir results/$dir

    echo $duration_ms > results/$dir/time_elapsed_ms

    hadoop fs -get out/part-r-00000 results/$dir/mapred.csv
    sed -i '1i category,revenue,quantity' results/$dir/mapred.csv

    hadoop fs -rm -r out
    hadoop fs -rm -r mapred_out
  done
done

#tail -f /dev/null
