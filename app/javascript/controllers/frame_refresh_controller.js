// app/javascript/controllers/frame_refresh_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 3000 },
  };

  connect() {
    this.timer = setInterval(() => {
      this.refresh();
    }, this.intervalValue);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  refresh() {
    fetch(this.urlValue, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
      })
      .catch(() => {});
  }
}
