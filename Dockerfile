FROM alpine:3.10 AS base

# Referenced from https://github.com/szyhf/DIDockerfiles/tree/master/litecoin/alpine

ENV LITECOIN_VERSION=0.18.1
ENV GLIBC_VERSION=2.31-r0

# This SHA is based on version 0.18.1 - if another version is used, you'll need to update sum
ENV LITECOIN_SHASUM="ca50936299e2c5a66b954c266dcaaeef9e91b2f5307069b9894048acf3eb5751"
ENV LITECOIN_SOURCE="https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz"
ENV LITECOIN_DEST="/litecoin-${LITECOIN_VERSION}.tar.gz"

RUN apk update \
	&& apk --no-cache add wget ca-certificates tzdata \
	&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
	&& wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
 	&& apk --no-cache add glibc-${GLIBC_VERSION}.apk \
	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \
	&& rm -rf /glibc-${GLIBC_VERSION}.apk \
	&& rm -rf /glibc-bin-${GLIBC_VERSION}.apk

FROM base AS slimcoin

RUN  wget -q -O ${LITECOIN_DEST} ${LITECOIN_SOURCE} \
  && sha256sum "${LITECOIN_DEST}" \
  && echo "${LITECOIN_SHASUM}  ${LITECOIN_DEST}" | sha256sum -c -

RUN tar xzvf ${LITECOIN_DEST} \
	&& mkdir /root/.litecoin \
	&& mv /litecoin-${LITECOIN_VERSION}/bin/* /usr/local/bin/ \
	&& rm -rf /litecoin-${LITECOIN_VERSION}/ \
	&& rm -rf ${LITECOIN_DEST} \
	&& rm -rf /glibc-${GLIBC_VERSION}.apk \
	&& rm -rf /glibc-bin-${GLIBC_VERSION}.apk

EXPOSE 9333 9332
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "pgrep -f litecoind || exit 1" ]

CMD ["litecoind"]
