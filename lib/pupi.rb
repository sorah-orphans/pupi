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
        @@config = {}
        def self.load
            config = @@config
            eval(File.load(File.expand_path("~/.pupirc")))
        end
        def self.config; @@config; end
    end
end
