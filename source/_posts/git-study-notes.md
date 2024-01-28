---
title: Git学习随笔 
date: 2019-01-16 15:09:02
tags:
   - Git
categories:
	- Notes
	- Study Notes

---



记一些Git学习时的笔记供之后参考，可以从博客右侧的导航栏进行便捷浏览。

<!-- more -->

### FAQ
#### 快速合并和非快速合并的区别
理解概念：https://blog.csdn.net/andyzhaojianhui/article/details/78072143
理解区别：https://blog.csdn.net/zombres/article/details/82179122

### Git远程操作

#### 查看/设置远程仓库

- 查看远程分支引用列表：`git ls-remote`
    >  54f42552f530fe64acdf71e68c5de3b8ac1b9184	HEAD
    > 54f42552f530fe64acdf71e68c5de3b8ac1b9184	refs/for/master    
    > 54f42552f530fe64acdf71e68c5de3b8ac1b9184	refs/heads/master
- 查看本地仓库已经配置的远程仓库信息：`git remote -v`
- 查看远程仓库详细信息：`git remote show [remote-name]`
- 添加远程仓库：`git remote add <remote-name> <url>`添加远程仓库URL，并设置一个简写的远程仓库名称，这个名称代替整个URL。这里的remote-name可以任意命名，通过`git clone`命令下来的仓库，其remote-name为origin。
- 修改远程仓库URL：`git remote set-url [remote-name] [url]`


`git remote`命令手册：
>    git remote [-v | --verbose]
       git remote add [-t <branch>] [-m <master>] [-f] [--[no-]tags] [--mirror=<fetch|push>] <name> <url>
       git remote rename <old> <new>
       git remote remove <name>
       git remote set-head <name> (-a | --auto | -d | --delete | <branch>)
       git remote set-branches [--add] <name> <branch>...
       git remote get-url [--push] [--all] <name>
       git remote set-url [--push] <name> <newurl> [<oldurl>]
       git remote set-url --add [--push] <name> <newurl>
       git remote set-url --delete [--push] <name> <url>
       git remote [-v | --verbose] show [-n] <name>...
       git remote prune [-n | --dry-run] <name>...
       git remote [-v | --verbose] update [-p | --prune] [(<group> | <remote>)...]

#### 拉取远程仓库信息

**git fetch**

- `git fetch <remote-name>`拉取某个远程远程仓库信息，例如：`git remote origin`，`git fetch --all`拉取本地仓库所有绑定的远程仓库信息。
- `git fetch`会将该远程仓库的所有信息（本地没有的）拉取到本地仓库中，更新所有远程分支的提交引用（但不用合并代码）。



**git pull**

`git pull`命令，拉取远程主机某个分支的提交更新。命令为：`git pull <remote-name> <branch-name>`
如果本地分支设置了远程的跟踪分支（上游），那么可以直接使用`git pull`。
`git pull` 会查找当前分支所跟踪的服务器与分支，从服务器上抓取数据然后尝试合并入那个远程分支。



### Git常用撤销操作

- 撤销文件暂存状态: `git reset HEAD <file>` 
- 撤销对文件的修改：`git checkout -- <file>`

### Git重置

#### git reset 命令

git reset命令有3种形式.

1. `git reset [-q] [<tree-ish>] [--] <paths>...`
2. `git reset (--patch | -p) [<tree-ish>] [--] [<paths>...]`
3. `git reset [--soft | --mixed [-N] | --hard | --merge | --keep] [-q] [<commit>]`

这里将1、2两种带有paths的形式称为**基于路径的使用方式**，将第3种带有commit的形式称为**基于提交记录的使用方式**。


根据这2种使用方式，在平时使用时有两种使用场景:

1. **重置暂存区 ，撤销文件暂存。(不会移动HEAD分支指向)**
   `git reset HEAD -- paths`或者直接`git reset HEAD`，由于reset参数默认是`--mixed`级别，表示将HEAD中的文件状态复制到暂存区。也就是相当于撤销了新文件的暂存，取消了`git add`命令的操作。这个命令执行完成后，文件的状态是**被修改但未暂存（Changes not staged）**。

