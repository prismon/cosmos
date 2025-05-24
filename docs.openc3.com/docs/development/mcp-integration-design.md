---
title: MCP Integration Design
description: Plan for integrating the Model Context Protocol into COSMOS
sidebar_custom_props:
  myEmoji: '\ud83d\udc1b'
---

## Overview

OpenC3 COSMOS already exposes JSON-RPC and WebSocket streaming APIs. To support the Model Context Protocol (MCP) we plan to provide an adapter that translates MCP messages into existing COSMOS API calls. The adapter will run as a plugin microservice so it can be managed and secured like other extensions.

## Architecture

1. **MCP Microservice** – A plugin-defined service started with `CMD` and optionally exposed via `ROUTE_PREFIX` through Traefik. This service handles MCP requests.
2. **COSMOS APIs** – The microservice interacts with the existing JSON API (`/openc3-api/api`) for commands and telemetry and may subscribe to the Streaming API (`/openc3-api/cable`) for real‑time telemetry.
3. **Authentication** – Incoming MCP requests must supply a COSMOS token. The microservice should validate tokens using the `AuthModel` logic available in both the Ruby and Python helper libraries.

## Suggested Libraries

- **Ruby** – Consider using an MCP client/server gem such as [`mcp`](https://rubygems.org/) if available. Otherwise implement a simple TCP or HTTP parser for the required MCP messages.
- **Python** – Look for packages like `mcpy` or `mcp-protocol` on PyPI. If none meet the needs, the adapter can parse MCP frames directly using Python's `socket` or `asyncio` libraries.

These libraries should be included in the plugin's Gem or Python requirements file so they are installed when the plugin is built.

## TODO

1. Prototype a plugin with a basic MCP microservice that authenticates via COSMOS.
2. Map MCP operations to JSON API calls for commands and telemetry retrieval.
3. Add streaming support by forwarding telemetry updates from the WebSocket API to MCP clients.
4. Provide configuration options for ROUTE_PREFIX and service port.
5. Document how to install and run the plugin.

