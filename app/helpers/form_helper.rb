module FormHelper
  def form_input(f, field, label:, type: :text, placeholder: nil, input_html: {}, wrapper_html: {}, label_html: {}, data_testid: nil, **_extra_kwargs)
    wrapper_options = merge_html_options({ class: "w-full py-2" }, wrapper_html)
    label_options = merge_html_options({ class: "pb-2 px-1 text-base max-sm:text-sm font-medium text-[#111118]" }, label_html)

    content_tag(:div, **wrapper_options) do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label, **label_options

        has_error = f.object.respond_to?(:errors) && f.object.errors[field].present?
        input_classes = "w-full h-12 sm:h-14 rounded-lg border px-4 text-sm text-[#111118] placeholder:text-[#636388] focus:outline-none transition"
        input_classes << (has_error ? " bg-red-50 border-red-300 focus:ring-red-200 focus:border-red-300" : " bg-white border-[#dcdce5] focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6]")

        default_input_options = {
          placeholder: placeholder,
          class: input_classes,
          data: { testid: "#{field.to_s.tr('_', '-')}-input" }
        }
        input_html = (input_html || {}).dup
        if data_testid.present?
          input_html[:data] = (input_html[:data] || {}).merge(testid: data_testid)
        end
        input_options = merge_html_options(default_input_options, input_html)

        concat f.send("#{type}_field", field,
          **input_options)

        if has_error
          concat content_tag(:p, f.object.errors[field].join(", "), class: "text-xs text-red-700 mt-1 px-1")
        end
      end
    end
  end

  def form_select(f, field, label:, options:, select_html: {}, wrapper_html: {}, label_html: {}, options_html: {}, data_testid: nil, **_extra_kwargs)
    wrapper_options = merge_html_options({ class: "w-full py-2" }, wrapper_html)
    label_options = merge_html_options({ class: "pb-2 px-1 text-sm font-medium text-[#111118]" }, label_html)

    content_tag(:div, **wrapper_options) do
      content_tag(:div, class: "flex flex-col") do
        concat f.label field, label, **label_options

        has_error = f.object.respond_to?(:errors) && f.object.errors[field].present?
        select_classes = "w-full h-12 sm:h-14 rounded-lg border px-4 text-sm text-[#111118] focus:outline-none transition appearance-none"
        select_classes << (has_error ? " bg-red-50 border-red-300 focus:ring-red-200 focus:border-red-300" : " bg-white border-[#dcdce5] focus:ring-2 focus:ring-[#261ce6] focus:border-[#261ce6]")

        default_select_options = {
          class: select_classes,
          data: { testid: "#{field.to_s.tr('_', '-')}-select" }
        }
        select_html = (select_html || {}).dup
        if data_testid.present?
          select_html[:data] = (select_html[:data] || {}).merge(testid: data_testid)
        end
        merged_select_options = merge_html_options(default_select_options, select_html)

        concat f.select field, options, options_html,
          **merged_select_options

        if has_error
          concat content_tag(:p, f.object.errors[field].join(", "), class: "text-xs text-red-700 mt-1 px-1")
        end
      end
    end
  end

  def form_radio_group(f, field, label:, options:, checked: nil, data_action: nil, wrapper_html: {}, label_html: {}, group_html: {}, radio_html: {}, card_html: {}, data_testid: nil, **_extra_kwargs)
    wrapper_options = merge_html_options({ class: "w-full py-2" }, wrapper_html)
    label_options = merge_html_options({ class: "pb-2 px-1 text-base max-sm:text-sm font-medium text-[#111118] block" }, label_html)
    default_group_options = {
      class: "grid grid-cols-2 gap-4",
      data: { testid: "#{field.to_s.tr('_', '-')}-radio-group" }
    }
    group_html = (group_html || {}).dup
    if data_testid.present?
      group_html[:data] = (group_html[:data] || {}).merge(testid: data_testid)
    end
    group_options = merge_html_options(default_group_options, group_html)

    content_tag(:div, **wrapper_options) do
      concat content_tag(:label, label, **label_options)

      concat content_tag(:div, **group_options) {
        safe_join(
          options.map do |text, value|
            option_key = value.to_s.parameterize(separator: "-")
            option_key = "option" if option_key.blank?

            option_label_options = merge_html_options(
              { class: "cursor-pointer", data: { testid: "#{field.to_s.tr('_', '-')}-#{option_key}-label" } },
              {}
            )

            content_tag(:label, **option_label_options) do
              default_radio_data = { testid: "#{field.to_s.tr('_', '-')}-#{option_key}-radio" }
              default_radio_data[:action] = data_action if data_action
              default_radio_options = {
                checked: (value == checked),
                class: "peer hidden",
                data: default_radio_data
              }
              merged_radio_options = merge_html_options(default_radio_options, radio_html)

              radio = f.radio_button(
                field,
                value,
                **merged_radio_options
              )

              default_card_options = {
                class: "h-14 flex items-center justify-center rounded-xl border border-[#dcdce5]
                        bg-white text-[#111118] text-sm font-medium
                        transition-all duration-200

                        hover:border-[#261ce6] hover:shadow-sm

                        peer-checked:bg-[#f5f4ff]
                        peer-checked:border-[#261ce6]
                        peer-checked:text-[#261ce6]
                        peer-checked:ring-2 peer-checked:ring-[#261ce6]",
                data: { testid: "#{field.to_s.tr('_', '-')}-#{option_key}-card" }
              }
              merged_card_options = merge_html_options(default_card_options, card_html)

              card = content_tag(:div, text,
                **merged_card_options
              )
              radio + card
            end
          end
        )
      }
    end
  end

  private

  def merge_html_options(defaults, custom)
    merged = (defaults || {}).dup
    custom_options = (custom || {}).dup

    default_class = merged.delete(:class)
    custom_class = custom_options.delete(:class)

    default_data = merged.delete(:data) || {}
    custom_data = custom_options.delete(:data) || {}

    merged.merge!(custom_options)
    merged[:class] = [ default_class, custom_class ].compact.join(" ") if default_class || custom_class
    merged[:data] = default_data.merge(custom_data) if default_data.any? || custom_data.any?

    merged
  end
end
