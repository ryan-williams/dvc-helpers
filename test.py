import pandas as pd

df = pd.DataFrame({
    'num': [111, 222, 333, 444, 555, 666, 777, 888],
    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee', 'fff', 'ggg', 'hhh'],
}).astype({ 'num': 'int32' })
df.to_parquet('test.parquet', index=False)
