module FormHelper
  def form_input(f, field, label:, type: :text, placeholder: nil)
    content_tag(:div, class: "w-full py-2") do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label,
          class: "pb-2 px-1 text-base max-sm:text-sm font-medium text-[#111118]"

        concat f.send("#{type}_field", field,
          placeholder: placeholder,
          class: "w-full h-12 sm:h-14 rounded-lg border border-[#dcdce5] bg-white px-4 text-sm text-[#111118] placeholder:text-[#636388] focus:outline-none  focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6] transition")
      end
    end
  end

  def form_select(f, field, label:, options:)
    content_tag(:div, class: "w-full py-2") do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label,
          class: "pb-2 px-1 text-sm font-medium text-[#111118]"

        concat f.select field, options, {},
          class: "w-full h-12 sm:h-14 rounded-lg border border-[#dcdce5] bg-white px-4 text-sm text-[#111118] focus:outline-none focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6] transition"
      end
    end
  end
end
