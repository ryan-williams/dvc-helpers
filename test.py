import pandas as pd

df = pd.DataFrame({
    'num': [111, 222, 333, 444, 555],
    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
})
df.to_parquet('test.parquet', index=False)
