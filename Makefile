SHELL = /bin/bash

all: md5
	md5sum -c hash.md5
depend: all_files.lst
all_files.lst: MOM6-examples/.datasets MOM6-examples
	find MOM6-examples/[oilc]* -type l -exec readlink --canonicalize {} \; | egrep -v "/MOM6-examples/|datasets$$" | LC_ALL=C /bin/sort -f | uniq | sed 's:.*/datasets/::;s:.*/mdteam/::' > $@
MOM6-examples/.datasets: | MOM6-examples
	test -d /lustre/f2/pdata/gfdl_O/datasets && ln -s /lustre/f2/pdata/gfdl_O/datasets MOM6-examples/.datasets || true
	test -d /archive/gold/datasets && ln -s /archive/gold/datasets MOM6-examples/.datasets || true
MOM6-examples:
	git clone https://github.com/NOAA-GFDL/MOM6-examples.git

DIRS = $(shell test -f all_files.lst && sed 's:/.*::' all_files.lst | sort | uniq)
tarfiles: $(foreach d,$(DIRS),newdir/$(d).tgz)
$(foreach d,$(DIRS),newdir/$(d).tgz):
	mkdir -p newdir
	cd MOM6-examples/.datasets && tar zcvf $(PWD)/$@ `grep ^$(basename $(@F))/ $(PWD)/all_files.lst`
md5: all_files.lst $(addsuffix .md5,$(DIRS))
$(addsuffix .md5,$(DIRS)):
	(cd MOM6-examples/.datasets && md5sum `grep ^$(basename $@)/ $(PWD)/all_files.lst`) > $@
hash.md5: $(addsuffix .md5,$(DIRS))
	md5sum $^ > $@

download: $(foreach d,$(DIRS),ftp-download/$(d).tgz)
ftp-download/%.tgz:
	mkdir -p $(@D); cd $(@D); wget -nv ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/$(@F)
test_download: md5 $(foreach d,$(DIRS),ftp-test/$(d).test)
ftp-test/%.test: ftp-md5/%.md5
	mkdir -p $(@D) ; ( cd ftp-unpacked ; md5sum -c ../$*.md5 ) && touch $@
unpack_download: $(foreach d,$(DIRS),ftp-unpacked/$(d))
ftp-unpacked/%: ftp-download/%.tgz
	mkdir -p $(@D) ; cd $(@D); tar xf ../$<
	touch $@
md5_download: $(foreach d,$(DIRS),ftp-md5/$(d).md5)
ftp-md5/%.md5: ftp-unpacked/%
	(cd $(<D); md5sum `find $* -type f | LC_ALL=C /bin/sort` ) > $@

special-cases: ftp/obs.woa13 ftp/obs ftp/obs.woa13.tgz ftp/obs.tgz

clean:
	-rm -f *.md5 ftp/*.md5 ftp/*.test all_files.lst

gitlab:
	# Clone MOM6-examples
	make MOM6-examples
	# Point .datasets to archive
	make MOM6-examples/.datasets
	# Create/update master list of files pointed to by MOM6-examples
	make -o all_files.lst
	# Make sure files are online
	cat all_files.lst | (cd MOM6-examples/.datasets/ ; xargs dmget )
	# Checksum data pointed to by MOM6-examples
	make md5
	# Fetch special case data
	make special-cases
	# Download tarfiles, unpack and check md5 match
	make test_download
