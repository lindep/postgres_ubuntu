# PostgtreSQL 9.4
#
# VERSION      9.4

FROM lindep/geotest
MAINTAINER Pieter Linde

#RUN apt-get update && apt-get -y install wget
COPY apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.list
COPY apt/sources.list /etc/apt/sources.list

#RUN apt-get update && apt-get install -y build-essential sqlite3 libsqlite3-dev


#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#RUN apt-get update && apt-get install -y postgresql-9.4 \
#	postgresql-contrib-9.4 \
#	postgresql-9.4-postgis-2.1 \
#	postgresql-client-9.4 \
#	libgdal-dev \
#	libgdal-perl \
#	python-gdal \
#	python-geolinks \
#	libspatialite-dev \
#	inotify-tools \
#	&& rm -rf /var/lib/apt/lists/*

#COPY geoTools /tmp/geoTools
#RUN cd /tmp/geoTools/geos-3.4.2 && make clean && ./configure && make && make install
#RUN ldconfig
#RUN cd /tmp/geoTools/proj-4.9.1 && make clean && ./configure && make && make install
#RUN ldconfig
#RUN cd /tmp/geoTools/gdal-1.11.2 && make clean && ./configure --with-sqlite3=yes --with-spatialite=yes && make && make install
#RUN ldconfig

RUN rm -rf /.nvm

RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc && \
  npm install -g d3 topojson

RUN mkdir /usr/share/gdal_python
COPY geoTools/gdal-1.11.2/swig/python/scripts /usr/share/gdal_python/scripts

ADD ./scripts/postgres.sh /var/lib/postgresql/postgres.sh
RUN chown postgres:postgres /var/lib/postgresql/postgres.sh
RUN chmod +x /var/lib/postgresql/postgres.sh

RUN echo "postgres:postgres" | chpasswd && adduser postgres sudo

RUN touch /var/tmp/firstrun
RUN chown postgres:postgres /var/tmp/firstrun

USER postgres

# Initial default user/pass and schema
ENV USER postgres
ENV PASSWORD postgres
ENV SCHEMA postgres
ENV POSTGIS false

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.4/main/postgresql.conf
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.4/main/pg_hba.conf

VOLUME	["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]



EXPOSE 5432
CMD ["/var/lib/postgresql/postgres.sh"]



