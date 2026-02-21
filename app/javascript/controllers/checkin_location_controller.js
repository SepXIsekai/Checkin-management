// app/javascript/controllers/checkin_location_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "latitude", "longitude"];

  getLocationAndSubmit() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.latitudeTarget.value = position.coords.latitude;
          this.longitudeTarget.value = position.coords.longitude;
          this.formTarget.requestSubmit();
        },
        (error) => {
          alert("ไม่สามารถรับตำแหน่งได้ กรุณาเปิด GPS: " + error.message);
        },
        { enableHighAccuracy: true },
      );
    } else {
      alert("Browser ไม่รองรับ Geolocation");
    }
  }
}