2. **用来将当前分支的HEAD指针移动到某个提交上**
   这种使用方式会根据传递的选项来决定进行什么样的操作, 但都会先将分支的HEAD指针进行移动. 移动的后续操作取决于传入的是`--mixed`还是`--soft`或是`--hard`. 
   - `--soft` 仅仅是移动HEAD指针到某次提交上, 暂存区和工作区不受影响，表示仅仅撤销提交, 重置前如果有加入到暂存区的文件会依旧保留在暂存区, (表示我们希望撤销`git commit`)
   - `--mixed` 移动HEAD指针后, 如果重置前有加入到暂存区的文件, 那么会被取消暂存, 但工作区不受影响. (表示我们希望撤销`git commit`以及`git add`)
   - `--hard` 在移动HEAD指针后, 会将暂存区及工作区都重置为对应提交记录的状态上去. (撤销`git commit` 、`git add`以及工作区所有的修改)


**关于git reset [--soft | --mixed | --hard] 命令操作过程:**
   首先git reset命令的三个选项都会将当前分支的HEAD指针进行移动. 
   - `--soft` 仅仅是移动指针，不会对暂存区和工作区做修改，重置后，工作区和index中依旧是之前的文件状态。
   - `--mixed`移动HEAD指针后，再将对应HEAD指向的提交记录中的文件拷贝至index中，所以此时index与HEAD中文件内容一致。可以通过命令`git diff --cached <path>`查看一下index与HEAD中的文件差异。这时候，工作区和index中的差异就是相对于HEAD中的差异，可以通过命令`git diff <commit> <path>`查看一下。
   - `--hard`则在移动HEAD指针后先将HEAD中对应的内容复制到index中, 同时还会将index的内容复制给工作区.

   https://www.git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E9%87%8D%E7%BD%AE%E6%8F%AD%E5%AF%86

### Git检出

#### 检出分支

- 从Tag检出分支：`git checkout -b [branchname] [tagname]`

- 基于其他分支检出：`git checkout -b <new-branch-name> <base-branch-name>`
  - 如果基分支是远程分支，那么检出分支会建立绑定关系（设置其为跟踪分支或上游分支）：`git checkout -b [branch][remotename]/[branch]`
  - `git checkout -b [branch][remotename]/[branch]`可简写为：`git checkout --track [remotename]/[branch]`



#### 撤销对未暂存文件的修改
命令：`git checkout -- <file>`

### Git Tag 操作

- 查看tag列表：`git tag`
- 查看tag信息：`git show <tag-name>`
- 创建tag：`git tag -a v1.4 -m 'my version 1.4' <commit-id>`
- 删除tag：`git tag -d <tag-name>`
- 推送tag到远程：`git push origin <tag-name>` / 推送本地所有tag：`git push --tags`
- 删除远程tag：`git push origin :refs/tags/<tag-name>`（将远程tag引用至空）


https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/0013762144381812a168659b3dd4610b4229d81de5056cc000



### Git配置

`git config section.key "配置值"`，例如`git config user.name "Bennie Joey"`

配置的3个级别，`-e`表示编辑配置文件：
- `git config -e`当前仓库，优先级最高
- `git config --global -e`当前用户 
- `git config --system -e`系统全局，优先级最低

`git config --list`列出所有 Git 当时能找到的配置。


**配置别名**

- 命令配置：`git config --global alias.<别名> '命令内容'`，如：`git config --global alias.st 'status'`
- 手动配置：`git config -e --global`编辑配置文件，加入到"[alias]"节即可。
    ```properties
    ci = commit
    cim = commit -m
    co = checkout
    cob = checkout -b
    lgol = log --oneline
    st = status
    sts = status -s
    a = !git add . && git status
    au = !git add -u . && git status
    aa = !git add . && git add -u . && git status
    ca = commit --amend # careful
    ac = !git add . && git commit
    acm = !git add . && git commit -m
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    d = diff
    alias = !git config --list | grep 'alias\\.' | sed 's/alias\\.\\([^=]*\\)=\\(.*\\)/\\1\\\t => \\2/' | sort
    br = branch
    unstage = reset HEAD --
    ```



### Git分支操作

#### 检出分支

1. 分支可以从一个**commit**、**tag**、**其他分支**上进行基础。
2. 创建分支，只是相当于从commit对象上建立了一个指针，然后让其内部的HEAD指针指向这个分支，就会知道当前工作区处于哪个分支上（可以将 HEAD 想象为当前分支的别名）。

#### 远程分支操作

##### Git查看、删除、重命名远程分支和tag
https://blog.zengrong.net/post/delete_git_remote_brahch/

##### 删除远程分支

第一种：
 `git push origin --delete <branch_name>`

第二种：
git branch -r -d origin/<branch_name>
git push origin :<branch_name>

##### 设置本地分支的远程跟踪分支

设置后可以直接在当前分支上使用`git pull`、`git push`。

