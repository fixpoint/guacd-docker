# guacd-docker

[![Build](https://github.com/fixpoint/guacd-docker/actions/workflows/build.yml/badge.svg)](https://github.com/fixpoint/guacd-docker/actions/workflows/build.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker repository](https://img.shields.io/badge/docker-ghcr.io/fixpoint/guacd-orange.svg?logo=docker&logoColor=white)](https://github.com/orgs/fixpoint/packages/container/package/guacd)

This repository is for building `guacd` docker image of [apache/guacamole-server][] as a multi platform docker image while [the original docker image](https://hub.docker.com/r/guacamole/guacd) only provides image for `linux/amd64`.

The docker image supports the followings:

- `linux/amd64`
- `linux/arm64`
- `linux/arm`

[apache/guacamole-server]: https://github.com/apache/guacamole-server

## Usage

Use `ghcr.io/fixpoint/guacd` like

```
docker pull ghcr.io/fixpoint/guacd
docker run --name my-guacd -d -p 4822:4822 ghcr.io/fixpoint/guacd
```

See [original overview](https://hub.docker.com/r/guacamole/guacd) for more detail.

## License

The code in this repository follows MIT license, texted in [LICENSE](./LICENSE).
Contributors need to agree that any modifications sent in this repository follow
the license.

The `guacd` itself follows Apache License 2.0, texted in [LICENSE.guacd](./LICENSE.guacd).
The file has copied from [apache/guacamole-server][].
