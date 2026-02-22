// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.dismiss();
    }, 3000);
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-x-full");
    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
