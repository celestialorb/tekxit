FROM openjdk:8-jre-alpine

ARG TEKXIT_VERSION="1.0.4"
ENV TEKXIT_SERVER_PROPERTIES_FILE="/opt/tekxit/server.properties.orig"
ENV TEKXIT_SERVER_UNIVERSE_DIRECTORY="/opt/tekxit/universe"
ENV TEKXIT_SERVER_WORLD="world"

# The user that runs the minecraft server and own all the data
# you may want to change this to match your local user
ENV USER=tekxit
ENV UID=1000

# Memory limits for the java VM that can be overridden via env.
ENV _JAVA_OPTIONS="-Xms1G -Xmx4G"

# the tekxit server files are published as .7z archive so we need something to unpack it.
RUN apk update && apk add curl unzip

# create a new user to run our minecraft-server
RUN adduser \
    --disabled-password \
    --gecos "" \
    --uid "${UID}" \
    "${USER}"

# declare a directory for the data directory
# survives a container restart
RUN mkdir -p /opt/tekxit
RUN chown -R ${USER} /opt/tekxit

# Switch to the minecraft user since we don't need root at this point
USER ${USER}
WORKDIR /opt/tekxit

# Download server files
RUN curl -sSL "https://tekxit.xyz/downloads/${TEKXIT_VERSION}TekxitPiServer.zip" -o /tmp/tekxit-server.zip

# Unpack server files
RUN \
    unzip /tmp/tekxit-server.zip -d /tmp/tekxit && \
    cp -r /tmp/tekxit/${TEKXIT_VERSION}TekxitPiServer/* /opt/tekxit && \
    rm -rf /tmp/tekxit

# Make a link to the forge JAR file.
RUN ln -s $(find ./ -maxdepth 1 -type f -name "forge*.jar") ./forge.jar

# EXPOSE 19132
EXPOSE 25565
ENTRYPOINT [ "sh", "-c", "cp ${TEKXIT_SERVER_PROPERTIES_FILE} ./server.properties && java -server -jar ./forge.jar --nogui --universe ${TEKXIT_SERVER_UNIVERSE_DIRECTORY} --world ${TEKXIT_SERVER_WORLD}" ]
