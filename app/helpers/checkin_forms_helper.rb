module CheckinFormsHelper
  def attendance_count_label(count)
    number_class = count > 0 ? "text-[#261ce6]" : "text-[#6B7280]"
    label = count > 1 ? "Students" : "Student"

    content_tag(:span, class: "text-xs font-semibold text-[#6B7280]") do
      content_tag(:span, count, class: number_class) + " #{label}"
    end
  end
end
