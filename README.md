<h1 align="center">Hako 📦</h1>

<p align="center">
  A state management library for Flutter designed for simplicity, performance, and testability.
  <br /><br />
  <a href="https://pub.dev/packages/hako"><img src="https://img.shields.io/pub/v/hako?style=for-the-badge" /></a>
  <a href="https://pub.dev/packages/hako_test"><img src="https://img.shields.io/pub/v/hako_test?style=for-the-badge" /></a>
  <a href="https://github.com/parsodyl/hako/actions/workflows/dart.yml"><img src="https://img.shields.io/github/actions/workflow/status/parsodyl/hako/dart.yml?style=for-the-badge" /></a>
  <a href="https://github.com/parsodyl/hako/blob/main/LICENSE"><img src="https://img.shields.io/github/license/parsodyl/hako?style=for-the-badge" /></a>
</p>

---

## Packages

This repository is a monorepo containing the following packages:

| Package | Version | Description |
| :--- | :--- | :--- |
| [`hako`](packages/hako) | [![pub package](https://img.shields.io/pub/v/hako.svg)](https://pub.dev/packages/hako) | Core state management library for Flutter. |
| [`hako_test`](packages/hako_test) | [![pub package](https://img.shields.io/pub/v/hako_test.svg)](https://pub.dev/packages/hako_test) | Testing library providing `hakoTest`, `expectHakoEmits`, and event matchers. |

---

## Overview

Hako (箱), the Japanese word for *box*, is a state management library built on top of `provider`. It serves as a natural progression for developers who use `provider` directly for state management and need granular state rebuilding and a more structured approach to state organization through an explicit and minimal API.

### Core Features

* **Granular Rebuilding**: Hako selects state values internally. This ensures that widgets listening to a `Hako` container will only rebuild when the specific state values they depend on have changed.
* **Minimal & Explicit API**: The public API is focused on three core operations: registering state in the constructor, reading state with `get()`, and updating state with `set()`.
* **No Code Generation**: The library is built with handwritten Dart and requires no build runners or generated files, keeping the development workflow simple.
* **Testable by Design**: Full companion testing suite with [`hako_test`](packages/hako_test) featuring `hakoTest` and `expectHakoEmits`.
* **State Change Observability**: An optional event stream can be opened to monitor all state access (`GetEvent`) and mutation (`SetEvent`) operations.

---

## Documentation

For detailed package guides and API documentation:
- [Hako Documentation](packages/hako/README.md)
- [Hako Test Documentation](packages/hako_test/README.md)

---

## Contributing

If you find a bug or would like to see a new feature, please create an issue or pull request.
