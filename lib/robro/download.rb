require 'open3'

module Robro
  class Download
    class Error < StandardError; end

    attr_reader :details

    def initialize(url)
      @url = url.sub /^http:/, 'https:'
      Robro.logger.debug "Attempt to download: #{@url}"
    end

    FILTERS = [
      #--2020-11-10 22:30:31--  https://kubuntu.org/wp-content/uploads/2020/10/6ac0/GroovyBannerv4-1024x273.png
      /^--\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}--  http/,
      #Resolving kubuntu.org (kubuntu.org)... 162.213.33.214
      /^Resolving /,
      #Connecting to kubuntu.org (kubuntu.org)|162.213.33.214|:443... connected.
      /^Connecting /,
      #Reusing existing connection to kubuntu.org:443.
      /^Reusing /,
    ]

    def run(&block)
      @details = {}

      result = false

      Open3.popen2e(
        { "LANG" => 'C'},
        'wget', '--continue', '--content-disposition', '--progress=dot:mega', @url,
      ) do |stdin, stdout_and_err, thread|
        stdout_and_err.each do |line|
          line.chomp!
          next if line.empty?

          data = extract_details line

          unless data.nil?
            data['filename'] = eval "\"#{data['filename']}\"" unless data['filename'].nil? # Handle escaped UTF-8 chars
            @details.merge! data
            block.call data, @details
          else
            puts "==='#{line}'===" unless filtred?(line)
          end
        end

        exit_status = thread.value
        @details.merge!({ exit_status: exit_status })

        raise Error.new "Error while downloading: #{error}" unless error.nil?
      end
    end

    def downloaded?
      success?
    end

    def success?
      error.nil?
    end

    def error
      return "#{details['error_code']}: #{details['error_text']}" unless details['error_code'].nil?
      return "#{details['error_text']}" unless details['error_text'].nil?
      return "Command execution failed with exit code: #{details[:exit_status].exitstatus}" unless details[:exit_status].success?

      nil
    end

    private

    def filtred?(line)
      FILTERS.each do |regexp|
        match = regexp.match line
        return true unless match.nil?
      end

      false
    end

    EXTRACTORS = [
      /^Length: (?<size>\d+)/,
      /^Saving to: '(?<filename>.*)'$/,
      #  64512K ,,,,,,,. ........ ........ ........ ........ ........  2% 1.26M 37m23s
      #  67584K ........ ........ ........ ........ ........ ........  2%  870K 42m29s
      # 101376K ........ ........ ........ ........ ........ ........  4% 4.70M 8m56s
      # 104448K ........ ........ ........ ........ ........ ........  4% 5.87M 8m41s
      # 107520K ........ ........ ........ ........ ........ ........  4% 6.17M 8m27s
      #2472960K ........ ........ ..                                 100% 5.80M=5m57s
      /^.* [,. ]{8} [,. ]{8} [,. ]{8} [,. ]{8} [,. ]{8} [,. ]{8} *(?<progress>\d+%) (?<rate>.*)[ =](?<remaining_time>.*)$/,
      #2020-11-08 09:29:55 ERROR 410: Gone.
      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ERROR (?<error_code>\d+): (?<error_text>.*)$/,
      #        [ skipping 79872K ]
      /^ +\[ skipping (?<skipping>.*) \]/,
      #2020-11-10 22:25:48 (1.19 MB/s) - 'GroovyBannerv4-1024x273.png' saved [278174/278174]
      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \((?<rate_average>.*)\) - '.*' saved/,
      #    The file is already fully retrieved; nothing to do.
      /^    (?<message>The file is already fully retrieved; nothing to do\.)$/,
      #HTTP request sent, awaiting response... 200 OK
      /^HTTP request sent, awaiting response... (?<http_status_code>\d+) (?<http_status_text>.*)$/,
      #wget: unable to resolve host address 'kuubuntu.org'
      /^wget: (?<error_text>unable to resolve host address '.*')$/,
      #Cannot write to 'kubuntu.iso' (Success).
      /^(?<error_text>Cannot write to .*)$/,
    ]

    def extract_details(line)
      result = {}
      EXTRACTORS.each do |extractor|
        result.merge! extract(extractor, line)
      end
      result == {} ? nil : result
    end

    def extract(regexp, line)
      match = regexp.match line
      return {} if match.nil?
      match.named_captures
    end
  end
end
