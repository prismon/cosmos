import time
from homeassistant import client as ha_client
from openc3.microservices.microservice import Microservice
from openc3.utilities.sleeper import Sleeper


class HomeAssistantBridge(Microservice):
    def __init__(self, name):
        super().__init__(name)
        self.host = "localhost"
        self.port = 8123
        self.token = None
        for option in self.config.get("options", []):
            match option[0].upper():
                case "HOST":
                    self.host = option[1]
                case "PORT":
                    self.port = int(option[1])
                case _:
                    self.logger.error(f"Unknown option {option} for {name}")
        self.token = self.secrets.env("HA_TOKEN")
        self.sleeper = Sleeper()

    def run(self):
        url = f"http://{self.host}:{self.port}"
        self.logger.info(f"Connecting to Home Assistant at {url}")
        api = ha_client.HomeAssistant(url, self.token)
        while True:
            if self.cancel_thread:
                break
            # Example: fetch and log the states of all entities
            try:
                states = api.get_states()
                self.logger.info(f"Retrieved {len(states)} states from Home Assistant")
            except Exception as err:
                self.logger.error(f"Home Assistant request failed: {err}")
            if self.sleeper.sleep(60):
                break

    def shutdown(self):
        self.sleeper.cancel()
        super().shutdown()


if __name__ == "__main__":
    HomeAssistantBridge.class_run()

