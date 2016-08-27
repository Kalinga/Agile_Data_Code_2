# Load the on-time parquet file
on_time_dataframe = sqlContext.read.parquet('data/on_time_performance.parquet')

# The first step is easily expressed as SQL: get all unique tail numbers for each airline
on_time_dataframe.registerTempTable("on_time_performance")
carrier_airplane = sqlContext.sql(
  "SELECT DISTINCT Carrier, TailNum FROM on_time_performance"
  )

