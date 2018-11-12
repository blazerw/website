class PageToc < Hyperloop::Component
  param :history
  param :location
  param :section_name
  param page_name: ''

  before_mount do
    @inverted_active = false
  end

  render(DIV) do
    render_section if AppStore.section_stores[params.section_name] &&
         AppStore.section_stores[params.section_name].loaded? &&
         AppStore.section_stores[params.section_name].pages.any?
  end

  def render_section
    AppStore.section_stores[params.section_name].pages.each_with_index do |page, index|
      if page[:processed]
        is_active = page[:name] == params.page_name ? true : false
        is_active = !is_active if @inverted_active && page[:name] == params.page_name

        section_title page, index, is_active
        section_content page, index, is_active
      else
        message =  "Skipping unprocessed page #{page[:file]}"
        message = message # skip linter warning
        `console.warn(message);`
      end
    end
  end

  def section_title page, index, is_active
    A do
      display_title(page, index, is_active)
    end
    .on(:click) do
      navigate_to_page(page, index)
    end
  end

  def section_content page, index, is_active
    Sem.List(bulleted: true) do
      page[:headings].drop(1).each do |heading|
        if (heading[:level] < 3)
          link_id = "#{params.section_name}_#{page[:name]}_#{heading[:slug]}"
          selected_class = (TocStore.visible_id == heading[:slug] ? 'toc-scrollspy' : '')
          # puts "#{TocStore.visible_id} == #{heading[:slug]}"
          Sem.ListItem do
            A(class: "dark-gray-text #{selected_class}", id: "#{link_id}") { "#{heading[:text]}" }
            .on(:click) do
              navigate_to_heading page, heading
            end
          end
        end
      end
    end
  end

  def display_title page, index, is_active
    DIV { page[:headings][0][:text] }
  end

  def navigate_to_page page, index
    params.history.push "/#{AppStore.version}/docs/#{params.section_name}/#{page[:name]}"
    if params[:page_name] == page[:name]
      @inverted_active = !@inverted_active
    else
      @inverted_active = false
    end
  end

  def navigate_to_heading page, heading
    slug = "#{heading[:slug]}"
    puts "navigate_to_heading #{slug}"
    TocStore.visible_id = slug
    params.history.push "/#{AppStore.version}/docs/#{params.section_name}/#{page[:name]}##{slug}"
  end
end
