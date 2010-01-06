# pupi - wiki like git
# Author: Sora Harakami <http://codnote.net>
# Licence: Ruby's licence
# Detail: http://github.com/sorah/pupi
#
class Pupi
    def initialize(d)
        self.create(d) unless File.exists?("./.pupi")
    end

    def self.create(p)
    end

    def commit(p)
    end

    def status()
    end

    class Page
        def initialize(p)
        end

        def self.create(p)
        end

        def save
        end
    end

    class Revision
        def initialize(r)
        end

        def commit(p)
        end

        def add(f)
        end
    end

    class Remote
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

    class Config
        @@config = {
            :show_use_browser => true,
            :browser => case RUBY_PLATFORM
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
            eval(File.load(pupirc)) if File.exists?(pupirc)
            @@config.merge config
        end

        def self.config; @@config; end
    end
end