1. 从远程分支检出本地分支（会自动设置远程分支为跟踪分支），见：[检出分支](#检出分支)
2. 修改或者本地分支的远程跟踪分支：`git branch -u/--set-upstream-to origin/远程分支名x` 
   `git branch (--set-upstream-to=<upstream> | -u <upstream>) [<branchname>]`
3. 查看本地分支的远程跟踪分支信息：`git branch -vv` 这会将所有的本地分支列出来并且包含更多的信息，如每一个分支正在跟踪哪个远程分支与本地分支是否是领先、落后或是都有。



### Git信息查看

#### 查看历史提交信息


##### Git log命令

- `git log <file-path>` 查看单个文件/目录的提交记录
- `git log --flow <file-path>` 追溯文件全部历史，包括删除、重命名文件名。、
- `git log pretty=oneline/short/full/fuller/format:<格式化>`，format参数如下：

| 选项 | 说明 |
| ----- | ------------------------------------------- |
| `%H` | 提交对象（commit）的完整哈希字串 |
| `%h` | 提交对象的简短哈希字串 |
| `%T` | 树对象（tree）的完整哈希字串 |
| `%t` | 树对象的简短哈希字串 |
| `%P` | 父对象（parent）的完整哈希字串 |
| `%p` | 父对象的简短哈希字串 |
| `%an` | 作者（author）的名字 |
| `%ae` | 作者的电子邮件地址 |
| `%ad` | 作者修订日期（可以用 --date= 选项定制格式） |
| `%ar` | 作者修订日期，按多久以前的方式显示 |
| `%cn` | 提交者（committer）的名字 |
| `%ce` | 提交者的电子邮件地址 |
| `%cd` | 提交日期 |
| `%cr` | 提交日期，按多久以前的方式显示 |
| `%s` | 提交说明 |



----


**git log常用命令选项**

| 选项 | 说明 |
| --------------------- | ---------------------------------- |
| `-(n)` | 仅显示最近的 n 条提交 |
| `--since`, `--after` | 仅显示指定时间之后的提交。 |
| `--until`, `--before` | 仅显示指定时间之前的提交。 |
| `--author` | 仅显示指定作者相关的提交。 |
| `--committer` | 仅显示指定提交者相关的提交。 |
| `--grep` | **仅显示含指定关键字的提交** |
| `-S` | **仅显示添加或移除了某个关键字的提交** |

https://git-scm.com/book/zh/v2/Git-%E5%9F%BA%E7%A1%80-%E6%9F%A5%E7%9C%8B%E6%8F%90%E4%BA%A4%E5%8E%86%E5%8F%B2



#### 查看对象库信息

- `git show <branch>`


### 命令使用

#### 底层命令

- `git cat-file `查看对象内容

  ```properties
  -t 查看对象类型。类型可以是blob, tree, commit, tag其中之一
  -s 显示对象大小
  -e exit with zero when there's no error
  -p 打印对象内容
  ```

- `git ls-files` 浏览文件内容。

  ```
  -z paths are separated with NUL character
  -t identify the file status with tags
  -v use lowercase letters for 'assume unchanged' files
  -f use lowercase letters for 'fsmonitor clean' files
  -c, --cached 显示已被暂存的文件。
  -d, --deleted 显示已经被删除的文件。
  -m, --modified 显示被修改的文件。
  -o, --others show other files in the output
  -i, --ignored 显示被忽略的文件。
  -s, --stage show staged contents' object name in the output
  -k, --killed 显示文件系统上需要被移除的文件
  --directory show 'other' directories' names only
  ```

- `git rev-parse` 将标签、相对名、简写或绝对名称转成实际的提交散列ID。

#### git rm命令

- `git rm <file> --cached` 移除索引中已经暂存的文件（工作区文件依旧保留）。
- `git rm <file>`移除索引和工作区的文件。（文件需要被暂存）
- `git rm -f <file>` -f命令 表示在删除之前已存在被加到暂存区的文件一样会被强制移除。


#### git diff 命令

该命令用来查看文件的不同.
- `git diff <file>`查看**工作区**相对于**暂存区**作出的更改。（默认）
- `git diff <commit> <file>` 查看**工作区**与**指定提交**的文件差异
- `git diff --cached [<commit>] <file>` 查看**暂存区**与**HEAD**或**指定提交**中的差异。
- `git diff <commit> <commit>` 查询两次提交中的文件差异。

`git diff <file>` 表示查看工作区相对于暂存区的差异：
```shell
$ git diff t.txt 
diff --git a/t.txt b/t.txt
index 1191247..01e79c3 100644
--- a/t.txt
+++ b/t.txt
@@ -1,2 +1,3 @@
1
2
+3   
```










