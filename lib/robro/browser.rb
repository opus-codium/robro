require 'capybara'
require 'capybara/dsl'
require 'capybara-screenshot'

require_relative 'browser/helpers'

module Robro
  class Browser
    attr_reader :application

    include Capybara::DSL
    include Robro::Browser::Helpers

    def initialize(application)
      @application = application.to_sym
      @headless = false # FIXME ENV['GUI'].nil?

      Capybara.configure do |config|
        config.run_server = false
        config.default_max_wait_time = 5
      end

      # FIXME Register chrome_jack_headless
      require 'selenium-webdriver'
      Capybara.register_driver :chrome_jack do |app|
        options = ::Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        options.add_argument('--start-maximized')
        options.add_argument('--disable-blink-features')
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_argument('--excludeSwitches=enable-automation')
        options.add_argument('--disable-gpu')

        driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
        bridge = driver.browser.send(:bridge)

        path = '/session/:session_id/chromium/send_command'
        path[':session_id'] = bridge.session_id

        javascript = <<~JAVASCRIPT
          Object.defineProperty(document, 'visibilityState', {value: 'visible', writable: true});
          Object.defineProperty(document, 'hidden', {value: false, writable: true});
          document.dispatchEvent(new Event("visibilitychange"));

          Object.defineProperty(window, 'navigator', {
            value: new Proxy(navigator, {
            has: (target, key) => (key === 'webdriver' ? false : key in target),
            get: (target, key) =>
              key === 'webdriver'
              ? undefined
              : typeof target[key] === 'function'
              ? target[key].bind(target)
              : target[key]
            })
          });
        JAVASCRIPT

        bridge.http.call(:post, path, cmd: 'Page.addScriptToEvaluateOnNewDocument',
                         params: {
          source: javascript,
        })

        driver
      end

      Capybara.current_driver = driver

      Capybara::Screenshot.register_driver(Capybara.current_driver) do |driver, path|
        driver.browser.save_screenshot(path)
      end

      Robro.logger.debug "Browser User-Agent: '#{page.execute_script 'return navigator.userAgent'}'"

      Robro.logger.debug "Capybara driver: #{Capybara.current_driver} (application: #{application}, headless: #{headless?})"
    end

    def headless?
      @headless
    end

    def clear
      visit 'file:///dev/null'
    end

    def close_other_tabs
      current_tab = page.driver.browser.window_handle
      tabs = page.driver.browser.window_handles - [current_tab]
      tabs.each do |tab|
        page.driver.browser.switch_to.window(tab)
        page.driver.browser.close
      end
      page.driver.browser.switch_to.window current_tab
    end

    def keep_only_tabs_with(url:)
      tabs = page.driver.browser.window_handles

      tabs.each do |tab|
        page.driver.browser.switch_to.window(tab)
        page.driver.browser.close unless page.current_url.start_with?(url_start_with)
      end
    end

    private

    def driver
      @application = 'chrome' if @application == 'chromium'

      driver_name = case @application
      when :firefox
        'selenium'
      when :chrome
        'chrome_jack'
      else
        raise "Unsupported browser: '#{application}'"
      end

      driver_name += '_headless' if @headless

      driver_name.to_sym
    end
  end
end
