docker build -t tini-loongarch64 .
docker run --rm -v "$(pwd)"/dist:/dist tini-loongarch64
ls -al "$(pwd)"/dist