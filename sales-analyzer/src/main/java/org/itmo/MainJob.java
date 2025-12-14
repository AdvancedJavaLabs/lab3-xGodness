package org.itmo;

import org.apache.hadoop.conf.Configuration;
import org.itmo.mapreduce.SalesJob;
import org.itmo.sort.SortJob;

import java.io.IOException;
import java.util.Arrays;

public class MainJob {
    private static final String SPLIT_MINSIZE_ENV_VAR = "SPLIT_MINSIZE";

    public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {
        if (args.length < 3) {
            System.err.println("usage: MainJob <num_reduce_tasks> <output_dir> [...input_paths]");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        conf.set("mapreduce.input.fileinputformat.split.minsize", System.getenv(SPLIT_MINSIZE_ENV_VAR));

        int numReduceTasks = Integer.parseInt(args[0]);
        String mapredOut = "mapred_out";
        String sortOut = args[1];

        int salesJobResult = SalesJob.run(conf, numReduceTasks, mapredOut, Arrays.copyOfRange(args, 2, args.length));
        if (salesJobResult != 0) {
            System.exit(salesJobResult);
        }

        int sortJobResult = SortJob.run(conf, sortOut, mapredOut);
        System.exit(sortJobResult);
    }
}
