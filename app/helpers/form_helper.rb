module FormHelper
  def form_input(f, field, label:, type: :text, placeholder: nil)
    content_tag(:div, class: "w-full py-2") do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label,
          class: "pb-2 px-1 text-base max-sm:text-sm font-medium text-[#111118]"

        has_error = f.object.respond_to?(:errors) && f.object.errors[field].present?
        input_classes = "w-full h-12 sm:h-14 rounded-lg border px-4 text-sm text-[#111118] placeholder:text-[#636388] focus:outline-none transition"
        input_classes << (has_error ? " bg-red-50 border-red-300 focus:ring-red-200 focus:border-red-300" : " bg-white border-[#dcdce5] focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6]")

        concat f.send("#{type}_field", field,
          placeholder: placeholder,
          class: input_classes)

        if has_error
          concat content_tag(:p, f.object.errors[field].join(", "), class: "text-xs text-red-700 mt-1 px-1")
        end
      end
    end
  end

  def form_select(f, field, label:, options:)
    content_tag(:div, class: "w-full py-2") do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label,
          class: "pb-2 px-1 text-sm font-medium text-[#111118]"

        has_error = f.object.respond_to?(:errors) && f.object.errors[field].present?
        select_classes = "w-full h-12 sm:h-14 rounded-lg border px-4 text-sm text-[#111118] focus:outline-none transition appearance-none"
        select_classes << (has_error ? " bg-red-50 border-red-300 focus:ring-red-200 focus:border-red-300" : " bg-white border-[#dcdce5] focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6]")

        concat f.select field, options, {},
          class: select_classes

        if has_error
          concat content_tag(:p, f.object.errors[field].join(", "), class: "text-xs text-red-700 mt-1 px-1")
        end
      end
    end
  end

  def form_radio_group(f, field, label:, options:, checked: nil, data_action: nil)
    content_tag(:div, class: "w-full py-2") do
      concat content_tag(:label, label,
        class: "pb-2 px-1 text-base max-sm:text-sm font-medium text-[#111118] block"
      )

      concat content_tag(:div, class: "grid grid-cols-2 gap-4") {
        safe_join(
          options.map do |text, value|
            content_tag(:label, class: "cursor-pointer") do
              radio = f.radio_button(
                field,
                value,
                checked: (value == checked),
                class: "peer hidden",
                data: (data_action ? { action: data_action } : {})
              )

              card = content_tag(:div, text,
                class: "h-14 flex items-center justify-center rounded-xl border border-[#dcdce5]
                        bg-white text-[#111118] text-sm font-medium
                        transition-all duration-200

                        hover:border-[#261ce6] hover:shadow-sm

                        peer-checked:bg-[#f5f4ff]
                        peer-checked:border-[#261ce6]
                        peer-checked:text-[#261ce6]
                        peer-checked:ring-2 peer-checked:ring-[#261ce6]"
              )
              radio + card
            end
          end
        )
      }
    end
  end
end
