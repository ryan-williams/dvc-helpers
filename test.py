from os import makedirs

import pandas as pd

makedirs('data', exist_ok=True)

df = pd.DataFrame({
    'num': [111, 222, 333, 444, 555],
    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
}).astype({ 'num': 'int32' })
df.to_parquet('data/test.parquet', index=False)

with open('data/test.txt', 'w') as f:
    for i in range(10):
        print(f"{i}", file=f)
