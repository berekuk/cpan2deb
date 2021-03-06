REPO=/repo/cpan2deb-lucid
CPAN_MIRROR=/opt/mirror
BUILD_IMAGE_DIR=/opt/images

create_repo:
	echo $(REPO)
	mkdir -p $(REPO)/binary
	mkdir -p $(REPO)/source
	mkdir -p $(REPO)/mini-dinstall/incoming
	chmod a+w $(REPO)/mini-dinstall/incoming
	chmod +t $(REPO)/mini-dinstall/incoming
	dpkg-scansources $(REPO)/source /dev/null | gzip -9c > $(REPO)/source/Sources.gz
	dpkg-scanpackages $(REPO)/binary /dev/null | gzip -9c > $(REPO)/binary/Packages.gz

update_mirror:
	mkdir -p  $(CPAN_MIRROR)
	perl update_mirror.pl $(CPAN_MIRROR)
	
create_build_images:
	mkdir -p /opt/images
	pbuilder  --create --basetgz $(BUILD_IMAGE_DIR)/lucid-amd64.tgz --distribution lucid --mirror http://ru.archive.ubuntu.com/ubuntu/ --architecture amd64
	pbuilder  --execute --save-after-exec --basetgz $(BUILD_IMAGE_DIR)/lucid-amd64.tgz ./add_chroot_repo.sh 
	pbuilder  --create --basetgz $(BUILD_IMAGE_DIR)/lucid-i386.tgz --distribution lucid --mirror http://ru.archive.ubuntu.com/ubuntu/ --architecture i386
	pbuilder  --execute --save-after-exec --basetgz $(BUILD_IMAGE_DIR)/lucid-i386.tgz ./add_chroot_repo.sh 

depgraph:
	perl -MCPAN::Dependency -e 'my $$cpandep = new CPAN::Dependency verbose => 1, process => ALL_CPAN; $$cpandep->run; $$cpandep->save_deps_graph(file => "deps.yml")'
