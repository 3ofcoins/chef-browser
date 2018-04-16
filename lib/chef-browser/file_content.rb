# frozen_string_literal: true

require 'chef-browser/app'

module ChefBrowser
  # We use different gems for highlighting different file types: Github's markup
  # for Markdown files, and Linguist and Pygments for everything else. We don't render non-test
  # files, but allow the user to download them.
  class FileContent
    include Linguist::BlobHelper

    attr_accessor :name, :path, :data

    @highlight_options = { encoding: 'utf-8', formatter: 'html', linenos: 'inline' }
    @markup_files = %w[license changelog code_of_conduct contributing testing readme]

    def initialize(name, path, content)
      @name = name
      @path = path
      @data = content
    end

    class << self
      def show_file(file, uri_options = {})
        # Using Kernel#open (via OpenURI#open) can be a security risk but
        # alternatives don't seem to work here: we're opening a URL,
        # not a file on disk and File#open fails.
        content = FileContent.new(file.name, file.url, open(file.url, uri_options).read)
        extname = File.extname(file.name).downcase
        if extname == '.md' || @markup_files.include?(file[:name].downcase)
          GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, content.data.force_encoding("utf-8"))
        elsif content.image?
          # Unfortunately, this part has to be handled by views/file.erb
          'image'
        elsif content.text?
          FileContent.highlight_file(content.name, extname, content.data)
        end
      end

      def highlight_file(filename, extname, content)
        lexer = (Linguist::Language[extname.gsub(/^\./, '')] ||
                 Linguist::Language.find_by_filename(filename).first ||
                 Linguist::Language.find_by_extension(extname).first
                )
        if lexer
          Pygments.highlight(content, lexer: lexer.name, options: @highlight_options)
        else
          Pygments.highlight(content, lexer: 'text', options: @highlight_options)
        end
      end
    end
  end
end
