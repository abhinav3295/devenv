FROM openjdk:8-jdk-alpine3.9

########################
# Add build tools      #
########################

RUN apk add bash git maven gradle tar

########################
# Setup defaults       #
########################
ADD prepare_submission.sh /root/prepare_submission.sh
WORKDIR /workspace
ENV PROBLEM_NAME "sample_problem"
CMD [ "bash", "-c", "/root/prepare_submission.sh", "${PROBLEM_NAME}" ]