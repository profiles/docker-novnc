FROM alpine:3.12.9

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	REMOTE_HOST=localhost \
	REMOTE_PORT=5900

RUN apk --update --upgrade add git bash supervisor nodejs nodejs-npm novnc
RUN git clone https://github.com/novnc/noVNC.git /root/noVNC \
	&& git clone https://github.com/novnc/websockify /root/noVNC/utils/websockify
RUN rm -rf /root/noVNC/.git \
	&& rm -rf /root/noVNC/utils/websockify/.git
RUN cd /root/noVNC \
	&& npm install -f npm@latest \
	&& npm install -f \
	&& ./utils/use_require.js --as commonjs --with-app
RUN cp /root/noVNC/node_modules/requirejs/require.js /root/noVNC/build \
	&& sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/launch.sh
RUN apk del git nodejs-npm nodejs
	
RUN cp /root/noVNC/build/vnc.html /root/noVNC/build/index.html

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8081

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
