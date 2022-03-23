FROM docker:20.10 as build

ENV DOCKERSLIM_RELEASE_URL https://downloads.dockerslim.com/releases/
ENV DOCKERSLIM_REPO_API_URL https://api.github.com/repos/docker-slim/docker-slim/releases/latest

RUN apk --no-cache add \
  bash~=5
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
RUN apk --no-cache add --virtual build-dependencies \
  curl~=7 \
  upx~=3 \
  && DEST_DIR="/tmp" \
  && FILE_NAME="docker-slim.tar.gz" \
  && RELEASES=$(curl "${DOCKERSLIM_REPO_API_URL}") \
  && LATEST_VERSION=$(echo "$RELEASES" | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$') \
  && curl "${DOCKERSLIM_RELEASE_URL%/}/${LATEST_VERSION}/dist_linux.tar.gz" -o "${DEST_DIR}/${FILE_NAME}" \
  && tar -xzf "${DEST_DIR}/${FILE_NAME}" --strip-components=1 -C /usr/local/bin \
  && upx /usr/local/bin/docker-slim \
  && upx /usr/local/bin/docker-slim-sensor

FROM docker:20.10 AS test

ENV CODECLIMATE_URL="https://github.com/codeclimate/codeclimate/archive/master.tar.gz"
ENV CONTAINER_STRUCTURE_TEST_URL="https://storage.googleapis.com/container-structure-test/v1.11.0/container-structure-test-linux-amd64"
ENV GITLAB_RUNNER_URL="https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"

WORKDIR /work

COPY --from=build /usr/local/bin/docker-slim /usr/local/bin/docker-slim
COPY --from=build /usr/local/bin/docker-slim-sensor /usr/local/bin/docker-slim-sensor
COPY bin /usr/local/bin

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --no-cache add \
  bash=~5 \
  curl=~7 \
  jq=~1 \
  && curl -L --output /usr/local/bin/gitlab-runner "$GITLAB_RUNNER_URL" \
  && curl -LO "$CONTAINER_STRUCTURE_TEST_URL" \
  && mv container-structure-test-linux-amd64 container-structure-test \
  && chmod +x container-structure-test \
  && mv container-structure-test /usr/local/bin/

ARG BUILD_DATE
ARG REVISION
ARG VERSION

LABEL maintainer="Megabyte Labs <help@megabyte.space"
LABEL org.opencontainers.image.authors="Brian Zalewski <brian@megabyte.space>"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.description="A Docker-in-Docker container for testing with ContainerStructureTest and GitLab Runner"
LABEL org.opencontainers.image.documentation="https://github.com/megabyte-labs/docker-test/blob/master/README.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.source="https://github.com/megabyte-labs/docker-test.git"
LABEL org.opencontainers.image.url="https://megabyte.space"
LABEL org.opencontainers.image.vendor="Megabyte Labs"
LABEL org.opencontainers.image.version=$VERSION
LABEL space.megabyte.type="ci-pipeline"
