// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template", "container"];

  connect() {
    this.updateOptions();
  }

  add(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime(),
    );
    this.containerTarget.insertAdjacentHTML("beforeend", content);
    this.updateOptions();
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest(".nested-row");
    const destroyInput = row.querySelector("input[name*='_destroy']");

    if (destroyInput) {
      // record เก่า → set _destroy = true แล้วซ่อน
      destroyInput.value = "1";
      row.style.display = "none";
    } else {
      // record ใหม่ → ลบออกเลย
      row.remove();
    }

    this.updateOptions();
  }

  change() {
    this.updateOptions();
  }

  updateOptions() {
    const selects = this.containerTarget.querySelectorAll(
      ".nested-row:not([style*='display: none']) select",
    );
    const selectedValues = [];

    selects.forEach((select) => {
      if (select.value) {
        selectedValues.push(select.value);
      }
    });

    selects.forEach((select) => {
      const currentValue = select.value;
      select.querySelectorAll("option").forEach((option) => {
        if (option.value && option.value !== currentValue) {
          option.hidden = selectedValues.includes(option.value);
        }
      });
    });
  }
}
