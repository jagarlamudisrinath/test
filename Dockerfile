# Use an official Python runtime as a parent image
FROM python:3.10.11-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install Java (OpenJDK 11) and necessary tools
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk gnupg2 curl build-essential wget && \
    apt-get clean;

# Set JAVA_HOME environment variable
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        JAVA_HOME_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        JAVA_HOME_ARCH="arm64"; \
    else \
        JAVA_HOME_ARCH="$ARCH"; \
    fi && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-$JAVA_HOME_ARCH" > /etc/environment && \
    . /etc/environment

#ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-$ARCH
ENV PATH $JAVA_HOME/bin:$PATH

# Add sbt repository and import the GPG key directly
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --dearmor > /usr/share/keyrings/sbt-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/sbt-archive-keyring.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list && \
    echo "deb [signed-by=/usr/share/keyrings/sbt-archive-keyring.gpg] https://repo.scala-sbt.org/scalasbt/debian /" >> /etc/apt/sources.list.d/sbt.list && \
    apt-get update && \
    apt-get install -y sbt=1.9.3

# Install Scala
RUN curl -fsL https://downloads.lightbend.com/scala/2.12.11/scala-2.12.11.tgz | tar xfz - -C /usr/local && \
    ln -s /usr/local/scala-2.12.11 /usr/local/scala

# Set SCALA_HOME environment variable and update PATH
ENV SCALA_HOME /usr/local/scala
ENV PATH $SCALA_HOME/bin:$PATH


# Install Python packages
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        JAVA_HOME_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        JAVA_HOME_ARCH="arm64"; \
    else \
        JAVA_HOME_ARCH="$ARCH"; \
    fi && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-$JAVA_HOME_ARCH && pip install --no-cache-dir jep nbformat

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Run command when the container launches
CMD ["bash"]
