// app/javascript/controllers/checkin_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["locationFields", "latitude", "longitude"];

  connect() {
    this.toggleMode();
  }

  toggleMode() {
    const onsiteRadio = this.element.querySelector('input[value="onsite"]');
    if (onsiteRadio && onsiteRadio.checked) {
      this.locationFieldsTarget.classList.remove("hidden");
    } else {
      this.locationFieldsTarget.classList.add("hidden");
    }
  }

  getCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.latitudeTarget.value = position.coords.latitude.toFixed(8);
          this.longitudeTarget.value = position.coords.longitude.toFixed(8);
        },
        (error) => {
          alert("ไม่สามารถรับตำแหน่งได้: " + error.message);
        },
      );
    } else {
      alert("Browser ไม่รองรับ Geolocation");
    }
  }
}
