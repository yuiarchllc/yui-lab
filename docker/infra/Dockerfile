FROM hashicorp/terraform:1.13.4

RUN apk add --update
RUN apk --no-cache add curl wget make bash jq aws-cli

ARG ECSPRESSO_VERSION="2.2.0"
RUN wget "https://github.com/kayac/ecspresso/releases/download/v${ECSPRESSO_VERSION}/ecspresso_${ECSPRESSO_VERSION}_linux_arm64.tar.gz" -O ecspresso.tar.gz && \
    tar -xzf ecspresso.tar.gz -C /usr/local/bin && \
    rm ecspresso.tar.gz

WORKDIR /work

ENTRYPOINT ["/bin/bash"]