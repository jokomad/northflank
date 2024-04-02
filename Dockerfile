
FROM golang:bullseye AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM ubuntu:22.04 AS chromeinstall

LABEL maintainer "MontFerret Team <mont.ferret@gmail.com>"
LABEL homepage "https://www.montferret.dev/"

EXPOSE 9222

# https://omahaproxy.appspot.com/
# https://chromiumdash.appspot.com/releases?platform=Linux
ENV REVISION=1097615
ENV DOWNLOAD_HOST=https://storage.googleapis.com

RUN apt-get update -qqy \
  && DEBIAN_FRONTEND="noninteractive" apt-get -qqy install apt-transport-https inotify-tools gnupg \
    libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
    libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
    libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxss1 libxtst6 \
    libappindicator1 libnss3 libnss3-tools libasound2 libatk1.0-0 libc6 ca-certificates fonts-liberation \
    libatk-bridge2.0-0 libgbm1 lsb-release xdg-utils wget unzip \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget -q -O chrome-linux.zip "$DOWNLOAD_HOST/chromium-browser-snapshots/Linux_x64/$REVISION/chrome-linux.zip" \
  && unzip chrome-linux.zip -d /usr/local \
  && rm chrome-linux.zip \
  && ln -s /usr/local/chrome-linux/chrome /usr/local/bin/chrome

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tint2 xdg-utils lxterminal hsetroot tigervnc-standalone-server supervisor && \
    rm -rf /var/lib/apt/lists

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends fonts-liberation libu2f-udev chromium-browser firefox nautilus flatpak vim openssh-client wget curl rsync ca-certificates apulse libpulse0 htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY supervisord.conf /etc/
COPY menu.xml /etc/xdg/openbox/
RUN echo 'hsetroot -solid "#123456" &' >> /etc/xdg/openbox/autostart

RUN mkdir -p /etc/firefox
RUN echo 'pref("browser.tabs.remote.autostart", false);' >> /etc/firefox/syspref.js

RUN mkdir -p /root/.config/tint2
COPY tint2rc /root/.config/tint2/

COPY 1.tar.gz.partaaa /config/1.tar.gz.partaaa
COPY 1.tar.gz.partaab /config/1.tar.gz.partaab
COPY 1.tar.gz.partaac /config/1.tar.gz.partaac
COPY 1.tar.gz.partaad /config/1.tar.gz.partaad
RUN cat /config/1.tar.gz.parta* >/config/1.tar.gz
RUN cd /config && tar -xf /config/1.tar.gz 

EXPOSE 8080
ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/supervisord"]

