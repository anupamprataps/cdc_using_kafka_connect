FROM confluentinc/cp-kafka-connect:7.5.0


# Switch to root for installations
USER root


# Install needed connectors
RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.4.2 && \
   confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.6


# Download latest Redshift JDBC driver (version 2.1.0.33) - using hardcoded path
RUN curl -L "https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/2.1.0.33/redshift-jdbc42-2.1.0.33.jar" \
   -o /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/redshift-jdbc42-2.1.0.33.jar && \
   chmod 644 /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/redshift-jdbc42-2.1.0.33.jar


# Download required AWS SDK dependencies for Redshift JDBC driver
RUN cd /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib && \
   curl -L "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.12.529/aws-java-sdk-core-1.12.529.jar" \
   -o aws-java-sdk-core-1.12.529.jar && \
   curl -L "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-redshift/1.12.529/aws-java-sdk-redshift-1.12.529.jar" \
   -o aws-java-sdk-redshift-1.12.529.jar && \
   curl -L "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-sts/1.12.529/aws-java-sdk-sts-1.12.529.jar" \
   -o aws-java-sdk-sts-1.12.529.jar && \
   curl -L "https://repo1.maven.org/maven2/joda-time/joda-time/2.12.5/joda-time-2.12.5.jar" \
   -o joda-time-2.12.5.jar && \
   curl -L "https://repo1.maven.org/maven2/com/amazonaws/jmespath-java/1.12.529/jmespath-java-1.12.529.jar" \
   -o jmespath-java-1.12.529.jar && \
   curl -L "https://repo1.maven.org/maven2/software/amazon/ion/ion-java/1.0.2/ion-java-1.0.2.jar" \
   -o ion-java-1.0.2.jar && \
   curl -L "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.17.0/jackson-databind-2.17.0.jar" \
   -o jackson-databind-2.17.0.jar && \
   curl -L "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.17.0/jackson-core-2.17.0.jar" \
   -o jackson-core-2.17.0.jar && \
   curl -L "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.17.0/jackson-annotations-2.17.0.jar" \
   -o jackson-annotations-2.17.0.jar && \
   curl -L "https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.14/httpclient-4.5.14.jar" \
   -o httpclient-4.5.14.jar && \
   curl -L "https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.16/httpcore-4.4.16.jar" \
   -o httpcore-4.4.16.jar && \
   chmod 644 *.jar


# Add PostgreSQL JDBC driver for better compatibility (using Maven Central to avoid SSL issues)
RUN curl -k -L "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar" \
   -o /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/postgresql-42.7.1.jar && \
   chmod 644 /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/postgresql-42.7.1.jar


# Verify the drivers are in place
RUN ls -lah /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/redshift* && \
   ls -lah /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/aws-java-sdk*


# Set environment variables
ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"


# Switch back to appuser
USER appuser
