import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["checkbox", "submit"]

    toggle() {
        this.submitTarget.disabled = !this.checkboxTarget.checked
    }
}
