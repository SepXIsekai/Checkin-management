import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input",
        "filename",
        "filenameText",
        "placeholder",
        "submit",
        "dropzone"
    ]

    select() {
        const file = this.inputTarget.files[0]
        if (!file) return

        this.filenameTextTarget.textContent = file.name

        this.filenameTarget.classList.remove("hidden")
        this.filenameTarget.classList.add("flex")

        if (this.hasPlaceholderTarget) {
            this.placeholderTarget.classList.add("hidden")
        }

        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = false
        }
    }
}
