uid=$(shell id -u)
gid=$(shell id -g)
install:
	install -m 755 -g ${gid} -o ${uid} ./cmd_parser.sh /usr/local/bin/
