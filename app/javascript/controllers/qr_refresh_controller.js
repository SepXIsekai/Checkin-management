// app/javascript/controllers/qr_refresh_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["qrcode", "url"];
  static values = { url: String };

  connect() {
    this.refresh();
    this.interval = setInterval(() => this.refresh(), 30000);
  }

  disconnect() {
    clearInterval(this.interval);
  }

  async refresh() {
    const response = await fetch(this.urlValue);
    const data = await response.json();

    this.qrcodeTarget.innerHTML = data.svg;
    this.urlTarget.textContent = data.url;
  }
}
