module Robro
  class Browser
    module Helpers
      def remove_elements(css:)
        page.execute_script "document.querySelectorAll('#{css}').forEach(e => { e.remove() } )"
      end

      def click_through_overlay(element)
        element_regexp = {
          firefox: /^Element (<.*>) is not clickable at point \((\d+),(\d+)\) because another element (?<element><.*>) obscures it$/,
          chrome: /^element click intercepted: Element (<.*>) is not clickable at point \((\d+), (\d+)\)\. Other element would receive the click: (?<element><.*>)/,
        }
        loop do
          element.click(wait: 1)
          break
        rescue StandardError => e
          m_element = element_regexp[Robro.browser.application].match e.message
          unless m_element.nil?
            m_id = /id=\"(?<id>[a-zA-Z0-9-]+)/.match m_element[:element]
            unless m_id.nil?
              overlay_element_id = m_id[:id]
              Robro.logger.debug "Removing '#{overlay_element_id}' that obscures target element"
              remove_elements css: "##{overlay_element_id}"
            else
              Robro.logger.error "Unable to find element ID that obscures target (#{element}) in: '#{m_id[:element]}'"
              debugger
            end
          else
            Robro.logger.error "Unable to find element that obscures target (#{element}) in: '#{e.message}'"
            debugger
          end
        end
      end
    end
  end
end
