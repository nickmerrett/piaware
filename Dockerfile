FROM raspbian/stretch:latest

RUN apt update && apt install -y \
  curl 

WORKDIR /tmp

RUN curl -o piaware-repo.deb http://flightaware.com/adsb/piaware/files/packages/pool/piaware/p/piaware-support/piaware-repository_3.7.2_all.deb \
    && dpkg -i piaware-repo.deb \
    &&  rm -f piaware-repo.deb

RUN apt update && apt install -y \
  piaware \ 
  piaware-web \
  perl-modules \
  rtl-sdr \
  dump1090-fa \ 
  lighttpd \ 
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


WORKDIR /
COPY piaware_config /root/.piaware
COPY start.sh /

RUN piaware-config allow-auto-updates no &&\
    piaware-config allow-manual-updates no && \
    piaware-config allow-mlat yes

RUN chmod +x /start.sh && mkdir /run/dump1090-fa/ && mkdir /run/piaware/

ENTRYPOINT [ "/start.sh" ]

EXPOSE 80 8080 30001 30002 30003 30004 30005 30104

