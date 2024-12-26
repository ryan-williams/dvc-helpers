# dvc-helpers
Bash scripts/aliases and `git {diff,show}` plugins for [DVC] files.

<!-- toc -->
- [`git {diff,show}` plugins](#git)
    - [Setup](#diff-setup)
    - [Examples](#examples)
        - [Field dtype changed](#dtype-changed)
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

#### Field dtype changed <a id="dtype-changed"></a>
[`85ea6c7`] added a Git-tracked text file:
<!-- `bmdff -stdiff git diff 85ea6c7^..85ea6c7` -->
```bash
git diff '85ea6c7^..85ea6c7'
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

<!-- `bmdfff -stdiff git show 85ea6c7` -->
<details><summary><code>git show 85ea6c7</code></summary>

```diff
commit 85ea6c70cac65ced51a0fdd7a67e4747e6249cbb
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


## Other Bash DVC scripts/aliases <a id="aliases"></a>
[`.dvc-rc`] can be `source`d from `~/.bashrc`, and provides useful aliases, e.g.:

- `dvlp` (`dvc_local_cache_path`)
- `dvz` (`dvc_size`)
- `dvc-diff` aliases (from [dvc-utils])

[DVC]: https://dvc.org/
[`git-diff-dvc.sh`]: ./git-diff-dvc.sh
[`git-textconv-dvc.sh`]: ./git-textconv-dvc.sh

[@test]: https://github.com/ryan-williams/dvc-helpers/tree/test
[`85ea6c7`]: https://github.com/ryan-williams/dvc-helpers/commit/85ea6c7

[dvc-utils]: https://github.com/runsascoded/dvc-utils
