#Name of container: docker-opensimulator-osgrid
#Version of container: 0.9.1.1.20200127

FROM opensuse/tumbleweed:latest
MAINTAINER lemmy04 <Mathias.Homann@openSUSE.org>
LABEL version=0.9.1.1.20200R203 Description="For running a standalone opensim instance in a docker container." Vendor="Mathias.Homann@openSUSE.org"

## install all updates
## Date: 2020-02-03
RUN zypper --gpg-auto-import-keys addrepo -r https://download.opensuse.org/repositories/Mono:/Factory/openSUSE_Factory/Mono:Factory.repo -e -f -p 50
RUN zypper --gpg-auto-import-keys ref
RUN zypper patch -y -l --with-optional ; exit 0

## do it again, could be an update for zypper in there
RUN zypper patch -y -l --with-optional ; exit 0

## install everything needed to run the bot
RUN zypper install -y -l --recommends mono-core mono-extras unzip curl screen sed less htop

## clean zypper cache for smaller image
RUN zypper cc --all

## setup /run/uscreens
RUN mkdir -p /run/uscreens
RUN chmod a+rwx,o+t /run/uscreens

## create an opensim user and group
RUN useradd \
        -c "The user that runs the opensim regions" \
        --no-log-init \
        -m \
        -U \
        opensim

##Adding opensim zip file
# Unpacking to /home/opensim/opensim
ADD ["http://opensimulator.org/dist/opensim-0.9.1.1.zip","/tmp/opensim.zip"]
RUN unzip /tmp/opensim.zip -d /home/opensim
RUN mv /home/opensim/opensim-0.9.1.1 /home/opensim/opensim

# create persistence
RUN mkdir -p /home/opensim/opensim/bin/persistence
ADD ["SQLiteStandalone.ini", "/home/opensim/opensim/bin/config-include/storage/SQLiteStandalone.ini"]

# change ownership of everything
RUN chown -R opensim:opensim /home/opensim/opensim

# aivate default config
RUN cp /home/opensim/opensim/bin/pCampBot.ini.example /home/opensim/opensim/bin/pCampBot.ini
RUN cp /home/opensim/opensim/bin/OpenSim.ini.example /home/opensim/opensim/bin/OpenSim.ini
RUN cp /home/opensim/opensim/bin/config-include/StandaloneCommon.ini.example /home/opensim/opensim/bin/config-include/StandaloneCommon.ini
RUN sed  -i 's/; Include-Architecture = "config-include\/Standalone.ini"/Include-Architecture = "config-include\/Standalone.ini"/' /home/opensim/opensim/bin/OpenSim.ini

# Startup script
COPY opensim.sh /home/opensim/opensim/bin
RUN chmod +x  /home/opensim/opensim/bin/opensim.sh

# To allow access from outside of the container  to the container service at these ports
# Need to allow ports access rule at firewall too .
# by default we're exposing one port so we can run one regions  
EXPOSE 9000/tcp
EXPOSE 9000/udp

WORKDIR /home/opensim/opensim/bin
USER opensim
CMD ["/home/opensim/opensim/bin/opensim.sh"]
