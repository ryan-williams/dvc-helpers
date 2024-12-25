from os import makedirs

import pandas as pd

makedirs('data', exist_ok=True)

df = pd.DataFrame({
    'num': [11, 22, 33, 44, 55],
    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
}).astype({ 'num': 'int32' })
df.to_parquet('data/test.parquet', index=False)

with open('data/test.txt', 'w') as f:
    for i in range(15):
        print(f"{i}", file=f)
