import sys
from pyspark.context import SparkContext
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import *
from awsglue.job import Job

## @params: [JOB_NAME,INPUT_PATH,OUTPUT_PATH]
# Note: getResolvedOptions requires the input parameters to have underscore
# so that '--input_path' will get resolved as 'input_path'
# Refer: https://docs.amazonaws.cn/en_us/glue/latest/dg/aws-glue-api-crawler-pyspark-extensions-get-resolved-options.html
args = getResolvedOptions(sys.argv, [
	'JOB_NAME',
	'input_path',
	'output_path',
	'number_of_partitions'
])

glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

inputPath = args['input_path']
outputPath = args['output_path']
numberOfPartitions = int(args.get('number_of_partitions', 1))

input_dyf = glueContext.create_dynamic_frame_from_options("s3", {
		"paths": [ inputPath ],
		"recurse": True,
		"groupFiles": "inPartition"
	},
	format = "parquet"
)

repartitionedDYF = input_dyf.repartition(numberOfPartitions)
glueContext.write_dynamic_frame.from_options(
	frame = repartitionedDYF,
	connection_type = "s3",
	connection_options = {"path": outputPath},
	format = "glueparquet"
)

job.commit()