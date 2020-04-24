FROM ubuntu:18.04

LABEL maintaner "shmileee [https://github.com/shmileee/docker-rehlds]"

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.10.0-git5392

RUN apt-get update -q && apt-get install -y \
    lib32gcc1 \
    unzip \
    curl

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -qL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit || true
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh

# Add custom cstrike folder
ADD files/cstrike /opt/hlds/cstrike

# Install metamod
RUN curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -

# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/amxxdrop/1.10/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/amxxdrop/1.10/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -

# Install ReHLDS
RUN curl -sqL "http://teamcity.rehlds.org/guestAuth/repository/downloadAll/Rehlds_Linux/23530:id/artifacts.zip" > rehlds.zip && \
    unzip -d rehlds rehlds.zip

RUN find rehlds -type f -not -path "*releaseRehldsNofixes*" -print0 | xargs -0 -I '{}' bash -c 'mv -f {} /opt/hlds && chmod +x /opt/hlds/$(basename {})'

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
