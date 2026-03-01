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
    this.stopRefreshing();
  }

  stopRefreshing() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  refresh() {
    fetch(this.urlValue, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => {
        if (!response.ok) {
          this.stopRefreshing();
          return;
        }
        return response.text();
      })
      .then((html) => {
        if (html) {
          Turbo.renderStreamMessage(html);
        }
      })
      .catch(() => {
        this.stopRefreshing();
      });
  }
}
