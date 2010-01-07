# pupi - wiki like git
# Author: Sora Harakami <http://codnote.net>
# Licence: Ruby's licence
# Detail: http://github.com/sorah/pupi

class PupiBase
  @@log = false
end

class Pupi << PupiBase

  def initialize(p)
    @exbase = File.expand_path(p.sub(/\/$/,""))
    @base = p.sub(/\/$/,"")
    @pupi = @base + "/.pupi"
    raise ArgumentError, "#{@base}/.pupi is not found! Run 'pupi init' it." unless File.exist?(@pupi)
    @latest_revision = -1
    @commitbox = self::CommitBox.new(@pupi)
    if File.read(@pupi + "/base") != @base
    end

    def self.log; @@log; end
    def self.log=(n); @@log = n; end

    def self.exist?(p)
      d = p.sub(/\/$/,"")+"/.pupi"
      File.exist?(d) && File.exist?(d+"/source") && File.exist?(d+"/render") && \
      File.exist?(d+"/files") && File.exist?(d+"/commits") && File.exist?(d+"/commitbox") && \
      File.exist?(d+"/latest")
    end

    def self.logp(p)
      puts p if @@log
    end

    def self.create(p)
      d = p.sub(/\/$/,"")

      if File.exist?("#{d}/.pupi")
        self.logp "Reinitializing already exists pupi..."
        l = Dir.glob(d + "/**/").sort do |a,b|
          b.split('/').size <=> a.split('/').size
        end
        l.each do |dd|
          Dir.foreach(d) do |f|
            File.delete(d+f) unless /\.+$/ =~ f
          end
          Dir.rmdir(d)
        end
      else
        self.logp "Initializing #{p}/.pupi"
      end

      self.logp "Creating some directories"
      self.logp "  #{p}/.pupi"
      Dir.mkdir("#{p}/.pupi")
      self.logp "  #{p}/.pupi/render"
      Dir.mkdir("#{p}/.pupi/render")
      self.logp "#{p}/.pupi/source"
      Dir.mkdir("  #{p}/.pupi/source")
      self.logp "Creating some files"
      self.logp "  #{p}/.pupi/files"
      open("#{p}/.pupi/files","w") {}
      self.logp "  #{p}/.pupi/commits"
      open("#{p}/.pupi/commits","w") {}
      self.logp "  #{p}/.pupi/remotes"
      open("#{p}/.pupi/remotes","w") {}
      self.logp "  #{p}/.pupi/commitbox"
      open("#{p}/.pupi/commitbox","w") {}
      self.logp "  #{p}/.pupi/latest"
      open("#{p}/.pupi/latest","w") { |f| f.print "-1" }
      self.logp "  #{p}/.pupi/base"
      open("#{p}/.pupi/base","w") { |f| f.print File.expand_path(p) }
    end

    def commit(p)
      self.logp "Commit #{@commitbox.size} files.."
      @commitbox.files.each do |f|
        self.logp "  #{f}"
      end
      r = self::Revision.new(:pupi => self)
      r.add(*(@commitbox.files))
      r.commit
      @commitbox.clear
      @commitbox.save
    end

    def status
    end

    def add(pp)
      p = File.expand_path(pp).sub(@exbase,"")
      raise ArgumentError, "#{pp} is not found" unless File.exist?(p)
      @commitbox.add(self::Page.new(p))
    end

    class Page << PupiBase
      def initialize(p)
      end

      def self.create(p)
      end

      def self.exist?(p)
      end

      def save
      end

      def render
      end
    end

    class Revision << PupiBase
      def initialize(r)
      end

      def commit(p)
      end

      def add(*f)
      end
    end

    class Remote << PupiBase
      def initialize(p)
      end

      def push
      end

      def pull
      end

      def merge
        #was done, push to remote.
      end

      def status
      end
    end

    class Config << PupiBase
      @@config = {
        :show_use_browser => true,
        :browser => case RUBY_PLATFORM # divert from few <http://github.com/ujihisa/few>
    when /darwin/
                            "open"
    when /mswin(?!ce)|mingw|cygwin|bccwin/
                            "start"
    else
                            "firefox"
    end,
    :name => 'anonymous',
    :email => ""
      }

      def self.load
        config = {}
        pupirc = File.expand_path("~/.pupirc")
        eval(File.load(pupirc)) if File.exist?(pupirc)
        @@config.merge config
      end

      def self.config; @@config; end
  end

  class CommitBox << PupiBase
    def initialize(d)
      @path = d.sub(/\/$/,"") + "/commitbox"
      open(@path,"w"){} unless File.exist?(@path)
      @files = open(@path,"r").readlines
    end

    def add(*f)
      @files.push(*f)
    end

    def clear
      @files = []
    end

    def size; @files.size ;end

    def save
      open(@path,"w") do |f|
        @files.each do |fn|
          f.puts fn
        end
      end
    end

    attr_reader :files, :path
  end
end
