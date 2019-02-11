all: md5
	md5sum -c hash.md5
depend: all_files.lst
all_files.lst: MOM6-examples/.datasets MOM6-examples
	find MOM6-examples/[oilc]* -type l -exec readlink --canonicalize {} \; | egrep -v "/MOM6-examples/|datasets$$" | sort -f | uniq | sed 's:.*/datasets/::;s:.*/mdteam/::' > $@
MOM6-examples/.datasets: | MOM6-examples
	ln -s /lustre/f2/pdata/gfdl_O/datasets MOM6-examples/.datasets
MOM6-examples:
	git clone https://github.com/NOAA-GFDL/MOM6-examples.git

DIRS = $(shell test -f all_files.lst && sed 's:/.*::' all_files.lst | uniq)
tarfiles: all_files.lst $(addsuffix .tgz,$(DIRS))
$(addsuffix .tgz,$(DIRS)):
	cd MOM6-examples/.datasets && tar zcvf $(PWD)/$@ `grep ^$(basename $@)/ $(PWD)/all_files.lst`
md5: all_files.lst $(addsuffix .md5,$(DIRS))
$(addsuffix .md5,$(DIRS)):
	(cd MOM6-examples/.datasets && md5sum `grep ^$(basename $@)/ $(PWD)/all_files.lst`) > $@
hash.md5: $(addsuffix .md5,$(DIRS))
	md5sum $^ > $@

download: $(foreach d,$(DIRS),ftp/$(d).tgz)
ftp/%.tgz:
	mkdir -p ftp; cd $(@D); wget -nv ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/$(@F)
	#mkdir -p ftp; cd $(@D); wget -nv ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/$(@F)
test_download: md5 $(foreach d,$(DIRS),ftp/$(d).test)
ftp/%.test: ftp/%
	cd $(@D); md5sum -c ../$*.md5 && touch $(@F)
unpack_download: $(foreach d,$(DIRS),ftp/$(d))
ftp/%: ftp/%.tgz
	cd $(@D); tar xf $(<F)
	touch $@
md5_download: $(foreach d,$(DIRS),ftp/$(d).md5)
ftp/%.md5: ftp/%
	cd $(@D); md5sum `find $* -type f | sort` > $(@F)

special-cases: ftp/OM4_025.v20180328.tgz ftp/OM4_05.v20180328.tgz ftp/obs.tgz ftp/obs.woa13.tgz ftp/OM4_025.v20180328 ftp/OM4_05.v20180328 ftp/obs ftp/obs.woa13

clean:
	-rm -f *.md5 ftp/*.md5 ftp/*.test all_files.lst
