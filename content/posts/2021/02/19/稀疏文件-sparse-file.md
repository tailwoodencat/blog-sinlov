---
title: "稀疏文件 Sparse File"
date: 2021-02-19T15:00:43+08:00
description: "desc 稀疏文件 Sparse File"
draft: false
categories: ['basics']
tags: ['basics']
toc:
  enable: true
  auto: false
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

# 稀疏文件介绍

稀疏文件，这是UNIX类和NTFS等文件系统的一个特性

例如：/var/lib/docker 目录，实际占用非常小，但是在系统里面看到的占用是 11G 的文件目录

```bash
$ df -alh
Filesystem      Size  Used Avail Use% Mounted on
overlay         117G   11G  101G  10% /var/lib/docker/overlay2/xxxxxxx
$ sudo du -h -d 1 /var/lib/docker
...
244K	/var/lib/docker
```

稀疏文件被普遍用来磁盘图像，数据库快照，日志文件，还有其他科学运用上

- 开始时，一个稀疏文件不包含用户数据，也没有分配到用来存储用户数据的磁盘空间
- 当数据被写入稀疏文件时，NTFS逐渐地为其分配磁盘空间。一个稀疏文件有可能增长得很大
- 稀疏文件以`64KB（不同文件系统不同）`为单位增量增长，因此磁盘上稀疏文件的大小总是64KB的倍数
- 稀疏文件就是在文件中留有很多空余空间，留备将来插入数据使用
- 如果这些空余空间被ASCII码的NULL字符占据，并且这些空间相当大，那么，这个文件就被称为稀疏文件，而且，并不分配相应的磁盘块

> 这样，会产生一个问题，文件已被创建了，但相应的磁盘空间并未被分配，只有在有真正的数据插入进来时，才会被分配磁盘块，如果这时文件系统被占满了，那么对该文件的写操作就会失败

为防止这种情况，有两种办法：`不产生稀疏文件` 或 `为稀疏文件留够空间`

在计算机科学方面，稀疏文件是文件系统中的一种文件存储方式，在创建一个文件的时候，就预先分配了文件需要的连续存储空间，其空间内部大多都还未被数据填充现在有很多文件系统都支持稀疏文件，包括大部分的 Unix 和NTFS


## WINDOWS 中的稀疏文件

WINNT 3.51中的NTFS文件系统对此进行了优化，那些无用的0字节被用一定的算法压缩起来，使得这些0字节不再占用那么多的空间

在你声明一个很大的稀疏文件时(例如 100GB)，这个文件实际上并不需要占用这么大的空间，因为里面大都是无用的0数据，那么，NTFS对稀疏文件的压缩算法可以释放这些无用的0字节空间， 可以说这是对磁盘占用空间以及效率的一种优化

记住，FAT32上并不支持稀疏文件的压缩（至少我在自己机子上测试得出如此结论）

### 判断一个磁盘是否是稀疏文件

我们可以通过一个系统函数GetVolumeInformation 来判断某个磁盘是否支持稀疏文件的压缩

```C
GetVolumeInformation
The GetVolumeInformation function retrieves information about a file system and volume that have a specified root directory.

BOOL GetVolumeInformation(
LPCTSTR lpRootPathName,
  LPTSTR lpVolumeNameBuffer,
  DWORD nVolumeNameSize,
  LPDWORD lpVolumeSerialNumber,
  LPDWORD lpMaximumComponentLength,
  LPDWORD lpFileSystemFlags,
  LPTSTR lpFileSystemNameBuffer,
  DWORD nFileSystemNameSize
);
```

我们只要把查询到的 `Flag` 跟 `FILE_SUPPORTS_SPARSE_FILES 位与(&)，便可以知道该磁盘是否支持

例如工具

```c
    CHAR szVolName[MAX_PATH], szFsName[MAX_PATH];
    DWORD dwSN, dwFSFlag, dwMaxLen, nWritten;
    BOOL bSuccess;
    HANDLE hFile;
    bSuccess = GetVolumeInformation(NULL,
        szVolName,
        MAX_PATH,
        &dwSN,
        &dwMaxLen,
        &dwFSFlag,
        szFsName,
        MAX_PATH);

    if (!bSuccess) {
        printf("errno:%d", GetLastError());
        return -1;
    }
    printf("vol name:%s \t fs name:%s sn: %d.\n", szVolName, szFsName, dwSN);
    if (dwFSFlag&FILE_SUPPORTS_SPARSE_FILES) {
        printf("support sparse file.\n");
    }else{
        printf("no support sparse file.\n");
    }
```

### 如何判断一个文件是否是稀疏文件

可以通过 `GetFileInformationByHandle()` 函数来判断一个文件是否是稀疏文件

```c
The GetFileInformationByHandle function retrieves file information for the specified file.

