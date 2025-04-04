module ApplicationHelper
  include Pagy::Frontend

  def pagy_tailwind_nav(pagy, link_extra: "")
    raw(pagy_nav(pagy).gsub(
      /<a (.*?)>(.*?)<\/a>/, '<a \1 class="px-3 py-1 bg-blue-500 text-white rounded-md hover:bg-blue-700">\2</a>'
    ).gsub(
      /<span (.*?)>(.*?)<\/span>/, '<span \1 class="px-3 py-1 bg-gray-300 text-gray-700 rounded-md">\2</span>'
    ))
  end
end
