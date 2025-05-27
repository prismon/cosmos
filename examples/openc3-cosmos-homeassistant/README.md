# OpenC3 COSMOS Home Assistant Plugin

This example plugin demonstrates how to integrate Home Assistant with COSMOS using the Python `homeassistant` package.

## Building the Plugin

Use the COSMOS CLI to build the plugin gem:

```bash
openc3.sh cli rake build VERSION=1.0.0
```

## Installation

1. Navigate to `http://localhost:2900/tools/admin` in your browser.
2. Click the paperclip icon and select the generated `.gem` file.
3. Fill out the plugin parameters for your Home Assistant instance.
4. Click **Install**.

## Home Assistant Python Module

The microservice included with this plugin relies on the [`homeassistant`](https://pypi.org/project/homeassistant/) Python package. The COSMOS Python environment installs this dependency via Poetry. Ensure that the `openc3/python/pyproject.toml` file contains:

```toml
"homeassistant (>=2024.2.0,<2025.0.0)",
```

After modifying `pyproject.toml`, run:

```bash
cd openc3/python
poetry install
```

This downloads the `homeassistant` package so the plugin can import it when running inside COSMOS.

## Usage

Once installed, the plugin starts a microservice that connects to your Home Assistant instance. The example configuration exposes a `HOME_ASSISTANT_BRIDGE` microservice which can call services and read states. Adjust the microservice code to fit your specific Home Assistant automations.
