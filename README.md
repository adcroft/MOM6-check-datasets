### MOM6-check-datasets

This repository generates tar files of directories within the "datasets" use by MOM6-examples.
The data is archived under `/archive/gold/datasets` and mirrored under `/lustre/f1/pdata/gfdl_O/datasets`.
The `Makefile` provides a means to both generate the tar files but also download and check the compatibility of tar files hosted under ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/ .

Create a list of all files that are used by MOM6-examples:
```bash
make all_files.lst
```
The above defines what are needed to run the MOM6-examples configurations.

Create md5 hashes for files grouped by directory:
```bash
make md5
```

Special cases for tar files with updated data:
```bash
make ftp/obs.tgz
make ftp/obs.woa13.tgz
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

To build new tar files to upload:
```bash
make tarfiles
```

Summarize md5 files:
```bash
make hash.md5
```

Check versions of md5 files:
```bash
make
```
