# my commands, shell conf, etc

## sub commander

### Usage
```
$ subcom git
git> b<TAB><TAB>
bisect  blame   branch  bundle
git> br<TAB>anch
* main
```

### require
rlwrap, perl, awk, expect, bash

<br>

## Co-Process Generator

### Usage
```
$ ls
$ cop open cat -n
$ ls
fpid  output.sock  pid  stderr.sock  stdin.sock  stdout.sock  stream.sock
$ cop write first
$ cop read
>>> first
<<<      1      first
$ cop read 1
     1  first
$ echo second | cop write
$ cop flush
>>> first
<<<      1      first
>>> second
<<<      2      second
$ cop flush
$ cop close
$ ls
```

<br>

## detach

### Usage
```
$ ls
file1  file2
$ detach file1
$ ls
file2
$ detach pop
$ ls
file1  file2
```

### require
tcl, ed
