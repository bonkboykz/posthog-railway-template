FROM clickhouse/clickhouse-server:25.8.12.129

COPY ./posthog/posthog/idl /idl
COPY ./posthog/docker/clickhouse/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
COPY ./posthog/docker/clickhouse/config.xml /etc/clickhouse-server/config.xml
COPY ./posthog/docker/clickhouse/config.d/default.xml /etc/clickhouse-server/config.d/default.xml
COPY ./posthog/docker/clickhouse/users.xml /etc/clickhouse-server/users.xml
COPY ./posthog/docker/clickhouse/user_defined_function.xml /etc/clickhouse-server/user_defined_function.xml
# user_scripts live outside /var/lib/clickhouse: a volume mounted there would hide them
COPY ./posthog/posthog/user_scripts /opt/clickhouse/user_scripts

# Hosts from env instead of compose short names: ZOOKEEPER_HOST is required at runtime;
# the single-node cluster points at itself by its Railway private domain
# (PostHog's ON CLUSTER migrations connect to the host listed here, so 'localhost' breaks from other services).
RUN sed -i 's|<host>zookeeper</host>|<host from_env="ZOOKEEPER_HOST"/>|' /etc/clickhouse-server/config.xml \
 && sed -i 's|<host>clickhouse</host>|<host from_env="CLICKHOUSE_CLUSTER_HOST"/>|g' /etc/clickhouse-server/config.d/default.xml \
 && printf '<clickhouse>\n    <user_scripts_path>/opt/clickhouse/user_scripts/</user_scripts_path>\n</clickhouse>\n' \
      > /etc/clickhouse-server/config.d/user_scripts.xml \
 && grep -q 'from_env="ZOOKEEPER_HOST"' /etc/clickhouse-server/config.xml \
 && ! grep -q '<host>clickhouse</host>' /etc/clickhouse-server/config.d/default.xml
