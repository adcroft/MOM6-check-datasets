### MOM6-datasets

This repository generates tarfiles of directories within the "datasets" use by MOM6-examples.
The data is archived under `/archive/gold/datasets` and mirrored under `/lustre/f1/pdata/gfdl_O/datasets`.
The `Makefile` provideds a means to both generate the tarfiles but also download and check the compatiblity of tarfiles hosted under ftp://ftp.gfdl.noaa.gov/home/aja/datasets/ .

Create a list of all files that are used by MOM6-examples:
```bash
make all_files.lst
```
The above defines what are need to run MOM6.

Create md5 hashs for files grouped by directory:
```bash
make md5
```
Special cases for tar files with updated data:
```bash
make ftp/OM4_025.v20180328.tgz
make ftp/OM4_05.v20180328.tgz
make ftp/obs.tgz
make ftp/obs.woa13.tgz
make ftp/OM4_025.v20180328
make ftp/OM4_05.v20180328
make ftp/obs
make ftp/obs.woa13
```

Download and test data from ftp site:
```bash
make test_download
```

`make test_download` is equivalent to:
```bash
make download
make md5_download
make unpack_download
make test_download
```

To build new tarfiles to upload:
```bash
make tarfiles
```

Summaize md5 files:
```bash
make hash.md5
```

Check versions of md5 files:
```bash
make
```
