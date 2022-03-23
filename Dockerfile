FROM docker:20.10

ENV CODECLIMATE_URL="https://github.com/codeclimate/codeclimate/archive/master.tar.gz"
ENV CONTAINER_STRUCTURE_TEST_URL="https://storage.googleapis.com/container-structure-test/v1.11.0/container-structure-test-linux-amd64"
ENV GITLAB_RUNNER_URL="https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"

WORKDIR /work

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --no-cache add \
    jq=~1 \
    && curl -L "$CODECLIMATE_URL" | tar xvz \
    && cd codeclimate-* \
    && make install \
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
LABEL org.opencontainers.image.description="A DIND Container for Testing with ContainerStructureTest and GitLab Runner"
LABEL org.opencontainers.image.documentation="https://github.com/megabyte-labs/docker-test/blob/master/README.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.source="https://gitlab.com/megabyte-labs/dockerfile/ci-pipeline/molecule.git"
LABEL org.opencontainers.image.url="https://megabyte.space"
LABEL org.opencontainers.image.vendor="Megabyte Labs"
LABEL org.opencontainers.image.version=$VERSION
LABEL space.megabyte.type="ci-pipeline"
