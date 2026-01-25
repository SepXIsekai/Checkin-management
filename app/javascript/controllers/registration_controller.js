// app/javascript/controllers/registration_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["secretCode", "studentId"]

  connect() {
    this.toggle()
  }

  toggle(event) {
    const role = event ? event.target.value : this.element.querySelector('select').value

    if (role === 'teacher') {
      this.secretCodeTarget.style.display = 'block'
      this.studentIdTarget.style.display = 'none'
    } else {
      this.secretCodeTarget.style.display = 'none'
      this.studentIdTarget.style.display = 'block'
    }
  }
}