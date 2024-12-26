# Example Dockerfile that installs and configures `git-diff-dvc.sh` and `git-diff-parquet.sh`, and
# verifies the examples in the README
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y curl git jq python3 python3-pip python3-venv wget yq

ENV PATH=/root/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && cargo install parquet2json

ENV VIRTUAL_ENV=.venv
ENV PATH=/$VIRTUAL_ENV/bin:$PATH
RUN python3 -m venv $VIRTUAL_ENV \
 && pip3 install 'bmdf>=0.3.3' 'qmdx>=0.0.4' dvc-s3

SHELL ["/bin/bash", "-c"]

ENV PATH=/src/pqt:$PATH
WORKDIR /src

RUN git clone https://github.com/ryan-williams/parquet-helpers pqt
RUN echo ". /src/pqt/.pqt-rc" >> /root/.bashrc

WORKDIR /src/dvc
ENV PATH=/src/dvc:$PATH

COPY . .
COPY .aws/credentials /root/.aws/credentials
RUN echo "*.parquet diff=parquet" > .gitattributes
RUN git config diff.parquet.command git-diff-parquet.sh
RUN git config diff.parquet.textconv "parquet2json-all -n2"
RUN git config diff.noprefix true
RUN git checkout test
RUN dvc pull -r s3 -R -A
RUN git checkout main
ENV SHELL=/bin/bash
# RUN git checkout -- .github
RUN echo ". /src/dvc/.dvc-rc" >> /root/.bashrc

RUN echo "*.dvc diff=dvc" >> .gitattributes
RUN git config diff.dvc.command git-diff-dvc.sh
RUN git config diff.dvc.textconv git-textconv-dvc.sh
RUN apt-get install -y file

ENTRYPOINT [ "/bin/bash", "-ic", "mdcmd && git diff --exit-code" ]
