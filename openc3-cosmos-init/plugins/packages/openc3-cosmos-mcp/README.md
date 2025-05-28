# OpenC3 COSMOS MCP Plugin

This plugin exposes a microservice implementing the Mission Control Protocol (MCP).
The microservice provides a lightweight HTTP adapter that translates MCP style
requests into COSMOS API calls.

### Endpoints

```
POST /mcp/cmd
  {"token":"TOKEN","target":"TGT","command":"CMD","params":{}}

GET  /mcp/tlm?token=TOKEN&target=TGT&packet=PKT&item=ITEM
```

Both endpoints require a valid COSMOS token which is verified using
`AuthModel`. The adapter can be configured through `plugin.txt` to run on a
specific port and route prefix.
