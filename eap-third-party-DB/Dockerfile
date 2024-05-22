FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8 as BUILDER

# This option will include all layers:
ENV GALLEON_PROVISION_DEFAULT_FAT_SERVER=true

# Alternatively you can specify one of the layers as shown in the docs, which would reduce the image size by trimming down to only what is needed
# https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.4/html-single/getting_started_with_jboss_eap_for_openshift_container_platform/index#capability-trimming-eap-foropenshift_default
#ENV GALLEON_PROVISION_LAYERS=datasources-web-server

RUN /usr/local/s2i/assemble

# From EAP 7.4 runtime image, copy the builder's server & add the war
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-runtime-openshift-rhel8 as RUNTIME
USER root
COPY --from=BUILDER --chown=jboss:root $JBOSS_HOME $JBOSS_HOME
COPY jbossopenshift.ear $JBOSS_HOME/standalone/deployments/

# (Optional) set ENV variable CONFIG_IS_FINAL to true if no modification is needed by start up scripts.  
#  For example:
#  ENV CONFIG_IS_FINAL=true 

RUN chmod -R ug+rwX $JBOSS_HOME
USER jboss
CMD $JBOSS_HOME/bin/openshift-launch.sh