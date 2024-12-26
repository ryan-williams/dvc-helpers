# dvc-helpers
Bash scripts/aliases and `git {diff,show}` plugins for [DVC] files.

<!-- toc -->
- [`git {diff,show}` plugins](#git)
    - [Setup](#diff-setup)
    - [Examples](#examples)
        - [Add text file](#add-txt)
        - [Update text file](#update-txt)
        - [Add Parquet file](#add-pqt)
        - [Update Parquet file](#update-pqt)
        - [Add directory, remove files](#add-dir)
        - [Update files in DVC-tracked directory](#update-dir)
- [Other Bash DVC scripts/aliases](#aliases)
<!-- /toc -->

## `git {diff,show}` plugins <a id="git"></a>
[`git-diff-dvc.sh`] and [`git-textconv-dvc.sh`] can be used to render human-readable `git diff` and `git show` summaries of DVC-tracked files and directories.

### Setup <a id="diff-setup"></a>
```bash
# From a clone of this repo: ensure git-diff-dvc.sh is on your $PATH
echo "export PATH=$PATH:$PWD" >> ~/.bashrc && . ~/.bashrc

# Git configs
git config --global diff.dvc.command git-diff-dvc.sh       # For git diff
git config --global diff.dvc.textconv git-textconv-dvc.sh  # For git show

# Git attributes (map globs/extensions to commands above):
git config --global core.attributesfile ~/.gitattributes
echo "*.dvc diff=dvc" >> ~/.gitattributes

# Or, configure just the current repo:
git config diff.dvc.command git-diff-dvc.sh       # For git diff
git config diff.dvc.textconv git-textconv-dvc.sh  # For git show
echo "*.dvc diff=dvc" >> .gitattributes
```

### Examples <a id="examples"></a>
Using commits from the [@test] branch:

#### Add text file <a id="add-txt"></a>
[`3fe0e6e`] added a DVC-tracked text file, `test.txt` (with `test.txt.dvc` committed to Git):
<!-- `bmdff -stdiff git diff 3fe0e6e^..3fe0e6e` -->
```bash
git diff '3fe0e6e^..3fe0e6e'
```
```diff
diff --git .gitignore .gitignore
new file mode 100644
index 0000000..341707b
--- /dev/null
+++ .gitignore
@@ -0,0 +1 @@
+/test.txt
test.txt
--- /dev/null .
+++ .dvc/cache/files/md5/3b/0332e02daabf31651a5a0d81ba830a f8af2eab0b7cb904c4fa697593684bbf716f091b
diff --git b/test.txt b/test.txt
new file mode 100644
index 0000000..f00c965
--- /dev/null
+++ b/test.txt
@@ -0,0 +1,10 @@
+1
+2
+3
+4
+5
+6
+7
+8
+9
+10
```

<!-- `bmdfff -stdiff git show 3fe0e6e` -->
<details><summary><code>git show 3fe0e6e</code></summary>

```diff
commit 3fe0e6e8b81c7e6783b7eeb1ad822f22c7f25135
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 10:01:22 2024 -0500

    add `test.txt.dvc`

diff --git .gitignore .gitignore
new file mode 100644
index 0000000..341707b
--- /dev/null
+++ .gitignore
@@ -0,0 +1 @@
+/test.txt
diff --git test.txt.dvc test.txt.dvc
new file mode 100644
index 0000000..f8af2ea
--- /dev/null
+++ test.txt.dvc
@@ -0,0 +1,12 @@
+
+test.txt .dvc/cache/files/md5/3b/0332e02daabf31651a5a0d81ba830a
+1
+2
+3
+4
+5
+6
+7
+8
+9
+10
```
</details>


#### Update text file <a id="update-txt"></a>
[`c8af3fe`] appended some lines to `test.txt`:
<!-- `bmdff -stdiff git diff c8af3fe^..c8af3fe` -->
```bash
git diff 'c8af3fe^..c8af3fe'
```
```diff
test.txt
--- .dvc/cache/files/md5/3b/0332e02daabf31651a5a0d81ba830a f8af2eab0b7cb904c4fa697593684bbf716f091b
+++ .dvc/cache/files/md5/fc/a18e3023be1c0a6e14ca2003b1524a 0ceff0bc7527454d140941483082b9cb892ffab2
diff --git a/test.txt b/test.txt
index f00c965..97b3d1a 100644
--- a/test.txt
+++ b/test.txt
@@ -8,3 +8,8 @@
 8
 9
 10
+11
+12
+13
+14
+15
```

<!-- `bmdfff -stdiff git show c8af3fe` -->
<details><summary><code>git show c8af3fe</code></summary>

```diff
commit c8af3fea8a57e26596cac0d7cded640047734db1
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 12:15:55 2024 -0500

    `seq 15 > test.txt`

diff --git test.txt.dvc test.txt.dvc
index f8af2ea..0ceff0b 100644
--- test.txt.dvc
+++ test.txt.dvc
@@ -1,5 +1,5 @@
 
-test.txt .dvc/cache/files/md5/3b/0332e02daabf31651a5a0d81ba830a
+test.txt .dvc/cache/files/md5/fc/a18e3023be1c0a6e14ca2003b1524a
 1
 2
 3
@@ -10,3 +10,8 @@ test.txt .dvc/cache/files/md5/3b/0332e02daabf31651a5a0d81ba830a
 8
 9
 10
+11
+12
+13
+14
+15
```
</details>

#### Add Parquet file <a id="add-pqt"></a>
`git-diff-dvc.sh` delegates to other diff drivers that you can configure, for file types (based on path names). For example, if [`git-diff-parquet.sh`] is configured, you get a nice rendering of [`3dc5466`] adding `test.parquet`;

<!-- `bmdff -stdiff -- git diff 3dc5466^..3dc5466 -- test.parquet.dvc` -->
```bash
git diff '3dc5466^..3dc5466' -- test.parquet.dvc
```
```diff
test.parquet
--- /dev/null .
+++ .dvc/cache/files/md5/43/79600b26647a50dfcd0daa824e8219 33d076033596bcccf90a442c58eb83f44499ea40
diff --git b/test.parquet b/test.parquet
new file mode 100644
index 0000000..918850d
--- /dev/null
+++ b/test.parquet
@@ -0,0 +1,15 @@
+MD5: 4379600b26647a50dfcd0daa824e8219
+1635 bytes
+5 rows
+message schema {
+  OPTIONAL INT64 num;
+  OPTIONAL BYTE_ARRAY str (STRING);
+}
+{
+  "num": 111,
+  "str": "aaa"
+}
+{
+  "num": 222,
+  "str": "bbb"
+}
```

<!-- `bmdfff -stdiff git show 3dc5466` -->
<details><summary><code>git show 3dc5466</code></summary>

```diff
commit 3dc5466a86cb2ff96dd6198af3c6fc348af3f8cc
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 12:32:31 2024 -0500

    add `test.parquet.dvc`

diff --git .gitignore .gitignore
index 341707b..a35ca01 100644
--- .gitignore
+++ .gitignore
@@ -1 +1,2 @@
 /test.txt
+/test.parquet
diff --git test.parquet.dvc test.parquet.dvc
new file mode 100644
index 0000000..33d0760
--- /dev/null
+++ test.parquet.dvc
@@ -0,0 +1,17 @@
+
+test.parquet .dvc/cache/files/md5/43/79600b26647a50dfcd0daa824e8219
+MD5: 4379600b26647a50dfcd0daa824e8219
+1635 bytes
+5 rows
+message schema {
+  OPTIONAL INT64 num;
+  OPTIONAL BYTE_ARRAY str (STRING);
+}
+{
+  "num": 111,
+  "str": "aaa"
+}
+{
+  "num": 222,
+  "str": "bbb"
+}
diff --git test.py test.py
new file mode 100644
index 0000000..fcfac0e
--- /dev/null
+++ test.py
@@ -0,0 +1,7 @@
+import pandas as pd
+
+df = pd.DataFrame({
+    'num': [111, 222, 333, 444, 555],
+    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
+})
+df.to_parquet('test.parquet', index=False)
```
</details>

#### Update Parquet file <a id="update-pqt"></a>
[`ab90427`] updated `test.parquet`, appending 3 rows and changing a dtype (from `int64` to `int32`):

<!-- `bmdff -stdiff -- git diff ab90427^..ab90427 -- test.parquet.dvc` -->
```bash
git diff 'ab90427^..ab90427' -- test.parquet.dvc
```
```diff
test.parquet
--- .dvc/cache/files/md5/43/79600b26647a50dfcd0daa824e8219 33d076033596bcccf90a442c58eb83f44499ea40
+++ .dvc/cache/files/md5/be/082c87786f3364ca9efec061a3cc21 718c8cd68af7fc28fb60e8ab1ee678a03cda86fe
a/test.parquet..b/test.parquet
1,3c1,3
< MD5: 4379600b26647a50dfcd0daa824e8219
< 1635 bytes
< 5 rows
---
> MD5: be082c87786f3364ca9efec061a3cc21
> 1622 bytes
> 8 rows
5c5
<   OPTIONAL INT64 num;
---
>   OPTIONAL INT32 num;

```


<!-- `bmdfff -stdiff git show ab90427` -->
<details><summary><code>git show ab90427</code></summary>

```diff
commit ab904274b2bfd259cc9ed7278dde187cf05ae813
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 12:34:53 2024 -0500

    append to `test.parquet`, change "num" to int32

diff --git test.parquet.dvc test.parquet.dvc
index 33d0760..718c8cd 100644
--- test.parquet.dvc
+++ test.parquet.dvc
@@ -1,10 +1,10 @@
 
-test.parquet .dvc/cache/files/md5/43/79600b26647a50dfcd0daa824e8219
-MD5: 4379600b26647a50dfcd0daa824e8219
-1635 bytes
-5 rows
+test.parquet .dvc/cache/files/md5/be/082c87786f3364ca9efec061a3cc21
+MD5: be082c87786f3364ca9efec061a3cc21
+1622 bytes
+8 rows
 message schema {
-  OPTIONAL INT64 num;
+  OPTIONAL INT32 num;
   OPTIONAL BYTE_ARRAY str (STRING);
 }
 {
diff --git test.py test.py
index fcfac0e..8721b78 100644
--- test.py
+++ test.py
@@ -1,7 +1,7 @@
 import pandas as pd
 
 df = pd.DataFrame({
-    'num': [111, 222, 333, 444, 555],
-    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
-})
+    'num': [111, 222, 333, 444, 555, 666, 777, 888],
+    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee', 'fff', 'ggg', 'hhh'],
+}).astype({ 'num': 'int32' })
 df.to_parquet('test.parquet', index=False)
```
</details>

[`$PQT_TXT_OPTS`] can be used to customize how Parquet files are converted to text (before being compared):

<!-- `bmdff -stdiff -EPQT_TXT_OPTS="-sn -1" -- git diff ab90427^..ab90427 -- test.parquet.dvc` -->
```bash
PQT_TXT_OPTS=-sn -1 git diff 'ab90427^..ab90427' -- test.parquet.dvc
```
```diff
test.parquet
--- .dvc/cache/files/md5/43/79600b26647a50dfcd0daa824e8219 33d076033596bcccf90a442c58eb83f44499ea40
+++ .dvc/cache/files/md5/be/082c87786f3364ca9efec061a3cc21 718c8cd68af7fc28fb60e8ab1ee678a03cda86fe
a/test.parquet..b/test.parquet
1,3c1,3
< MD5: 4379600b26647a50dfcd0daa824e8219
< 1635 bytes
< 5 rows
---
> MD5: be082c87786f3364ca9efec061a3cc21
> 1622 bytes
> 8 rows
5c5
<   OPTIONAL INT64 num;
---
>   OPTIONAL INT32 num;
12a13,15
> {"num":666,"str":"fff"}
> {"num":777,"str":"ggg"}
> {"num":888,"str":"hhh"}

```

`-s` renders one object per line (instead of one field), and `-n -1` means "print all the rows" (before a diff is performed).

#### Add directory, remove files <a id="add-dir"></a>
[`d760752`] moved `test.txt` and `test.parquet` into a new DVC-tracked directory, `data/` (with tracking file `data.dvc`):

<!-- `bmdff -stdiff -- git diff d760752^..d760752 -- data.dvc` -->
```bash
git diff 'd760752^..d760752' -- data.dvc
```
```diff
data
--- /dev/null .
+++ .dvc/cache/files/md5/63/9653e88148f06346d0b965fd0318cc.dir e9c2c3a1ce3f416a21df573905667f4083122bc3
1c1,4
< {}
---
> {
>   "test.parquet": "c07bba3fae2b64207aa92f422506e4a2",
>   "test.txt": "e20b902b49a98b1a05ed62804c757f94"
> }

data/test.parquet
--- /dev/null null
+++ .dvc/cache/files/md5/c0/7bba3fae2b64207aa92f422506e4a2 c07bba3fae2b64207aa92f422506e4a2
diff --git b/data/test.parquet b/data/test.parquet
new file mode 100644
index 0000000..0109fa9
--- /dev/null
+++ b/data/test.parquet
@@ -0,0 +1,15 @@
+MD5: c07bba3fae2b64207aa92f422506e4a2
+1592 bytes
+5 rows
+message schema {
+  OPTIONAL INT32 num;
+  OPTIONAL BYTE_ARRAY str (STRING);
+}
+{
+  "num": 111,
+  "str": "aaa"
+}
+{
+  "num": 222,
+  "str": "bbb"
+}


data/test.txt
--- /dev/null null
+++ .dvc/cache/files/md5/e2/0b902b49a98b1a05ed62804c757f94 e20b902b49a98b1a05ed62804c757f94
diff --git b/data/test.txt b/data/test.txt
new file mode 100644
index 0000000..8b1acc1
--- /dev/null
+++ b/data/test.txt
@@ -0,0 +1,10 @@
+0
+1
+2
+3
+4
+5
+6
+7
+8
+9

```

Notice how both `data/test.{txt,parquet}` are rendered (the latter using the appropriate diff driver).

The full commit also shows the previous `test.{txt,parquet}` files as deleted:

<!-- `bmdfff -stdiff git show d760752` -->
<details><summary><code>git show d760752</code></summary>

```diff
commit d760752ef1dbb4a4c7ff2c75228097549c9c8080
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 13:03:28 2024 -0500

    mv `test.{txt,parquet}.dvc` into dvc-tracked dir `data/`

diff --git .gitignore .gitignore
index a35ca01..3af0ccb 100644
--- .gitignore
+++ .gitignore
@@ -1,2 +1 @@
-/test.txt
-/test.parquet
+/data
diff --git data.dvc data.dvc
new file mode 100644
index 0000000..e9c2c3a
--- /dev/null
+++ data.dvc
@@ -0,0 +1,29 @@
+
+test.parquet .dvc/cache/files/md5/c0/7bba3fae2b64207aa92f422506e4a2
+MD5: c07bba3fae2b64207aa92f422506e4a2
+1592 bytes
+5 rows
+message schema {
+  OPTIONAL INT32 num;
+  OPTIONAL BYTE_ARRAY str (STRING);
+}
+{
+  "num": 111,
+  "str": "aaa"
+}
+{
+  "num": 222,
+  "str": "bbb"
+}
+
+test.txt .dvc/cache/files/md5/e2/0b902b49a98b1a05ed62804c757f94
+0
+1
+2
+3
+4
+5
+6
+7
+8
+9
diff --git test.parquet.dvc test.parquet.dvc
deleted file mode 100644
index 718c8cd..0000000
--- test.parquet.dvc
+++ /dev/null
@@ -1,17 +0,0 @@
-
-test.parquet .dvc/cache/files/md5/be/082c87786f3364ca9efec061a3cc21
-MD5: be082c87786f3364ca9efec061a3cc21
-1622 bytes
-8 rows
-message schema {
-  OPTIONAL INT32 num;
-  OPTIONAL BYTE_ARRAY str (STRING);
-}
-{
-  "num": 111,
-  "str": "aaa"
-}
-{
-  "num": 222,
-  "str": "bbb"
-}
diff --git test.py test.py
index 8721b78..065a6f3 100644
--- test.py
+++ test.py
@@ -1,7 +1,15 @@
+from os import makedirs
+
 import pandas as pd
 
+makedirs('data', exist_ok=True)
+
 df = pd.DataFrame({
-    'num': [111, 222, 333, 444, 555, 666, 777, 888],
-    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee', 'fff', 'ggg', 'hhh'],
+    'num': [111, 222, 333, 444, 555],
+    'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
 }).astype({ 'num': 'int32' })
-df.to_parquet('test.parquet', index=False)
+df.to_parquet('data/test.parquet', index=False)
+
+with open('data/test.txt', 'w') as f:
+    for i in range(10):
+        print(f"{i}", file=f)
diff --git test.txt.dvc test.txt.dvc
deleted file mode 100644
index 0ceff0b..0000000
--- test.txt.dvc
+++ /dev/null
@@ -1,17 +0,0 @@
-
-test.txt .dvc/cache/files/md5/fc/a18e3023be1c0a6e14ca2003b1524a
-1
-2
-3
-4
-5
-6
-7
-8
-9
-10
-11
-12
-13
-14
-15
```
</details>

#### Update files in DVC-tracked directory <a id="update-dir"></a>
[`03fd1e7`] changed values in `data/test.parquet`, and added rows to `data/test.txt`:

<!-- `bmdff -stdiff -- git diff 03fd1e7^..03fd1e7 -- data.dvc` -->
```bash
git diff '03fd1e7^..03fd1e7' -- data.dvc
```
```diff
data
--- .dvc/cache/files/md5/63/9653e88148f06346d0b965fd0318cc.dir e9c2c3a1ce3f416a21df573905667f4083122bc3
+++ .dvc/cache/files/md5/06/3f561a84adbf367a10e21aa33479dd.dir cb8a498df96e6a595dba21f186793e464d12282f
2,3c2,3
<   "test.parquet": "c07bba3fae2b64207aa92f422506e4a2",
<   "test.txt": "e20b902b49a98b1a05ed62804c757f94"
---
>   "test.parquet": "f46dd86f608b1dc00993056c9fc55e6e",
>   "test.txt": "9306ec0709cc72558045559ada26573b"

data/test.parquet
--- .dvc/cache/files/md5/c0/7bba3fae2b64207aa92f422506e4a2 c07bba3fae2b64207aa92f422506e4a2
+++ .dvc/cache/files/md5/f4/6dd86f608b1dc00993056c9fc55e6e f46dd86f608b1dc00993056c9fc55e6e
a/data/test.parquet..b/data/test.parquet
1c1
< MD5: c07bba3fae2b64207aa92f422506e4a2
---
> MD5: f46dd86f608b1dc00993056c9fc55e6e
9c9
<   "num": 111,
---
>   "num": 11,
13c13
<   "num": 222,
---
>   "num": 22,



data/test.txt
--- .dvc/cache/files/md5/e2/0b902b49a98b1a05ed62804c757f94 e20b902b49a98b1a05ed62804c757f94
+++ .dvc/cache/files/md5/93/06ec0709cc72558045559ada26573b 9306ec0709cc72558045559ada26573b
diff --git a/data/test.txt b/data/test.txt
index 8b1acc1..aa44898 100644
--- a/data/test.txt
+++ b/data/test.txt
@@ -8,3 +8,8 @@
 7
 8
 9
+10
+11
+12
+13
+14

```

<!-- `bmdff -stdiff -- git show 03fd1e7` -->
```bash
git show 03fd1e7
```
```diff
commit 03fd1e7cf697669c4d221ab1399f93a358be487d
Author: Ryan Williams <ryan@runsascoded.com>
Date:   Wed Dec 25 15:21:11 2024 -0500

    modify DVC-dir files

diff --git data.dvc data.dvc
index e9c2c3a..cb8a498 100644
--- data.dvc
+++ data.dvc
@@ -1,6 +1,6 @@
 
-test.parquet .dvc/cache/files/md5/c0/7bba3fae2b64207aa92f422506e4a2
-MD5: c07bba3fae2b64207aa92f422506e4a2
+test.parquet .dvc/cache/files/md5/f4/6dd86f608b1dc00993056c9fc55e6e
+MD5: f46dd86f608b1dc00993056c9fc55e6e
 1592 bytes
 5 rows
 message schema {
@@ -8,15 +8,15 @@ message schema {
   OPTIONAL BYTE_ARRAY str (STRING);
 }
 {
-  "num": 111,
+  "num": 11,
   "str": "aaa"
 }
 {
-  "num": 222,
+  "num": 22,
   "str": "bbb"
 }
 
-test.txt .dvc/cache/files/md5/e2/0b902b49a98b1a05ed62804c757f94
+test.txt .dvc/cache/files/md5/93/06ec0709cc72558045559ada26573b
 0
 1
 2
@@ -27,3 +27,8 @@ test.txt .dvc/cache/files/md5/e2/0b902b49a98b1a05ed62804c757f94
 7
 8
 9
+10
+11
+12
+13
+14
diff --git test.py test.py
index 065a6f3..34e93bb 100644
--- test.py
+++ test.py
@@ -5,11 +5,11 @@ import pandas as pd
 makedirs('data', exist_ok=True)
 
 df = pd.DataFrame({
-    'num': [111, 222, 333, 444, 555],
+    'num': [11, 22, 33, 44, 55],
     'str': ['aaa', 'bbb', 'ccc', 'ddd', 'eee'],
 }).astype({ 'num': 'int32' })
 df.to_parquet('data/test.parquet', index=False)
 
 with open('data/test.txt', 'w') as f:
-    for i in range(10):
+    for i in range(15):
         print(f"{i}", file=f)
```


## Other Bash DVC scripts/aliases <a id="aliases"></a>
[`.dvc-rc`] can be `source`d from `~/.bashrc`, and provides useful aliases, e.g.:

- `dvlp` (`dvc_local_cache_path`)
- `dvz` (`dvc_size`)
- `dvc-diff` aliases (from [dvc-utils])

[DVC]: https://dvc.org/
[`git-diff-dvc.sh`]: ./git-diff-dvc.sh
[`git-textconv-dvc.sh`]: ./git-textconv-dvc.sh

[@test]: https://github.com/ryan-williams/dvc-helpers/tree/test
[`3fe0e6e`]: https://github.com/ryan-williams/dvc-helpers/commit/3fe0e6e
[`c8af3fe`]: https://github.com/ryan-williams/dvc-helpers/commit/c8af3fe
[`3dc5466`]: https://github.com/ryan-williams/dvc-helpers/commit/3dc5466 
[`ab90427`]: https://github.com/ryan-williams/dvc-helpers/commit/ab90427
[`d760752`]: https://github.com/ryan-williams/dvc-helpers/commit/d760752
[`03fd1e7`]: https://github.com/ryan-williams/dvc-helpers/commit/03fd1e7
[`$PQT_TXT_OPTS`]: https://github.com/ryan-williams/parquet-helpers?tab=readme-ov-file#customizing-output-with-pqt_txt_opts-

[dvc-utils]: https://github.com/runsascoded/dvc-utils
[`git-diff-parquet.sh`]: https://github.com/ryan-williams/parquet-helpers?tab=readme-ov-file#git-diffshow-plugins-
