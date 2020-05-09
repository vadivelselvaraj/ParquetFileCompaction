# ParquetFileCompaction
Compacts parquet files present in an S3 location using AWS Glue job

# Setup
After cloning the repo, run the below.
- Review the cloudformation stack parameters under `Job Parameters` of the `manager.sh` file.
- Create the cloudformation stack.
```bash
./manager.sh create-stack
```
- Run compaction job
```bash
./manager.sh run-compaction s3://PATH_WITH_MULTIPLE_FILES s3://READ_OPTIMIZED_STORAGE_PATH
```
**Note:** The S3 path location shouldn't end with a slash.

## Maintenance
- After updating any cloudformation stack parameters, update it using the below.
```bash
./manager.sh update-stack
```
- Delete the cloudformation stack.
```bash
./manager.sh delete-stack
```
