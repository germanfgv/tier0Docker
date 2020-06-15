FROM cmssw/cmsweb:20190814

RUN echo "Adding the AFS cmst1:zh user"
RUN groupadd -g 1399 zh
RUN adduser -u 31961 -g 1399 cmst1
RUN adduser -u 103031 -g 1399 cmst0

### Setup directory and files permissions
RUN install -o cmst0 -g 1399 -d /data/srv /data/admin /data/certs
RUN chown root:1399 /data; pip install htcondor

ENV WDIR=/data

# Add install script
ADD install.sh ${WDIR}/install.sh

# Add wmagent run script
ADD run.sh ${WDIR}/run.sh

RUN chown cmst0 ${WDIR}/run.sh ${WDIR}/install.sh

USER cmst0

# Add .bashrc with alias and environment
ADD .bashrc /home/cmst0/.bashrc

WORKDIR ${WDIR}

RUN ${WDIR}/install.sh 

RUN echo "Installation completed!"

# commenting this out for testing
#CMD ["./run.sh"]
CMD ["/bin/bash", "-l"]
