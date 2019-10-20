# 自作 OS

30 日でできる OS 自作入門をやる

## Setup

### install qemu

Using qemu ver-3.1.1 as emulator

```
wget https://download.qemu.org/qemu-3.1.1.tar.xz

tar xvJf qemu-3.1.1.tar.xz
cd qemu-3.1.1
./configure
make
make install
```

Check install

```
$ qemu-system-i386 -version
QEMU emulator version 3.1.1
Copyright (c) 2003-2018 Fabrice Bellard and the QEMU Project developers
```

### install nasm

Using `nasm` assembler

```
$ brew install nasm
```

Check install

```
$ nasm -v
NASM version 2.14.02 compiled on Sep 28 2019
```

### Install mtools

Using `mtools` for write OS to disk

```
$ brew install mtools
```
