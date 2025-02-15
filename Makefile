CXXFLAGS:= -std=gnu++17 -Wall -O3 -MMD -MP -ggdb -fno-omit-frame-pointer -Iext/CLI11 \
	 -Iext/fmt-5.2.1/include/ -Iext/powerblog/ext/simplesocket -Iext/powerblog/ext/ \
	 -I/usr/local/opt/openssl/include/  \
	 -Iext/sgp4/libsgp4/ \
	 -I/usr/local/include

# CXXFLAGS += -Wno-delete-non-virtual-dtor

PROGRAMS = navparse ubxtool navnexus navrecv navdump testrunner navdisplay tlecatch

all: navmon.pb.cc $(PROGRAMS)

-include Makefile.local

-include *.d

clean:
	rm -f *~ *.o *.d ext/*/*.o $(PROGRAMS) navmon.pb.h navmon.pb.cc

H2OPP=ext/powerblog/h2o-pp.o
SIMPLESOCKETS=ext/powerblog/ext/simplesocket/swrappers.o ext/powerblog/ext/simplesocket/sclasses.o  ext/powerblog/ext/simplesocket/comboaddress.o 

navparse: navparse.o ext/fmt-5.2.1/src/format.o $(H2OPP) $(SIMPLESOCKETS) minicurl.o ubx.o bits.o navmon.pb.o gps.o ephemeris.o beidou.o glonass.o $(patsubst %.cc,%.o,$(wildcard ext/sgp4/libsgp4/*.cc)) tle.o navmon.o
	$(CXX) -std=gnu++17 $^ -o $@ -pthread -L/usr/local/lib -L/usr/local/opt/openssl/lib/  -lh2o-evloop -lssl -lcrypto -lz  -lcurl -lprotobuf  $(WSLAY)

navdump: navdump.o ext/fmt-5.2.1/src/format.o bits.o navmon.pb.o gps.o ephemeris.o beidou.o glonass.o navmon.o $(patsubst %.cc,%.o,$(wildcard ext/sgp4/libsgp4/*.cc)) tle.o sp3.o
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -pthread  -lprotobuf

navdisplay: navdisplay.o ext/fmt-5.2.1/src/format.o bits.o navmon.pb.o gps.o ephemeris.o beidou.o glonass.o ephemeris.o navmon.o
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -pthread  -lprotobuf -lncurses


navnexus: navnexus.o ext/fmt-5.2.1/src/format.o  $(SIMPLESOCKETS) ubx.o bits.o navmon.pb.o storage.o
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -pthread -lprotobuf

navrecv: navrecv.o ext/fmt-5.2.1/src/format.o $(SIMPLESOCKETS) navmon.pb.o storage.o
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -pthread -lprotobuf  

tlecatch: tlecatch.o $(patsubst %.cc,%.o,$(wildcard ext/sgp4/libsgp4/*.cc))
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -pthread -lprotobuf  

navmon.pb.cc: navmon.proto
	protoc --cpp_out=./ navmon.proto

ubxtool: navmon.pb.o ubxtool.o ubx.o bits.o ext/fmt-5.2.1/src/format.o galileo.o  gps.o beidou.o navmon.o ephemeris.o $(SIMPLESOCKETS)
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -lprotobuf -pthread

testrunner: navmon.pb.o testrunner.o ubx.o bits.o ext/fmt-5.2.1/src/format.o galileo.o  gps.o beidou.o ephemeris.o sp3.o
	$(CXX) -std=gnu++17 $^ -o $@ -L/usr/local/lib -lprotobuf

check: testrunner
	./testrunner
