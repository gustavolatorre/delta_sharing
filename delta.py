import delta_sharing as ds

profile = 'config.share'
client = ds.SharingClient(profile)

share_name = 'taxis'
schema_name = 'nyctaxis'
table_name = 'yellowtaxisample'
table_url = f'{profile}#{share_name}.{schema_name}.{table_name}'

df = ds.load_as_pandas(table_url)
df.to_parquet('taxi.parquet', index=False, compression='gzip')
