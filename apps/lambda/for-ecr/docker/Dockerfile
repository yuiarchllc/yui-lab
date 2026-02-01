FROM public.ecr.aws/lambda/nodejs:22

COPY dist/ ./

CMD ["index.handler"]

# イメージを確認する場合は以下を実施
# docker run --rm -it --entrypoint /bin/bash lambda-for-ecr:latest