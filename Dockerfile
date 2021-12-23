ARG ALPINE_BASE="3.12.9"
ARG NOVNC_TAG="v1.3.0"
ARG WEBSOCKIFY_TAG="v0.10.0"
ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

FROM alpine:${ALPINE_BASE}

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="docker-snapserver" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rugarci/docker-snapserver" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.schema-version="1.0"
    org.opencord.component.novnc.version=$NOVNC_TAG \
    org.opencord.component.novnc.vcs-url="https://github.com/novnc/noVNC" \
    org.opencord.component.websockify.version=$WEBSOCKIFY_TAG \
    org.opencord.component.websockify.vcs-url="https://github.com/novnc/websockify"
    
ENV VNC_SERVER "localhost:5900"

RUN apk --no-cache add \
        bash \
        python3 \
        python3-dev \
        gfortran \
        py-pip \
        build-base \
        procps \
        git
        
RUN pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir numpy

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN git config --global advice.detachedHead false && \
    git clone https://github.com/novnc/noVNC --branch ${NOVNC_TAG} /root/noVNC && \
    git clone https://github.com/novnc/websockify --branch ${WEBSOCKIFY_TAG} /root/noVNC/utils/websockify

RUN cp /root/noVNC/vnc.html /root/noVNC/index.html

RUN sed -i "/wait ${proxy_pid}/i if [ -n \"\$AUTOCONNECT\" ]; then sed -i \"s/'autoconnect', false/'autoconnect', '\$AUTOCONNECT'/\" /root/noVNC/app/ui.js; fi" /root/noVNC/utils/novnc_proxy

RUN sed -i "/wait ${proxy_pid}/i if [ -n \"\$VNC_PASSWORD\" ]; then sed -i \"s/WebUtil.getConfigVar('password')/'\$VNC_PASSWORD'/\" /root/noVNC/app/ui.js; fi" /root/noVNC/utils/novnc_proxy

RUN sed -i "/wait ${proxy_pid}/i if [ -n \"\$VIEW_ONLY\" ]; then sed -i \"s/UI.rfb.viewOnly = UI.getSetting('view_only');/UI.rfb.viewOnly = \$VIEW_ONLY;/\" /root/noVNC/app/ui.js; fi" /root/noVNC/utils/novnc_proxy

ENTRYPOINT [ "bash", "-c", "/root/noVNC/utils/novnc_proxy --vnc ${VNC_SERVER}" ]
