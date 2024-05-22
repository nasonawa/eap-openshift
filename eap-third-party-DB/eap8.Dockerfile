# Use EAP 8 Builder image to create a JBoss EAP 8 server with its default configuration
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest AS builder
# With these 3 environments variables, a JBoss EAP 8 server is provisioned with the "same"
# cloud configuration that EAP standalone.xml
ENV GALLEON_PROVISION_FEATURE_PACKS=org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack,org.jboss.eap:eap-datasources-galleon-pack
ENV GALLEON_PROVISION_LAYERS=datasources-web-server,postgresql-datasource
ENV GALLEON_PROVISION_CHANNELS=org.jboss.eap.channels:eap-8.0
ENV POSTGRESQL_DRIVER_VERSION="42.7.3"

# ENV MAVEN_MIRROR_URL <maven mirror URL if needed>
RUN /usr/local/s2i/assemble

# Copy the JBoss EAP 8 server from the previous step into the runtime image
FROM registry.redhat.io/jboss-eap-8-tech-preview/eap8-openjdk17-runtime-openshift-rhel8:latest AS runtime
ENV POSTGRESQL_USER="eapuser"
ENV POSTGRESQL_PASSWORD="password"
ENV POSTGRESQL_DATABASE="sampledb"

COPY --from=builder --chown=jboss:root $JBOSS_HOME $JBOSS_HOME
COPY --chown=jboss:root jbossopenshift.ear $JBOSS_HOME/standalone/deployments
##############################################################################################
#
# Steps to add:                                                                                    
# (1) COPY or ADD the WAR/EAR to $JBOSS_HOME/standalone/deployments. 
#       For example:
#       COPY --chown=jboss:root test.war $JBOSS_HOME/standalone/deployments                                
# (2) (Optional) Modify the $JBOSS_HOME/standalone/configuration/standalone.xml (not standalone-openshift.xml)
# (3) (Optional) set ENV variable CONFIG_IS_FINAL to true if no modification is needed by start up scripts. 
#       For example:
#       ENV CONFIG_IS_FINAL=true 
# (4) (Optional) copy a modified standalone.xml in $JBOSS_HOME/standalone/configuration/
#       For example:
#       COPY --chown=jboss:root standalone.xml  $JBOSS_HOME/standalone/configuration
##############################################################################################

RUN chmod -R ug+rwX $JBOSS_HOME