BOOL GetFileInformationByHandle(
HANDLE hFile,
  LPBY_HANDLE_FILE_INFORMATION lpFileInformation
);
```

例子代码如下:

```c
HANDLE hFile;
BY_HANDLE_FILE_INFORMATION stFileInfo；

//Open/create file to get the file handle
hFile = CreateFile();
//Get the file information
GetFileInformationByHandle(hFile, &stFileInfo);

if(stFileInfo.dwFileAttributes & FILE_ATTRIBUTE_SPARSE_FILE)
{
    //Sparse file
}else{
   //Not sparse file
}
```

### 如何产生一个稀疏文件并声明该文件是稀疏文件

大部分文件，在你改变它的EndOfFile的时候，中间的空白会被操作系统填0

> 也就是说，如果你用 SetFilePointer() 和 SetEndOfFile() 来产生一个很大的文件，那么这个文件它占用的是真正的磁盘空间，即使里面全是0

因为系统默认的会在 DeviceIoControl() 中的 ControlCode 里用

FSCTL_SET_ZERO_DATA标记，这个标记使得那些文件空洞被0所填充

`为了节省磁盘空间，我们必须把一个文件声明为稀疏文件，以便让系统把那些无用的0字节压缩，并释放相应的磁盘空间`

```c
    hFile = CreateFile("tmp_file",
        GENERIC_WRITE|GENERIC_READ,
        FILE_SHARE_READ|FILE_SHARE_WRITE,
        NULL,
        CREATE_ALWAYS,
        0,
        NULL);
    DWORD dwTemp;
    DeviceIoControl(hFile,
        FSCTL_SET_SPARSE,
        NULL,
        0,
        NULL,
        0,
        &dwTemp,
        NULL);


    SetFilePointer(hFile, 0x100000, NULL, FILE_BEGIN);
    WriteFile(hFile,
        "123",
        3,
        &nWritten,
        NULL);
    SetEndOfFile(hFile);
    CloseHandle(hFile);
```

通过 `FSCTL_SET_SPARSE` 标记告诉系统该文件是稀疏文件，如果该文件所在的磁盘支持稀疏文件的压缩，则系统会释放不必要的0字节空间

你可以用这个方法创建一个100GB得文件试一下(示例里是1M)，记得右键看看文件属性里的‘大小’和占用空间，它被声明为100GB，但是实际上那些0字节基本不占用空间

> tips: 在FAT32得磁盘里，因为没有对SPARSE FILE得支持，所以您创建的空洞文件全部被填零，即使你声明它是一个稀疏文件，也没有任何作用，您声明这个文件多大，它就占用多大的空间

如果您编译 DeviceIoControl 这个函数出现 `'FSCTL_SET_SPARSE' : undeclared identifier` 之类的情况

```
#include <windows.h>
#define   _WIN32_WINNT         0x0501
#include <Winioctl.h>
```

## Linux文件空洞与稀疏文件

### Linux 文件空洞介绍

在 UNIX/Linux 文件操作中，文件位移量可以大于文件的当前长度，在这种情况下，对该文件的下一次写将延长该文件，并在文件中构成一个空洞

位于文件中但没有写过的字节都被设为0

如果 offset 比文件的当前长度更大，下一个写操作就会把文件`撑大（extend）` 在文件里创造 `空洞（hole）`

没有被实际写入文件的`所有字节由重复的 0 表示`

`空洞是否占用硬盘空间是由文件系统（file system）决定的`

### UNIX 稀疏文件（Sparse File）

稀疏文件与其他普通文件基本相同，区别在于`文件中的部分数据是全0，且这部分数据不占用磁盘空间`

> 文件系统存储稀疏文件时，inode 索引节点中，只给出实际占用磁盘空间的 block 号，数据全0，且不占用磁盘空间的文件block并没有物理磁盘block号

稀疏文件的创建与查看

```
# 创建一个稀疏文件
$ dd if=/dev/zero of=sparse-file bs=1 count=1 seek=1024k
# 查看这个稀疏文件
$ ls -l sparse-File
-rw-r--r-- 1 work work 1048577 Feb 19 15:13 sparse-file
# 查看实际占用空间
$ du -sh sparse-file
8.0K sparse-file

# 将数据写入稀疏文件
$ cat nginx.conf >> sparse-file
# 再次查看实际占用
$ du -sh sparse-file
13.1K sparse-file
# 查看数据文件占用
$ du -sh nginx.conf
13.1K nginx.conf
```

### linux稀疏文件Inode数据块存储

文件空洞部分不占用磁盘空间
`文件所占用的磁盘空间仍然是连续的`